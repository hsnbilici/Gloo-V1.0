// Supabase Edge Function: Decline Challenge
//
// Declines a pending challenge and refunds sender's wager.
//
// Deploy: supabase functions deploy decline-challenge
// POST /functions/v1/decline-challenge
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
    if (challenge.status !== 'pending') {
      return errorResponse('Challenge is no longer pending')
    }

    // Only the designated recipient can decline (open challenges cannot be declined)
    if (challenge.recipient_id === null) {
      return errorResponse('Open challenges cannot be declined — use cancel instead')
    }
    if (challenge.recipient_id !== userId) {
      return errorResponse('This challenge is not for you', 403)
    }

    // ── Refund sender wager ──────────────────────────────────────────────────
    const wagerAmount = challenge.wager ?? 0

    if (wagerAmount > 0) {
      await supabase.rpc('credit_balance', {
        p_user_id: challenge.sender_id,
        p_amount: wagerAmount,
      }).catch((err: unknown) => {
        console.error('Failed to refund sender wager:', err)
      })
    }

    // ── Update challenge status ──────────────────────────────────────────────
    const { error: updateError } = await supabase
      .from('challenges')
      .update({
        status: 'declined',
        completed_at: new Date().toISOString(),
      })
      .eq('id', challengeId)
      .eq('status', 'pending') // optimistic lock

    if (updateError) {
      return errorResponse('Failed to decline challenge: ' + updateError.message)
    }

    return jsonResponse({ success: true })
  } catch (err) {
    return errorResponse(String(err), 500)
  }
})
