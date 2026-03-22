// Supabase Edge Function: ELO Hesaplama (Anti-Cheat)
//
// Bu fonksiyon mac tamamlandiginda cagirilir.
// Client dogrudan ELO guncelleyemez — bu fonksiyon:
// 1. Auth dogrulama yapar (token + match katilimci kontrolu)
// 2. pvp_matches tablosundan iki oyuncunun skorunu dogrular
// 3. ELO degisimini hesaplar (dinamik K-Factor)
// 4. profiles tablosunu gunceller
//
// Deploy: supabase functions deploy calculate-elo
// Cagri: POST /functions/v1/calculate-elo
//   Headers: Authorization: Bearer <user_token>
//   Body: { matchId: "uuid" }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

/** Dynamic K-Factor: lower ELO = faster movement, higher = more stable.
 *  SYNC: This formula must stay in sync with client (matchmaking.dart).
 *  If you change tiers here, update the Dart version too. */
function getKFactor(playerElo: number): number {
  if (playerElo < 800) return 40
  if (playerElo < 1200) return 32
  if (playerElo < 1600) return 28
  return 24
}

const CORS_HEADERS = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface MatchRow {
  id: string
  player1_id: string
  player2_id: string | null
  seed: number
  status: string
  player1_score: number | null
  player2_score: number | null
  winner_id: string | null
}

interface ProfileRow {
  id: string
  elo: number
  pvp_wins: number
  pvp_losses: number
}

function calculateEloChange(
  playerElo: number,
  opponentElo: number,
  outcome: number, // 1 = win, 0 = loss, 0.5 = draw
): number {
  const k = getKFactor(playerElo)
  const expected = 1.0 / (1.0 + Math.pow(10, (opponentElo - playerElo) / 400))
  return Math.round(k * (outcome - expected))
}

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS })
  }

  try {
    // ── Auth dogrulama ──────────────────────────────────────────────────────
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Authorization header required' }),
        { status: 401, headers: CORS_HEADERS },
      )
    }

    // Kullanici token'ini dogrula
    const token = authHeader.replace('Bearer ', '')
    const anonClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: `Bearer ${token}` } } },
    )

    const { data: { user }, error: authError } = await anonClient.auth.getUser(token)
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid auth token' }),
        { status: 401, headers: CORS_HEADERS },
      )
    }

    const userId = user.id

    // ── Request body ────────────────────────────────────────────────────────
    const { matchId } = await req.json()

    if (!matchId || typeof matchId !== 'string' || matchId.length > 100) {
      return new Response(
        JSON.stringify({ error: 'Invalid matchId' }),
        { status: 400, headers: CORS_HEADERS },
      )
    }

    // Supabase service role client (RLS bypass)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Mac bilgisini getir
    const { data: match, error: matchError } = await supabase
      .from('pvp_matches')
      .select('*')
      .eq('id', matchId)
      .single()

    if (matchError || !match) {
      return new Response(JSON.stringify({ error: 'Mac bulunamadi' }), {
        status: 404,
        headers: CORS_HEADERS,
      })
    }

    const m = match as MatchRow

    // ── Katilimci kontrolu ──────────────────────────────────────────────────
    // Dogrulanan kullanicinin bu match'in player1 veya player2'si oldugunu kontrol et
    if (userId !== m.player1_id && userId !== m.player2_id) {
      return new Response(
        JSON.stringify({ error: 'Not a participant of this match' }),
        { status: 403, headers: CORS_HEADERS },
      )
    }

    // Iki skor da girilmis olmali
    if (m.player1_score === null || m.player2_score === null) {
      return new Response(JSON.stringify({ error: 'Skorlar eksik' }), {
        status: 400,
        headers: CORS_HEADERS,
      })
    }

    // Mac zaten tamamlanmissa tekrar hesaplama
    if (m.status === 'completed') {
      return new Response(JSON.stringify({ error: 'Mac zaten tamamlandi' }), {
        status: 409,
        headers: CORS_HEADERS,
      })
    }

    // Bot eslestirme — sadece player1'in ELO'sunu guncelle
    const isBot = m.player2_id === null

    // Profilleri getir
    const { data: p1Profile } = await supabase
      .from('profiles')
      .select('id, elo, pvp_wins, pvp_losses')
      .eq('id', m.player1_id)
      .single()

    if (!p1Profile) {
      return new Response(JSON.stringify({ error: 'Oyuncu 1 profili bulunamadi' }), {
        status: 404,
        headers: CORS_HEADERS,
      })
    }

    const player1 = p1Profile as ProfileRow
    let player2: ProfileRow | null = null

    if (!isBot && m.player2_id) {
      const { data: p2Data } = await supabase
        .from('profiles')
        .select('id, elo, pvp_wins, pvp_losses')
        .eq('id', m.player2_id)
        .single()
      player2 = p2Data as ProfileRow | null
    }

    // Kazanani belirle
    let winnerId: string | null = null
    let p1Outcome: number
    let p2Outcome: number

    if (m.player1_score > m.player2_score) {
      winnerId = m.player1_id
      p1Outcome = 1.0
      p2Outcome = 0.0
    } else if (m.player2_score > m.player1_score) {
      winnerId = m.player2_id
      p1Outcome = 0.0
      p2Outcome = 1.0
    } else {
      p1Outcome = 0.5
      p2Outcome = 0.5
    }

    // ELO hesapla
    const opponentElo = player2?.elo ?? Math.round(player1.elo * 0.9)
    const p1EloChange = calculateEloChange(player1.elo, opponentElo, p1Outcome)
    const newP1Elo = Math.max(0, player1.elo + p1EloChange)

    // Player 1 profilini guncelle
    await supabase
      .from('profiles')
      .update({
        elo: newP1Elo,
        pvp_wins: player1.pvp_wins + (p1Outcome === 1.0 ? 1 : 0),
        pvp_losses: player1.pvp_losses + (p1Outcome === 0.0 ? 1 : 0),
      })
      .eq('id', m.player1_id)

    // Player 2 profilini guncelle (bot degilse)
    let p2EloChange = 0
    if (player2) {
      p2EloChange = calculateEloChange(player2.elo, player1.elo, p2Outcome)
      const newP2Elo = Math.max(0, player2.elo + p2EloChange)

      await supabase
        .from('profiles')
        .update({
          elo: newP2Elo,
          pvp_wins: player2.pvp_wins + (p2Outcome === 1.0 ? 1 : 0),
          pvp_losses: player2.pvp_losses + (p2Outcome === 0.0 ? 1 : 0),
        })
        .eq('id', player2.id)
    }

    // Mac durumunu guncelle
    await supabase
      .from('pvp_matches')
      .update({
        status: 'completed',
        winner_id: winnerId,
        completed_at: new Date().toISOString(),
      })
      .eq('id', matchId)

    return new Response(
      JSON.stringify({
        matchId,
        winnerId,
        player1: {
          id: m.player1_id,
          score: m.player1_score,
          eloChange: p1EloChange,
          newElo: newP1Elo,
        },
        player2: isBot
          ? { id: 'bot', score: m.player2_score, eloChange: 0 }
          : {
              id: m.player2_id,
              score: m.player2_score,
              eloChange: p2EloChange,
              newElo: player2 ? Math.max(0, player2.elo + p2EloChange) : null,
            },
      }),
      {
        status: 200,
        headers: CORS_HEADERS,
      },
    )
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: CORS_HEADERS,
    })
  }
})
