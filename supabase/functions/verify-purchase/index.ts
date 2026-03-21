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

// ── Receipt hash — replay korumasi ──────────────────────────────────────────

async function computeReceiptHash(receipt: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(receipt)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map((b) => b.toString(16).padStart(2, '0')).join('')
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

// ── Google Play Developer API ────────────────────────────────────────────────

const GOOGLE_PLAY_API_BASE = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications'
const GOOGLE_TOKEN_URL = 'https://oauth2.googleapis.com/token'
const PACKAGE_NAME = 'com.gloogame.app'

// Subscription urun ID'leri — "gloo_plus" iceren urunler
const SUBSCRIPTION_PRODUCT_IDS = new Set([
  'gloo_plus_monthly',
  'gloo_plus_yearly',
])

/**
 * Google service account JSON'dan JWT olustur ve OAuth2 access token al.
 * Web Crypto API (crypto.subtle) kullanir — npm bagimliligi yok.
 */
async function getGoogleAccessToken(
  serviceAccountKey: { client_email: string; private_key: string },
): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  const header = { alg: 'RS256', typ: 'JWT' }
  const payload = {
    iss: serviceAccountKey.client_email,
    scope: 'https://www.googleapis.com/auth/androidpublisher',
    aud: GOOGLE_TOKEN_URL,
    iat: now,
    exp: now + 3600,
  }

  const encoder = new TextEncoder()

  const toBase64Url = (data: Uint8Array): string => {
    let binary = ''
    for (const byte of data) {
      binary += String.fromCharCode(byte)
    }
    return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
  }

  const headerB64 = toBase64Url(encoder.encode(JSON.stringify(header)))
  const payloadB64 = toBase64Url(encoder.encode(JSON.stringify(payload)))
  const unsignedToken = `${headerB64}.${payloadB64}`

  // PEM → binary DER
  const pemBody = serviceAccountKey.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/g, '')
    .replace(/-----END PRIVATE KEY-----/g, '')
    .replace(/\s/g, '')
  const binaryDer = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0))

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  )

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    encoder.encode(unsignedToken),
  )

  const signatureB64 = toBase64Url(new Uint8Array(signature))
  const jwt = `${unsignedToken}.${signatureB64}`

  // JWT → access token exchange
  const tokenResponse = await fetch(GOOGLE_TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  })

  if (!tokenResponse.ok) {
    const errText = await tokenResponse.text()
    throw new Error(`Google OAuth token exchange failed: ${tokenResponse.status} ${errText}`)
  }

  const tokenData = await tokenResponse.json()
  return tokenData.access_token
}

/**
 * Google Play Developer API ile tek seferlik urun (in-app product) dogrula.
 */
async function verifyGoogleProduct(
  accessToken: string,
  productId: string,
  purchaseToken: string,
  expectedOrderId: string,
): Promise<{ verified: boolean; error?: string }> {
  const url = `${GOOGLE_PLAY_API_BASE}/${PACKAGE_NAME}/purchases/products/${productId}/tokens/${purchaseToken}`

  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
  })

  if (!response.ok) {
    const errText = await response.text()
    return { verified: false, error: `Google Play API error: ${response.status} ${errText}` }
  }

  const data = await response.json()

  // purchaseState: 0 = purchased, 1 = canceled, 2 = pending
  if (data.purchaseState !== 0) {
    return { verified: false, error: `Invalid purchase state: ${data.purchaseState}` }
  }

  // orderId eslesmesi
  if (data.orderId !== expectedOrderId) {
    return { verified: false, error: `Order ID mismatch: expected ${expectedOrderId}, got ${data.orderId}` }
  }

  return { verified: true }
}

/**
 * Google Play Developer API ile abonelik (subscription) dogrula.
 */
async function verifyGoogleSubscription(
  accessToken: string,
  subscriptionId: string,
  purchaseToken: string,
  expectedOrderId: string,
): Promise<{ verified: boolean; error?: string }> {
  const url = `${GOOGLE_PLAY_API_BASE}/${PACKAGE_NAME}/purchases/subscriptions/${subscriptionId}/tokens/${purchaseToken}`

  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` },
  })

  if (!response.ok) {
    const errText = await response.text()
    return { verified: false, error: `Google Play API error: ${response.status} ${errText}` }
  }

  const data = await response.json()

  // paymentState: 0 = pending, 1 = received, 2 = free trial, 3 = deferred
  if (data.paymentState === undefined || (data.paymentState !== 1 && data.paymentState !== 2)) {
    return { verified: false, error: `Invalid payment state: ${data.paymentState}` }
  }

  // Abonelik suresi dolmus mu kontrol et
  const expiryMillis = parseInt(data.expiryTimeMillis, 10)
  if (isNaN(expiryMillis) || expiryMillis < Date.now()) {
    return { verified: false, error: 'Subscription expired' }
  }

  // orderId eslesmesi — aboneliklerde orderId sonuna ..0, ..1 gibi renewal suffix eklenir
  // Ilk satin alim icin tam eslesme, yenileme icin prefix eslesmesi kontrol edilir
  if (data.orderId !== expectedOrderId && !data.orderId?.startsWith(expectedOrderId + '..')) {
    return { verified: false, error: `Order ID mismatch: expected ${expectedOrderId}, got ${data.orderId}` }
  }

  return { verified: true }
}

// ── Android receipt dogrulama ────────────────────────────────────────────────

async function verifyAndroidReceipt(
  receipt: string,
  productId: string,
): Promise<{ verified: boolean; error?: string }> {
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

    // purchaseState: 0 = purchased (client-side on-kontrol)
    if (purchaseData.purchaseState !== undefined && purchaseData.purchaseState !== 0) {
      return { verified: false, error: `Invalid purchase state: ${purchaseData.purchaseState}` }
    }

    // ── Google Play Developer API ile sunucu tarafinda dogrulama ──
    const serviceAccountKeyJson = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_KEY')

    if (!serviceAccountKeyJson) {
      // Service account yoksa dogrulama yapilamaz — guvenlik geregi reddet
      console.error('GOOGLE_SERVICE_ACCOUNT_KEY not configured — cannot verify purchase')
      return { verified: false, error: 'Server configuration error: verification unavailable' }
    }

    let serviceAccountKey: { client_email: string; private_key: string }
    try {
      serviceAccountKey = JSON.parse(serviceAccountKeyJson)
    } catch {
      console.error('Failed to parse GOOGLE_SERVICE_ACCOUNT_KEY JSON')
      return { verified: false, error: 'Server configuration error: invalid credentials' }
    }

    if (!serviceAccountKey.client_email || !serviceAccountKey.private_key) {
      console.error('GOOGLE_SERVICE_ACCOUNT_KEY missing client_email or private_key')
      return { verified: false, error: 'Server configuration error: incomplete credentials' }
    }

    // Access token al
    const accessToken = await getGoogleAccessToken(serviceAccountKey)

    // Abonelik mi yoksa tek seferlik urun mu?
    if (SUBSCRIPTION_PRODUCT_IDS.has(productId)) {
      return await verifyGoogleSubscription(
        accessToken,
        productId,
        purchaseData.purchaseToken,
        purchaseData.orderId,
      )
    } else {
      return await verifyGoogleProduct(
        accessToken,
        productId,
        purchaseData.purchaseToken,
        purchaseData.orderId,
      )
    }
  } catch (err) {
    return { verified: false, error: `Android verification failed: ${String(err)}` }
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

    // Receipt replay korumasi: ayni receipt'in farkli hesaplardan kullanilmasini onle
    const receiptHash = await computeReceiptHash(receipt)
    const { data: existingUse } = await supabase
      .from('purchase_verifications')
      .select('user_id')
      .eq('receipt_hash', receiptHash)
      .eq('verified', true)
      .neq('user_id', userId)
      .limit(1)
      .maybeSingle()

    if (existingUse) {
      return new Response(
        JSON.stringify({ verified: false, error: 'Receipt already used by another account' }),
        { status: 400, headers: CORS_HEADERS },
      )
    }

    // Platform bazli dogrulama
    const result = platform === 'ios'
      ? await verifyAppleReceipt(receipt, productId)
      : await verifyAndroidReceipt(receipt, productId)

    // Audit log — purchase_verifications tablosuna kaydet
    try {
      await supabase.from('purchase_verifications').insert({
        user_id: userId,
        platform,
        product_id: productId,
        receipt_hash: receiptHash,
        verified: result.verified,
        error: result.error ?? null,
        created_at: new Date().toISOString(),
      })
    } catch (auditErr) {
      console.error('Audit log error:', auditErr)
    }

    if (!result.verified) {
      return new Response(JSON.stringify(result), { status: 400, headers: CORS_HEADERS })
    }

    // Basarili dogrulama — profilde kaydet (atomic RPC ile race condition onlenir)
    try {
      await supabase.rpc('append_purchased_product', {
        p_user_id: userId,
        p_product_id: productId,
      })
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
