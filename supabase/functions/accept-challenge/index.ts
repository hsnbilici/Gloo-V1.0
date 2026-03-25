// Supabase Edge Function: Accept Challenge
//
// Accepts a pending challenge, deducting wager escrow for recipient.
//
// Deploy: supabase functions deploy accept-challenge
// POST /functions/v1/accept-challenge
//   Headers: Authorization: Bearer <user_token>
//   Body: { challengeId: string }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import {
  CORS_HEADERS,
  createServiceClient,
  getUserId,
  jsonResponse,
  errorResponse,
  checkRateLimit,
} from '../_shared/challenge_helpers.ts'

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS })
  }

  if (req.method !== 'POST') {
    return errorResponse('Method not allowed', 405)
  }

  try {
    // ── Auth ──────────────────────────────────────────────────────────────────
    const authResult = await getUserId(req)
    if ('error' in authResult) return authResult.error
    const { userId } = authResult

    // ── Rate limit ───────────────────────────────────────────────────────────
    if (!checkRateLimit(userId, 10)) {
      return errorResponse('Rate limit exceeded', 429)
    }

    // ── Request body ─────────────────────────────────────────────────────────
    const { challengeId } = await req.json()

    if (!challengeId || typeof challengeId !== 'string') {
      return errorResponse('Invalid challengeId')
    }

    const supabase = createServiceClient()

    // ── Fetch challenge ──────────────────────────────────────────────────────
    const { data: challenge, error: fetchError } = await supabase
      .from('challenges')
      .select('*')
      .eq('id', challengeId)
      .single()

    if (fetchError || !challenge) {
      return errorResponse('Challenge not found', 404)
    }

    // ── Verify eligibility ───────────────────────────────────────────────────
    if (challenge.status !== 'pending') {
      return errorResponse('Challenge is no longer pending')
    }

    if (challenge.sender_id === userId) {
      return errorResponse('Cannot accept your own challenge')
    }

    // recipient_id must be null (open) or match this user
    if (challenge.recipient_id !== null && challenge.recipient_id !== userId) {
      return errorResponse('This challenge is not for you', 403)
    }

    // Check expiration
    if (new Date(challenge.expires_at) < new Date()) {
      return errorResponse('Challenge has expired')
    }

    // ── Wager escrow for recipient ───────────────────────────────────────────
    const wagerAmount = challenge.wager ?? 0
    let newBalance: number | null = null

    if (wagerAmount > 0) {
      // Ensure balances row exists
      await supabase
        .from('balances')
        .upsert({ user_id: userId }, { onConflict: 'user_id', ignoreDuplicates: true })

      // Check balance
      const { data: balanceRow } = await supabase
        .from('balances')
        .select('gel_ozu')
        .eq('user_id', userId)
        .single()

      if (!balanceRow || balanceRow.gel_ozu < wagerAmount) {
        return errorResponse('Insufficient balance for wager')
      }

      // Deduct via RPC (atomic)
      const { error: deductError } = await supabase.rpc('deduct_balance', {
        p_user_id: userId,
        p_amount: wagerAmount,
      })

      if (deductError) {
        return errorResponse('Failed to deduct wager: ' + deductError.message)
      }
    }

    // ── Update challenge ─────────────────────────────────────────────────────
    const { error: updateError } = await supabase
      .from('challenges')
      .update({
        recipient_id: userId,
        status: 'active',
        accepted_at: new Date().toISOString(),
      })
      .eq('id', challengeId)
      .eq('status', 'pending') // optimistic lock

    if (updateError) {
      // Refund recipient wager on failure
      if (wagerAmount > 0) {
        await supabase.rpc('credit_balance', {
          p_user_id: userId,
          p_amount: wagerAmount,
        }).catch(() => {})
      }
      return errorResponse('Failed to accept challenge: ' + updateError.message)
    }

    // ── Fetch updated balance if not already known ───────────────────────────
    if (newBalance === null) {
      const { data: balRow } = await supabase
        .from('balances')
        .select('gel_ozu')
        .eq('user_id', userId)
        .single()
      newBalance = balRow?.gel_ozu ?? null
    }

    // Return challenge with seed for gameplay (sender_score hidden until completion)
    return jsonResponse({
      challenge: {
        id: challenge.id,
        mode: challenge.mode,
        seed: challenge.seed,
        wager: challenge.wager,
        expires_at: challenge.expires_at,
      },
      balance: newBalance,
    })
  } catch (err) {
    return errorResponse(String(err), 500)
  }
})
