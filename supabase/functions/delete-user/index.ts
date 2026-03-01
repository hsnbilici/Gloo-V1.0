// Supabase Edge Function: Kullanici Hesap Silme (GDPR Article 17)
//
// 1. JWT dogrulama (sadece kendi hesabini silebilir)
// 2. delete_user_data RPC cagrisi (uygulama tablolari — transaction)
// 3. auth.admin.deleteUser() (auth.users satiri)
//
// Deploy: supabase functions deploy delete-user
// Cagri: POST /functions/v1/delete-user
//   Headers: Authorization: Bearer <user_token>

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

    // ── Service role client (RLS bypass + admin API) ──────────────────────
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // ── 1. Uygulama tablolarini sil (transaction — mevcut RPC) ────────────
    const { error: rpcError } = await supabase
      .rpc('delete_user_data', { p_user_id: userId })

    if (rpcError) {
      return new Response(
        JSON.stringify({ error: 'Failed to delete user data', detail: rpcError.message }),
        { status: 500, headers: CORS_HEADERS },
      )
    }

    // ── 2. auth.users satirini sil ────────────────────────────────────────
    const { error: authDeleteError } = await supabase.auth.admin.deleteUser(userId)

    if (authDeleteError) {
      return new Response(
        JSON.stringify({ error: 'Failed to delete auth user', detail: authDeleteError.message }),
        { status: 500, headers: CORS_HEADERS },
      )
    }

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: CORS_HEADERS },
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: CORS_HEADERS },
    )
  }
})
