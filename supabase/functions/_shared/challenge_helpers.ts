// Shared helpers for Challenge Edge Functions
//
// Import: import { ... } from '../_shared/challenge_helpers.ts'

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

// ── CORS ─────────────────────────────────────────────────────────────────────

export const CORS_HEADERS: Record<string, string> = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ── Response helpers ─────────────────────────────────────────────────────────

export function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), { status, headers: CORS_HEADERS })
}

export function errorResponse(message: string, status = 400): Response {
  return new Response(JSON.stringify({ error: message }), { status, headers: CORS_HEADERS })
}

// ── Supabase client ──────────────────────────────────────────────────────────

export function createServiceClient(): SupabaseClient {
  return createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  )
}

// ── Auth ─────────────────────────────────────────────────────────────────────

/**
 * Extracts and verifies user_id from JWT Authorization header.
 * Returns user_id on success, or an error Response.
 */
export async function getUserId(
  req: Request,
): Promise<{ userId: string } | { error: Response }> {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return { error: errorResponse('Authorization header required', 401) }
  }

  const token = authHeader.replace('Bearer ', '')
  const anonClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: `Bearer ${token}` } } },
  )

  const {
    data: { user },
    error: authError,
  } = await anonClient.auth.getUser(token)

  if (authError || !user) {
    return { error: errorResponse('Invalid auth token', 401) }
  }

  return { userId: user.id }
}

// ── Rate limiting (in-memory, per-isolate) ───────────────────────────────────

const rateLimitMap = new Map<string, { count: number; resetAt: number }>()

/**
 * Simple in-memory rate limiter. Returns true if request is allowed.
 * Note: Deno Deploy isolates are ephemeral, so this is best-effort.
 */
export function checkRateLimit(userId: string, maxPerMinute = 10): boolean {
  const now = Date.now()
  const entry = rateLimitMap.get(userId)

  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(userId, { count: 1, resetAt: now + 60_000 })
    return true
  }

  entry.count++
  if (entry.count > maxPerMinute) {
    return false
  }

  return true
}

// ── Reward constants ─────────────────────────────────────────────────────────

export const REWARDS = {
  winBase: 15,
  loseBase: 5,
  drawBase: 10,
  expireBase: 5,
  glooPlusBonusMultiplier: 1.5,
} as const

// ── Valid wager amounts ──────────────────────────────────────────────────────

export const VALID_WAGERS = new Set([0, 10, 25, 50])

// ── Valid challenge modes ────────────────────────────────────────────────────

export const VALID_MODES = new Set(['classic', 'colorChef', 'timeTrial'])
