// Supabase Edge Function: Claim Deep Link Challenge
//
// Claims an open (recipient_id=null) challenge via deep link.
// Deep link challenges have NO wager.
//
// Deploy: supabase functions deploy claim-deep-link-challenge
// POST /functions/v1/claim-deep-link-challenge
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
    if (challenge.recipient_id !== null) {
      return errorResponse('Challenge already claimed')
    }

    if (challenge.status !== 'pending') {
      return errorResponse('Challenge is no longer pending')
    }

    if (challenge.sender_id === userId) {
      return errorResponse('Cannot claim your own challenge')
    }

    // Check expiration
    if (new Date(challenge.expires_at) < new Date()) {
      return errorResponse('Challenge has expired')
    }

    // ── Update challenge (no wager for deep link) ────────────────────────────
    const { error: updateError } = await supabase
      .from('challenges')
      .update({
        recipient_id: userId,
        status: 'active',
        accepted_at: new Date().toISOString(),
      })
      .eq('id', challengeId)
      .eq('status', 'pending') // optimistic lock
      .is('recipient_id', null) // ensure not already claimed

    if (updateError) {
      return errorResponse('Failed to claim challenge: ' + updateError.message)
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
    })
  } catch (err) {
    return errorResponse(String(err), 500)
  }
})
