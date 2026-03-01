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

    // ── Per-user kontrol: ayni kullanici ayni kodu tekrar kullanamasin ────
    const { data: existingUsage, error: usageCheckError } = await supabase
      .from('redeem_usages')
      .select('id')
      .eq('code_id', codeData.id)
      .eq('user_id', userId)
      .maybeSingle()

    if (usageCheckError) {
      return new Response(
        JSON.stringify({ error: 'Failed to check usage history' }),
        { status: 500, headers: CORS_HEADERS },
      )
    }

    if (existingUsage) {
      return new Response(
        JSON.stringify({ success: false, error: 'already_redeemed' }),
        { status: 409, headers: CORS_HEADERS },
      )
    }

    // ── Basarili: kullanim kaydini olustur ve current_uses artir ──────────
    const { error: insertUsageError } = await supabase
      .from('redeem_usages')
      .insert({ code_id: codeData.id, user_id: userId })

    if (insertUsageError) {
      // UNIQUE constraint ihlali — race condition durumunda
      if (insertUsageError.code === '23505') {
        return new Response(
          JSON.stringify({ success: false, error: 'already_redeemed' }),
          { status: 409, headers: CORS_HEADERS },
        )
      }
      return new Response(
        JSON.stringify({ error: 'Failed to record usage' }),
        { status: 500, headers: CORS_HEADERS },
      )
    }

    // ── Atomik artırma: race condition olmadan current_uses kontrol + artır ──
    const { data: rpcResult, error: rpcError } = await supabase
      .rpc('increment_redeem_usage', { p_code_id: codeData.id })

    if (rpcError) {
      // Usage zaten insert edildi, geri al
      await supabase
        .from('redeem_usages')
        .delete()
        .eq('code_id', codeData.id)
        .eq('user_id', userId)
      return new Response(
        JSON.stringify({ error: 'Failed to update code usage' }),
        { status: 500, headers: CORS_HEADERS },
      )
    }

    if (rpcResult === -1) {
      // Limit aşılmış — usage kaydını da geri al
      await supabase
        .from('redeem_usages')
        .delete()
        .eq('code_id', codeData.id)
        .eq('user_id', userId)
      return new Response(
        JSON.stringify({ error: 'Code usage limit reached' }),
        { status: 410, headers: CORS_HEADERS },
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
