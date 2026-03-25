// Supabase Edge Function: Submit Challenge Score
//
// Submits the recipient's score, determines winner, distributes rewards.
//
// Deploy: supabase functions deploy submit-challenge-score
// POST /functions/v1/submit-challenge-score
//   Headers: Authorization: Bearer <user_token>
//   Body: { challengeId: string, recipientScore: number }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import {
  CORS_HEADERS,
  createServiceClient,
  getUserId,
  jsonResponse,
  errorResponse,
  REWARDS,
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
    const { challengeId, recipientScore } = await req.json()

    if (!challengeId || typeof challengeId !== 'string') {
      return errorResponse('Invalid challengeId')
    }

    if (typeof recipientScore !== 'number' || recipientScore < 0) {
      return errorResponse('Invalid recipientScore')
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
    if (challenge.recipient_id !== userId) {
      return errorResponse('Only the recipient can submit a score', 403)
    }

    if (challenge.status !== 'active') {
      return errorResponse('Challenge is not active')
    }

    if (challenge.recipient_score !== null) {
      return errorResponse('Score already submitted', 409)
    }

    // ── Determine winner ─────────────────────────────────────────────────────
    const senderScore = challenge.sender_score as number
    const wagerAmount = challenge.wager ?? 0

    let outcome: 'win' | 'lose' | 'draw'
    if (recipientScore > senderScore) {
      outcome = 'win'
    } else if (recipientScore < senderScore) {
      outcome = 'lose'
    } else {
      outcome = 'draw'
    }

    // ── Check Gloo+ status for both players ──────────────────────────────────
    const { data: profiles } = await supabase
      .from('profiles')
      .select('id, gloo_plus')
      .in('id', [userId, challenge.sender_id])

    const profileMap = new Map<string, boolean>()
    for (const p of profiles ?? []) {
      profileMap.set(p.id, p.gloo_plus === true)
    }

    const recipientGlooPlus = profileMap.get(userId) ?? false
    const senderGlooPlus = profileMap.get(challenge.sender_id) ?? false

    // ── Calculate rewards ────────────────────────────────────────────────────
    let recipientReward = 0
    let senderReward = 0

    if (outcome === 'win') {
      // Recipient wins
      recipientReward = wagerAmount > 0 ? wagerAmount * 2 : REWARDS.winBase
      senderReward = wagerAmount > 0 ? 0 : REWARDS.loseBase
    } else if (outcome === 'lose') {
      // Sender wins
      senderReward = wagerAmount > 0 ? wagerAmount * 2 : REWARDS.winBase
      recipientReward = wagerAmount > 0 ? 0 : REWARDS.loseBase
    } else {
      // Draw — refund wagers + participation reward
      recipientReward = wagerAmount + REWARDS.drawBase
      senderReward = wagerAmount + REWARDS.drawBase
    }

    // Apply Gloo+ bonus to ALL rewards (spec: "Gloo+ bonus tum odullere uygulanir")
    if (recipientGlooPlus && recipientReward > 0) {
      recipientReward = Math.round(recipientReward * REWARDS.glooPlusBonusMultiplier)
    }
    if (senderGlooPlus && senderReward > 0) {
      senderReward = Math.round(senderReward * REWARDS.glooPlusBonusMultiplier)
    }

    // ── Credit rewards (must succeed before marking completed) ───────────────
    let creditFailed = false

    if (recipientReward > 0) {
      await supabase
        .from('balances')
        .upsert({ user_id: userId }, { onConflict: 'user_id', ignoreDuplicates: true })

      const { error: creditErr } = await supabase.rpc('credit_balance', {
        p_user_id: userId,
        p_amount: recipientReward,
      })
      if (creditErr) {
        console.error('Failed to credit recipient reward:', creditErr)
        creditFailed = true
      }
    }

    if (senderReward > 0) {
      await supabase
        .from('balances')
        .upsert(
          { user_id: challenge.sender_id },
          { onConflict: 'user_id', ignoreDuplicates: true },
        )

      const { error: creditErr } = await supabase.rpc('credit_balance', {
        p_user_id: challenge.sender_id,
        p_amount: senderReward,
      })
      if (creditErr) {
        console.error('Failed to credit sender reward:', creditErr)
        creditFailed = true
      }
    }

    if (creditFailed) {
      return errorResponse('Failed to distribute rewards — please retry', 500)
    }

    // ── Update challenge (only after rewards credited) ───────────────────────
    const { error: updateError } = await supabase
      .from('challenges')
      .update({
        recipient_score: recipientScore,
        status: 'completed',
        completed_at: new Date().toISOString(),
      })
      .eq('id', challengeId)
      .eq('status', 'active') // optimistic lock

    if (updateError) {
      return errorResponse('Failed to update challenge: ' + updateError.message)
    }

    // ── Fetch updated recipient balance ──────────────────────────────────────
    const { data: balRow } = await supabase
      .from('balances')
      .select('gel_ozu')
      .eq('user_id', userId)
      .single()

    return jsonResponse({
      outcome,
      sender_score: senderScore,
      recipient_score: recipientScore,
      gel_reward: recipientReward,
      balance: balRow?.gel_ozu ?? null,
    })
  } catch (err) {
    return errorResponse(String(err), 500)
  }
})
