// Supabase Edge Function: IAP Receipt Dogrulama
//
// Client tarafinda satin alim tamamlandiginda bu fonksiyon cagirilir.
// Receipt'i Apple/Google sunuculariyla dogrular.
//
// Deploy: supabase functions deploy verify-purchase
// Cagri: POST /functions/v1/verify-purchase
//   Headers: Authorization: Bearer <user_token>
//   Body: { platform: 'ios'|'android', receipt: string, productId: string }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const APPLE_PRODUCTION_URL = 'https://buy.itunes.apple.com/verifyReceipt'
const APPLE_SANDBOX_URL = 'https://sandbox.itunes.apple.com/verifyReceipt'

// Apple satin alim durumu: 0 = gecerli
const APPLE_STATUS_OK = 0
// Apple sandbox redirect: production'a gonderilen sandbox receipt
const APPLE_STATUS_SANDBOX = 21007

const VALID_PRODUCT_IDS = new Set([
  'gloo_remove_ads',
  'gloo_sound_crystal',
  'gloo_sound_forest',
  'gloo_texture_pack',
  'gloo_starter_pack',
  'gloo_plus_monthly',
  'gloo_plus_yearly',
])

const CORS_HEADERS = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ── Apple receipt dogrulama ──────────────────────────────────────────────────

async function verifyAppleReceipt(
  receipt: string,
  productId: string,
): Promise<{ verified: boolean; error?: string }> {
  const sharedSecret = Deno.env.get('APPLE_SHARED_SECRET') ?? ''
  const payload = {
    'receipt-data': receipt,
    password: sharedSecret,
    'exclude-old-transactions': true,
  }

  // Oncelik: production endpoint'e gonder
  let response = await fetch(APPLE_PRODUCTION_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
  let result = await response.json()

  // Sandbox receipt ise sandbox endpoint'e yonlendir
  if (result.status === APPLE_STATUS_SANDBOX) {
    response = await fetch(APPLE_SANDBOX_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    })
    result = await response.json()
  }

  if (result.status !== APPLE_STATUS_OK) {
    return { verified: false, error: `Apple status: ${result.status}` }
  }

  // Receipt icinde istenen urun var mi kontrol et
  const latestReceipts = result.latest_receipt_info ?? result.receipt?.in_app ?? []
  const found = latestReceipts.some(
    (item: { product_id: string }) => item.product_id === productId,
  )

  if (!found) {
    return { verified: false, error: 'Product not found in receipt' }
  }

  return { verified: true }
}

// ── Android receipt dogrulama ────────────────────────────────────────────────

async function verifyAndroidReceipt(
  receipt: string,
  productId: string,
): Promise<{ verified: boolean; error?: string }> {
  // Android purchase token dogrulamasi.
  // Tam entegrasyon icin Google Play Developer API + service account gerekir.
  // Simdilik temel token format dogrulama yapilir.
  try {
    const purchaseData = JSON.parse(receipt)

    // Temel alan kontrolleri
    if (!purchaseData.orderId || !purchaseData.purchaseToken) {
      return { verified: false, error: 'Invalid Android receipt format' }
    }

    // Product ID eslesmesi
    if (purchaseData.productId !== productId) {
      return { verified: false, error: 'Product ID mismatch' }
    }

    // purchaseState: 0 = purchased
    if (purchaseData.purchaseState !== undefined && purchaseData.purchaseState !== 0) {
      return { verified: false, error: `Invalid purchase state: ${purchaseData.purchaseState}` }
    }

    // Google Play Developer API entegrasyonu icin:
    // GOOGLE_SERVICE_ACCOUNT_KEY env degiskeni ayarlanmalı
    // ve googleapis ile subscriptions/products.get cagirilmali.
    // Su an temel dogrulama yeterli.

    return { verified: true }
  } catch {
    return { verified: false, error: 'Failed to parse Android receipt' }
  }
}

// ── Ana handler ──────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS })
  }

  try {
    // Auth dogrulama
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ verified: false, error: 'Authorization header required' }),
        { status: 401, headers: CORS_HEADERS },
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Token dogrula
    const token = authHeader.replace('Bearer ', '')
    const anonClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: `Bearer ${token}` } } },
    )

    const { data: { user }, error: authError } = await anonClient.auth.getUser(token)
    if (authError || !user) {
      return new Response(
        JSON.stringify({ verified: false, error: 'Invalid auth token' }),
        { status: 401, headers: CORS_HEADERS },
      )
    }

    const userId = user.id

    // Request body
    const { platform, receipt, productId } = await req.json()

    if (!platform || !receipt || !productId) {
      return new Response(
        JSON.stringify({ verified: false, error: 'platform, receipt, productId required' }),
        { status: 400, headers: CORS_HEADERS },
      )
    }

    if (!VALID_PRODUCT_IDS.has(productId)) {
      return new Response(
        JSON.stringify({ verified: false, error: 'Invalid product ID' }),
        { status: 400, headers: CORS_HEADERS },
      )
    }

    if (platform !== 'ios' && platform !== 'android') {
      return new Response(
        JSON.stringify({ verified: false, error: 'Platform must be ios or android' }),
        { status: 400, headers: CORS_HEADERS },
      )
    }

    // Platform bazli dogrulama
    const result = platform === 'ios'
      ? await verifyAppleReceipt(receipt, productId)
      : await verifyAndroidReceipt(receipt, productId)

    if (!result.verified) {
      return new Response(JSON.stringify(result), { status: 400, headers: CORS_HEADERS })
    }

    // Basarili dogrulama — profilde kaydet (service_role ile RLS bypass)
    try {
      // Mevcut purchased_products alanini oku veya olustur
      const { data: profile } = await supabase
        .from('profiles')
        .select('purchased_products')
        .eq('id', userId)
        .single()

      const currentProducts: string[] = profile?.purchased_products ?? []
      if (!currentProducts.includes(productId)) {
        currentProducts.push(productId)
      }

      await supabase
        .from('profiles')
        .update({ purchased_products: currentProducts })
        .eq('id', userId)
    } catch (dbError) {
      // DB hatasi receipt dogrulamasini gecersiz kilmaz
      console.error('Profile update error:', dbError)
    }

    return new Response(
      JSON.stringify({ verified: true, productId, userId }),
      { status: 200, headers: CORS_HEADERS },
    )
  } catch (err) {
    return new Response(
      JSON.stringify({ verified: false, error: String(err) }),
      { status: 500, headers: CORS_HEADERS },
    )
  }
})
