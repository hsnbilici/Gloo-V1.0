// Supabase Edge Function: Create Challenge
//
// Creates a new challenge with server-generated seed and optional wager escrow.
//
// Deploy: supabase functions deploy create-challenge
// POST /functions/v1/create-challenge
//   Headers: Authorization: Bearer <user_token>
//   Body: { mode: string, senderScore: number, wager: number, recipientId?: string }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import {
  CORS_HEADERS,
  createServiceClient,
  getUserId,
  jsonResponse,
  errorResponse,
  checkRateLimit,
  VALID_WAGERS,
  VALID_MODES,
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
    const { mode, senderScore, wager, recipientId } = await req.json()

    // Validate mode
    if (!mode || !VALID_MODES.has(mode)) {
      return errorResponse('Invalid mode. Must be classic, colorChef, or timeTrial')
    }

    // Validate senderScore
    if (typeof senderScore !== 'number' || senderScore < 0) {
      return errorResponse('Invalid senderScore')
    }

    // Validate wager
    const wagerAmount = wager ?? 0
    if (!VALID_WAGERS.has(wagerAmount)) {
      return errorResponse('Invalid wager. Must be 0, 10, 25, or 50')
    }

    const supabase = createServiceClient()

    // ── Check Gloo+ status & daily limit ─────────────────────────────────────
    const { data: profile } = await supabase
      .from('profiles')
      .select('gloo_plus')
      .eq('id', userId)
      .single()

    const isGlooPlus = profile?.gloo_plus === true
    const dailyLimit = isGlooPlus ? 20 : 5

    // Count today's challenges by this user
    const todayStart = new Date()
    todayStart.setUTCHours(0, 0, 0, 0)

    const { count: todayCount } = await supabase
      .from('challenges')
      .select('id', { count: 'exact', head: true })
      .eq('sender_id', userId)
      .gte('created_at', todayStart.toISOString())

    if ((todayCount ?? 0) >= dailyLimit) {
      return errorResponse(
        `Daily challenge limit reached (${dailyLimit}). ${isGlooPlus ? '' : 'Upgrade to Gloo+ for 20/day.'}`,
      )
    }

    // ── Wager escrow ─────────────────────────────────────────────────────────
    let newBalance: number | null = null

    if (wagerAmount > 0) {
      // Ensure balances row exists (upsert for first-time migration)
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
      const { data: deductResult, error: deductError } = await supabase.rpc('deduct_balance', {
        p_user_id: userId,
        p_amount: wagerAmount,
      })

      if (deductError) {
        return errorResponse('Failed to deduct wager: ' + deductError.message)
      }

      newBalance = deductResult
    }

    // ── Generate seed server-side ────────────────────────────────────────────
    const seed = Math.floor(Math.random() * 2147483647)

    // ── Insert challenge ─────────────────────────────────────────────────────
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()

    const { data: challenge, error: insertError } = await supabase
      .from('challenges')
      .insert({
        sender_id: userId,
        recipient_id: recipientId ?? null,
        mode,
        seed,
        sender_score: senderScore,
        wager: wagerAmount,
        status: 'pending',
        expires_at: expiresAt,
      })
      .select('id')
      .single()

    if (insertError || !challenge) {
      // Refund wager on failure
      if (wagerAmount > 0) {
        await supabase.rpc('credit_balance', {
          p_user_id: userId,
          p_amount: wagerAmount,
        }).catch(() => {})
      }
      return errorResponse('Failed to create challenge: ' + (insertError?.message ?? 'unknown'))
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

    return jsonResponse({ challengeId: challenge.id, balance: newBalance })
  } catch (err) {
    return errorResponse(String(err), 500)
  }
})
