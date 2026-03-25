// Supabase Edge Function: Cancel Challenge
//
// Cancels a pending challenge created by the caller and refunds wager.
//
// Deploy: supabase functions deploy cancel-challenge
// POST /functions/v1/cancel-challenge
//   Headers: Authorization: Bearer <user_token>
//   Body: { challengeId: string }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import {
  CORS_HEADERS,
  createServiceClient,
  getUserId,
  jsonResponse,
  errorResponse,
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
    if (challenge.sender_id !== userId) {
      return errorResponse('Only the sender can cancel a challenge', 403)
    }

    if (challenge.status !== 'pending') {
      return errorResponse('Challenge is no longer pending')
    }

    // ── Refund sender wager ──────────────────────────────────────────────────
    const wagerAmount = challenge.wager ?? 0

    if (wagerAmount > 0) {
      await supabase.rpc('credit_balance', {
        p_user_id: userId,
        p_amount: wagerAmount,
      }).catch((err: unknown) => {
        console.error('Failed to refund sender wager:', err)
      })
    }

    // ── Update challenge status ──────────────────────────────────────────────
    const { error: updateError } = await supabase
      .from('challenges')
      .update({
        status: 'cancelled',
        completed_at: new Date().toISOString(),
      })
      .eq('id', challengeId)
      .eq('status', 'pending') // optimistic lock

    if (updateError) {
      return errorResponse('Failed to cancel challenge: ' + updateError.message)
    }

    return jsonResponse({ success: true })
  } catch (err) {
    return errorResponse(String(err), 500)
  }
})
