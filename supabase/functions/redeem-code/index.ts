// Supabase Edge Function: Redeem Code Dogrulama
//
// Client dogrudan redeem_codes tablosuna erismez.
// Tum dogrulama ve guncelleme bu Edge Function uzerinden yapilir.
// service_role key ile RLS bypass edilir.
//
// Deploy: supabase functions deploy redeem-code
// Cagri: POST /functions/v1/redeem-code
//   Headers: Authorization: Bearer <user_token>
//   Body: { code: string }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const CORS_HEADERS = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
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
    const { code } = await req.json()
    if (!code || typeof code !== 'string') {
      return new Response(
        JSON.stringify({ error: 'code is required' }),
        { status: 400, headers: CORS_HEADERS },
      )
    }

    const normalizedCode = code.toUpperCase().trim()

    // ── Service role client (RLS bypass) ────────────────────────────────────
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // ── Kodu dogrula ────────────────────────────────────────────────────────
    const { data: codeData, error: codeError } = await supabase
      .from('redeem_codes')
      .select('*')
      .eq('code', normalizedCode)
      .maybeSingle()

    if (codeError || !codeData) {
      return new Response(
        JSON.stringify({ error: 'Invalid code' }),
        { status: 404, headers: CORS_HEADERS },
      )
    }

    // Suresi gecmis mi?
    if (codeData.expires_at) {
      const expiry = new Date(codeData.expires_at)
      if (new Date() > expiry) {
        return new Response(
          JSON.stringify({ error: 'Code expired' }),
          { status: 410, headers: CORS_HEADERS },
        )
      }
    }

    // Max uses asilmis mi?
    if (codeData.current_uses >= codeData.max_uses) {
      return new Response(
        JSON.stringify({ error: 'Code usage limit reached' }),
        { status: 410, headers: CORS_HEADERS },
      )
    }

    // Kullanici bu kodu daha once kullanmis mi?
    // redeem_usages tablosu yoksa bu kontrolu atlayabiliriz,
    // ama ek guvenlik icin profiles.redeemed_codes JSONB alani kullanilabilir.
    // Su an basit akis: max_uses kontrolu yeterli.

    // ── Basarili: current_uses artir ────────────────────────────────────────
    const { error: updateError } = await supabase
      .from('redeem_codes')
      .update({ current_uses: codeData.current_uses + 1 })
      .eq('id', codeData.id)

    if (updateError) {
      return new Response(
        JSON.stringify({ error: 'Failed to update code usage' }),
        { status: 500, headers: CORS_HEADERS },
      )
    }

    // Urun listesini don
    const productIds: string[] = codeData.product_ids ?? []

    return new Response(
      JSON.stringify({
        success: true,
        productIds,
        userId,
      }),
      { status: 200, headers: CORS_HEADERS },
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: CORS_HEADERS },
    )
  }
})
