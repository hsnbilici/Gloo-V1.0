# CD.27c Challenge/Invite System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a hybrid challenge system (async Score Battle + sync Live Duel Phase 2) enabling mutual friends to challenge each other with optional Jel Ozu wagers, server-authoritative via Edge Functions.

**Architecture:** Server-authoritative mutations via Supabase Edge Functions (no direct client INSERT/UPDATE on challenges table). Client reads through `challenges_safe` view that hides seed/score until appropriate status. Balance ledger table for wager escrow. Riverpod providers for state, route params for game integration.

**Tech Stack:** Flutter 3.41+, Dart, Supabase (PostgreSQL + Edge Functions + Realtime), Riverpod, GoRouter

**Spec:** `docs/superpowers/specs/2026-03-25-cd27c-challenge-invite-design.md`

---

## Task 1: Supabase Migration — challenges + balances tables

**Files:**
- Create: `supabase/migrations/20260325_create_challenges.sql`

- [ ] **Step 1: Write migration SQL**

```sql
-- challenges table
CREATE TABLE IF NOT EXISTS challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES profiles(id),
  recipient_id UUID REFERENCES profiles(id),
  mode TEXT NOT NULL,
  challenge_type TEXT NOT NULL DEFAULT 'score_battle',
  seed INTEGER NOT NULL,
  wager INTEGER NOT NULL DEFAULT 0,
  sender_score INTEGER,
  recipient_score INTEGER,
  status TEXT NOT NULL DEFAULT 'pending',
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  accepted_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY challenges_select ON challenges FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

CREATE INDEX idx_challenges_recipient_status ON challenges(recipient_id, status);
CREATE INDEX idx_challenges_sender_status ON challenges(sender_id, status);
CREATE INDEX idx_challenges_sender_daily ON challenges(sender_id, created_at);
CREATE INDEX idx_challenges_expires_at ON challenges(expires_at) WHERE status IN ('pending', 'active');

-- challenges_safe view: hides seed + sender_score until appropriate status
CREATE OR REPLACE VIEW challenges_safe AS
  SELECT
    c.id, c.sender_id, c.recipient_id, c.mode, c.challenge_type,
    CASE
      WHEN auth.uid() = c.sender_id THEN c.seed
      WHEN c.status IN ('active', 'completed') THEN c.seed
      ELSE NULL
    END AS seed,
    c.wager,
    CASE
      WHEN auth.uid() = c.sender_id THEN c.sender_score
      WHEN c.status = 'completed' THEN c.sender_score
      ELSE NULL
    END AS sender_score,
    c.recipient_score, c.status,
    c.expires_at, c.created_at, c.accepted_at, c.completed_at,
    sp.username AS sender_username,
    rp.username AS recipient_username
  FROM challenges c
  LEFT JOIN profiles sp ON sp.id = c.sender_id
  LEFT JOIN profiles rp ON rp.id = c.recipient_id;

-- balances table (server-authoritative for wager escrow)
CREATE TABLE IF NOT EXISTS balances (
  user_id UUID PRIMARY KEY REFERENCES profiles(id),
  gel_ozu INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE balances ENABLE ROW LEVEL SECURITY;

CREATE POLICY balances_select ON balances FOR SELECT
  USING (auth.uid() = user_id);
```

- [ ] **Step 2: Apply migration**

Run: `cd supabase && supabase db push` or apply via Supabase MCP tool.
Expected: Tables and view created successfully.

- [ ] **Step 3: Verify via SQL**

```sql
SELECT * FROM challenges LIMIT 0;
SELECT * FROM balances LIMIT 0;
SELECT * FROM challenges_safe LIMIT 0;
```
Expected: Empty results, no errors.

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260325_create_challenges.sql
git commit -m "feat(challenge): add challenges + balances tables with RLS and safe view"
```

---

## Task 2: Dart Models — Challenge, ChallengeResult, enums

**Files:**
- Create: `lib/core/models/challenge.dart`
- Create: `test/challenge/challenge_model_test.dart`

- [ ] **Step 1: Write model tests**

```dart
// test/challenge/challenge_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/models/challenge.dart';

void main() {
  group('ChallengeType', () {
    test('fromString parses score_battle', () {
      expect(ChallengeType.fromString('score_battle'), ChallengeType.scoreBattle);
    });
    test('fromString parses live_duel', () {
      expect(ChallengeType.fromString('live_duel'), ChallengeType.liveDuel);
    });
    test('fromString defaults to scoreBattle', () {
      expect(ChallengeType.fromString('unknown'), ChallengeType.scoreBattle);
    });
    test('toDbString round-trips', () {
      for (final t in ChallengeType.values) {
        expect(ChallengeType.fromString(t.toDbString()), t);
      }
    });
  });

  group('ChallengeStatus', () {
    test('fromString parses all values', () {
      for (final s in ChallengeStatus.values) {
        expect(ChallengeStatus.fromString(s.name), s);
      }
    });
    test('fromString defaults to pending', () {
      expect(ChallengeStatus.fromString('garbage'), ChallengeStatus.pending);
    });
  });

  group('Challenge.fromMap', () {
    test('parses full challenge', () {
      final map = {
        'id': 'abc-123',
        'sender_id': 'user-1',
        'recipient_id': 'user-2',
        'sender_username': 'alice',
        'recipient_username': 'bob',
        'mode': 'classic',
        'challenge_type': 'score_battle',
        'seed': 42,
        'wager': 25,
        'sender_score': 1500,
        'recipient_score': null,
        'status': 'active',
        'expires_at': '2026-03-26T12:00:00Z',
        'created_at': '2026-03-25T12:00:00Z',
        'accepted_at': '2026-03-25T13:00:00Z',
        'completed_at': null,
      };
      final c = Challenge.fromMap(map);
      expect(c.id, 'abc-123');
      expect(c.senderId, 'user-1');
      expect(c.recipientId, 'user-2');
      expect(c.senderUsername, 'alice');
      expect(c.recipientUsername, 'bob');
      expect(c.mode.name, 'classic');
      expect(c.type, ChallengeType.scoreBattle);
      expect(c.seed, 42);
      expect(c.wager, 25);
      expect(c.senderScore, 1500);
      expect(c.recipientScore, isNull);
      expect(c.status, ChallengeStatus.active);
    });

    test('handles null seed (hidden from recipient)', () {
      final map = {
        'id': 'abc-123',
        'sender_id': 'user-1',
        'recipient_id': 'user-2',
        'sender_username': 'alice',
        'recipient_username': null,
        'mode': 'timeTrial',
        'challenge_type': 'score_battle',
        'seed': null,
        'wager': 0,
        'sender_score': null,
        'recipient_score': null,
        'status': 'pending',
        'expires_at': '2026-03-26T12:00:00Z',
        'created_at': '2026-03-25T12:00:00Z',
        'accepted_at': null,
        'completed_at': null,
      };
      final c = Challenge.fromMap(map);
      expect(c.seed, isNull);
      expect(c.recipientUsername, isNull);
    });
  });

  group('ChallengeResult.fromMap', () {
    test('parses win result', () {
      final map = {
        'outcome': 'win',
        'sender_score': 1200,
        'recipient_score': 1500,
        'gel_reward': 15,
      };
      final r = ChallengeResult.fromMap(map);
      expect(r.outcome, ChallengeOutcome.win);
      expect(r.senderScore, 1200);
      expect(r.recipientScore, 1500);
      expect(r.gelReward, 15);
    });
  });

  group('Challenge.isExpired', () {
    test('returns true for past expires_at', () {
      final c = Challenge(
        id: 'x', senderId: 's', recipientId: null,
        senderUsername: 'a', recipientUsername: null,
        mode: GameMode.classic, type: ChallengeType.scoreBattle,
        seed: null, wager: 0, senderScore: null, recipientScore: null,
        status: ChallengeStatus.pending,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
      );
      expect(c.isExpired, true);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/challenge/challenge_model_test.dart`
Expected: Compilation errors — Challenge class doesn't exist yet.

- [ ] **Step 3: Implement models**

```dart
// lib/core/models/challenge.dart
import 'package:gloo/core/models/game_mode.dart';

enum ChallengeType {
  scoreBattle,
  liveDuel;

  static ChallengeType fromString(String s) => switch (s) {
    'score_battle' => scoreBattle,
    'live_duel' => liveDuel,
    _ => scoreBattle,
  };

  String toDbString() => switch (this) {
    scoreBattle => 'score_battle',
    liveDuel => 'live_duel',
  };
}

enum ChallengeStatus {
  pending,
  active,
  completed,
  expired,
  declined,
  cancelled;

  static ChallengeStatus fromString(String s) {
    for (final v in values) {
      if (v.name == s) return v;
    }
    return pending;
  }
}

enum ChallengeOutcome {
  win,
  loss,
  draw;

  static ChallengeOutcome fromString(String s) => switch (s) {
    'win' => win,
    'loss' => loss,
    'draw' => draw,
    _ => draw,
  };
}

class Challenge {
  const Challenge({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.senderUsername,
    required this.recipientUsername,
    required this.mode,
    required this.type,
    required this.seed,
    required this.wager,
    required this.senderScore,
    required this.recipientScore,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String? recipientId;
  final String senderUsername;
  final String? recipientUsername;
  final GameMode mode;
  final ChallengeType type;
  final int? seed;
  final int wager;
  final int? senderScore;
  final int? recipientScore;
  final ChallengeStatus status;
  final DateTime expiresAt;
  final DateTime createdAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get hasWager => wager > 0;

  Duration get timeRemaining {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      recipientId: map['recipient_id'] as String?,
      senderUsername: map['sender_username'] as String? ?? '',
      recipientUsername: map['recipient_username'] as String?,
      mode: GameMode.fromString(map['mode'] as String? ?? 'classic'),
      type: ChallengeType.fromString(map['challenge_type'] as String? ?? 'score_battle'),
      seed: map['seed'] as int?,
      wager: map['wager'] as int? ?? 0,
      senderScore: map['sender_score'] as int?,
      recipientScore: map['recipient_score'] as int?,
      status: ChallengeStatus.fromString(map['status'] as String? ?? 'pending'),
      expiresAt: DateTime.parse(map['expires_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class ChallengeResult {
  const ChallengeResult({
    required this.outcome,
    required this.senderScore,
    required this.recipientScore,
    required this.gelReward,
  });

  final ChallengeOutcome outcome;
  final int senderScore;
  final int recipientScore;
  final int gelReward;

  factory ChallengeResult.fromMap(Map<String, dynamic> map) {
    return ChallengeResult(
      outcome: ChallengeOutcome.fromString(map['outcome'] as String? ?? 'draw'),
      senderScore: map['sender_score'] as int? ?? 0,
      recipientScore: map['recipient_score'] as int? ?? 0,
      gelReward: map['gel_reward'] as int? ?? 0,
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/challenge/challenge_model_test.dart`
Expected: All tests PASS.

- [ ] **Step 5: Run analyze**

Run: `flutter analyze lib/core/models/challenge.dart`
Expected: 0 issues.

- [ ] **Step 6: Commit**

```bash
git add lib/core/models/challenge.dart test/challenge/challenge_model_test.dart
git commit -m "feat(challenge): add Challenge, ChallengeResult models with enums and tests"
```

---

## Task 3: Edge Functions — create-challenge + accept-challenge + decline-challenge + cancel-challenge + submit-challenge-score + claim-deep-link-challenge

**Files:**
- Create: `supabase/functions/create-challenge/index.ts`
- Create: `supabase/functions/accept-challenge/index.ts`
- Create: `supabase/functions/decline-challenge/index.ts`
- Create: `supabase/functions/cancel-challenge/index.ts`
- Create: `supabase/functions/submit-challenge-score/index.ts`
- Create: `supabase/functions/claim-deep-link-challenge/index.ts`

Reference: `supabase/functions/verify-purchase/index.ts` for pattern (Deno, createClient, service_role).

- [ ] **Step 1: Create shared helper**

Create `supabase/functions/_shared/challenge_helpers.ts`:

```typescript
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2'

export function createServiceClient(): SupabaseClient {
  return createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )
}

export function getUserId(req: Request): string | null {
  const authHeader = req.headers.get('authorization')
  if (!authHeader) return null
  // Decode JWT to get sub claim
  const token = authHeader.replace('Bearer ', '')
  try {
    const payload = JSON.parse(atob(token.split('.')[1]))
    return payload.sub || null
  } catch {
    return null
  }
}

export function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }
}

export function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
  })
}

export function errorResponse(message: string, status = 400) {
  return jsonResponse({ error: message }, status)
}

// Rate limiting: simple in-memory (resets on cold start, sufficient for casual game)
const rateLimits = new Map<string, { count: number; resetAt: number }>()

export function checkRateLimit(userId: string, maxPerMinute = 10): boolean {
  const now = Date.now()
  const entry = rateLimits.get(userId)
  if (!entry || now > entry.resetAt) {
    rateLimits.set(userId, { count: 1, resetAt: now + 60000 })
    return true
  }
  if (entry.count >= maxPerMinute) return false
  entry.count++
  return true
}

// Challenge reward constants
export const REWARDS = {
  winBase: 15,
  loseBase: 5,
  drawBase: 10,
  expireBase: 5,
  glooPlusBonusMultiplier: 1.5,
}
```

- [ ] **Step 2: Create create-challenge Edge Function**

```typescript
// supabase/functions/create-challenge/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createServiceClient, getUserId, jsonResponse, errorResponse, checkRateLimit, corsHeaders } from '../_shared/challenge_helpers.ts'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders() })
  if (req.method !== 'POST') return errorResponse('Method not allowed', 405)

  const userId = getUserId(req)
  if (!userId) return errorResponse('Unauthorized', 401)
  if (!checkRateLimit(userId)) return errorResponse('Rate limit exceeded', 429)

  const { recipientId, mode, challengeType, senderScore, wager, clientBalance } = await req.json()

  // Validate inputs
  if (!mode || !['classic', 'colorChef', 'timeTrial'].includes(mode)) {
    return errorResponse('Invalid mode')
  }
  if (senderScore == null || typeof senderScore !== 'number') {
    return errorResponse('Invalid sender score')
  }
  const validWagers = [0, 10, 25, 50]
  if (!validWagers.includes(wager ?? 0)) {
    return errorResponse('Invalid wager amount')
  }

  const db = createServiceClient()

  // Check daily limit
  const { data: profile } = await db
    .from('profiles')
    .select('id')
    .eq('id', userId)
    .single()
  if (!profile) return errorResponse('Profile not found', 404)

  // Check if user has Gloo+ (from audio_settings or app_settings)
  const { data: settings } = await db
    .from('profiles')
    .select('gloo_plus')
    .eq('id', userId)
    .single()
  const isGlooPlus = settings?.gloo_plus ?? false
  const dailyLimit = isGlooPlus ? 20 : 5

  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const tomorrow = new Date(today)
  tomorrow.setDate(tomorrow.getDate() + 1)

  const { count: dailyCount } = await db
    .from('challenges')
    .select('id', { count: 'exact', head: true })
    .eq('sender_id', userId)
    .gte('created_at', today.toISOString())
    .lt('created_at', tomorrow.toISOString())

  if ((dailyCount ?? 0) >= dailyLimit) {
    return errorResponse('Daily challenge limit reached')
  }

  // Wager escrow (server-side balance)
  const effectiveWager = wager ?? 0
  if (effectiveWager > 0) {
    // Upsert balance row (first-time migration from client)
    await db.from('balances').upsert(
      { user_id: userId, gel_ozu: clientBalance ?? 0, updated_at: new Date().toISOString() },
      { onConflict: 'user_id', ignoreDuplicates: true }
    )

    const { data: balance } = await db
      .from('balances')
      .select('gel_ozu')
      .eq('user_id', userId)
      .single()

    if (!balance || balance.gel_ozu < effectiveWager) {
      return errorResponse('Insufficient balance for wager')
    }

    // Deduct wager atomically
    const { error: deductError } = await db.rpc('deduct_balance', {
      p_user_id: userId,
      p_amount: effectiveWager,
    })
    if (deductError) return errorResponse('Failed to deduct wager')
  }

  // Generate seed server-side
  const seed = Math.floor(Math.random() * 2147483647)

  // Create challenge
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()

  const { data: challenge, error: insertError } = await db
    .from('challenges')
    .insert({
      sender_id: userId,
      recipient_id: recipientId || null,
      mode,
      challenge_type: challengeType ?? 'score_battle',
      seed,
      wager: effectiveWager,
      sender_score: senderScore,
      status: 'pending',
      expires_at: expiresAt,
    })
    .select('id')
    .single()

  if (insertError) {
    // Refund wager on failure
    if (effectiveWager > 0) {
      await db.rpc('credit_balance', { p_user_id: userId, p_amount: effectiveWager })
    }
    return errorResponse('Failed to create challenge')
  }

  // Get updated balance
  const { data: newBalance } = await db
    .from('balances')
    .select('gel_ozu')
    .eq('user_id', userId)
    .single()

  return jsonResponse({
    challengeId: challenge.id,
    balance: newBalance?.gel_ozu,
  })
})
```

- [ ] **Step 3: Create balance RPC helpers in migration**

Add to migration file `supabase/migrations/20260325_create_challenges.sql`:

```sql
-- Atomic balance operations
CREATE OR REPLACE FUNCTION deduct_balance(p_user_id UUID, p_amount INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE balances
  SET gel_ozu = gel_ozu - p_amount, updated_at = now()
  WHERE user_id = p_user_id AND gel_ozu >= p_amount;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Insufficient balance';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION credit_balance(p_user_id UUID, p_amount INTEGER)
RETURNS VOID AS $$
BEGIN
  INSERT INTO balances (user_id, gel_ozu, updated_at)
  VALUES (p_user_id, p_amount, now())
  ON CONFLICT (user_id) DO UPDATE
  SET gel_ozu = balances.gel_ozu + p_amount, updated_at = now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

- [ ] **Step 4: Create accept-challenge Edge Function**

```typescript
// supabase/functions/accept-challenge/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createServiceClient, getUserId, jsonResponse, errorResponse, checkRateLimit, corsHeaders } from '../_shared/challenge_helpers.ts'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders() })
  if (req.method !== 'POST') return errorResponse('Method not allowed', 405)

  const userId = getUserId(req)
  if (!userId) return errorResponse('Unauthorized', 401)
  if (!checkRateLimit(userId)) return errorResponse('Rate limit exceeded', 429)

  const { challengeId, clientBalance } = await req.json()
  if (!challengeId) return errorResponse('Missing challengeId')

  const db = createServiceClient()

  // Fetch challenge
  const { data: challenge, error } = await db
    .from('challenges')
    .select('*')
    .eq('id', challengeId)
    .single()

  if (error || !challenge) return errorResponse('Challenge not found', 404)
  if (challenge.status !== 'pending') return errorResponse('Challenge is not pending')
  if (challenge.recipient_id && challenge.recipient_id !== userId) {
    return errorResponse('Not the intended recipient')
  }
  if (challenge.sender_id === userId) return errorResponse('Cannot accept own challenge')
  if (new Date(challenge.expires_at) < new Date()) return errorResponse('Challenge expired')

  // Wager escrow for recipient
  if (challenge.wager > 0) {
    await db.from('balances').upsert(
      { user_id: userId, gel_ozu: clientBalance ?? 0, updated_at: new Date().toISOString() },
      { onConflict: 'user_id', ignoreDuplicates: true }
    )

    const { data: balance } = await db
      .from('balances')
      .select('gel_ozu')
      .eq('user_id', userId)
      .single()

    if (!balance || balance.gel_ozu < challenge.wager) {
      return errorResponse('Insufficient balance for wager')
    }

    const { error: deductError } = await db.rpc('deduct_balance', {
      p_user_id: userId,
      p_amount: challenge.wager,
    })
    if (deductError) return errorResponse('Failed to deduct wager')
  }

  // Update challenge status
  const { error: updateError } = await db
    .from('challenges')
    .update({
      recipient_id: userId,
      status: 'active',
      accepted_at: new Date().toISOString(),
    })
    .eq('id', challengeId)
    .eq('status', 'pending')

  if (updateError) {
    // Refund on failure
    if (challenge.wager > 0) {
      await db.rpc('credit_balance', { p_user_id: userId, p_amount: challenge.wager })
    }
    return errorResponse('Failed to accept challenge')
  }

  // Get updated balance
  const { data: newBalance } = await db
    .from('balances')
    .select('gel_ozu')
    .eq('user_id', userId)
    .single()

  return jsonResponse({
    challenge: {
      ...challenge,
      recipient_id: userId,
      status: 'active',
      accepted_at: new Date().toISOString(),
    },
    balance: newBalance?.gel_ozu,
  })
})
```

- [ ] **Step 5: Create decline-challenge Edge Function**

```typescript
// supabase/functions/decline-challenge/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createServiceClient, getUserId, jsonResponse, errorResponse, corsHeaders } from '../_shared/challenge_helpers.ts'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders() })
  if (req.method !== 'POST') return errorResponse('Method not allowed', 405)

  const userId = getUserId(req)
  if (!userId) return errorResponse('Unauthorized', 401)

  const { challengeId } = await req.json()
  if (!challengeId) return errorResponse('Missing challengeId')

  const db = createServiceClient()

  const { data: challenge } = await db
    .from('challenges')
    .select('*')
    .eq('id', challengeId)
    .single()

  if (!challenge) return errorResponse('Challenge not found', 404)
  if (challenge.status !== 'pending') return errorResponse('Challenge is not pending')
  if (challenge.recipient_id && challenge.recipient_id !== userId) {
    return errorResponse('Not the intended recipient')
  }

  // Refund sender wager
  if (challenge.wager > 0) {
    await db.rpc('credit_balance', {
      p_user_id: challenge.sender_id,
      p_amount: challenge.wager,
    })
  }

  await db
    .from('challenges')
    .update({ status: 'declined', completed_at: new Date().toISOString() })
    .eq('id', challengeId)

  return jsonResponse({ success: true })
})
```

- [ ] **Step 6: Create cancel-challenge Edge Function**

```typescript
// supabase/functions/cancel-challenge/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createServiceClient, getUserId, jsonResponse, errorResponse, corsHeaders } from '../_shared/challenge_helpers.ts'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders() })
  if (req.method !== 'POST') return errorResponse('Method not allowed', 405)

  const userId = getUserId(req)
  if (!userId) return errorResponse('Unauthorized', 401)

  const { challengeId } = await req.json()
  if (!challengeId) return errorResponse('Missing challengeId')

  const db = createServiceClient()

  const { data: challenge } = await db
    .from('challenges')
    .select('*')
    .eq('id', challengeId)
    .single()

  if (!challenge) return errorResponse('Challenge not found', 404)
  if (challenge.sender_id !== userId) return errorResponse('Only sender can cancel')
  if (challenge.status !== 'pending') return errorResponse('Can only cancel pending challenges')

  // Refund sender wager
  if (challenge.wager > 0) {
    await db.rpc('credit_balance', {
      p_user_id: userId,
      p_amount: challenge.wager,
    })
  }

  await db
    .from('challenges')
    .update({ status: 'cancelled', completed_at: new Date().toISOString() })
    .eq('id', challengeId)

  return jsonResponse({ success: true })
})
```

- [ ] **Step 7: Create submit-challenge-score Edge Function**

```typescript
// supabase/functions/submit-challenge-score/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createServiceClient, getUserId, jsonResponse, errorResponse, corsHeaders, REWARDS } from '../_shared/challenge_helpers.ts'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders() })
  if (req.method !== 'POST') return errorResponse('Method not allowed', 405)

  const userId = getUserId(req)
  if (!userId) return errorResponse('Unauthorized', 401)

  const { challengeId, score } = await req.json()
  if (!challengeId || score == null) return errorResponse('Missing params')

  const db = createServiceClient()

  const { data: challenge } = await db
    .from('challenges')
    .select('*')
    .eq('id', challengeId)
    .single()

  if (!challenge) return errorResponse('Challenge not found', 404)
  if (challenge.recipient_id !== userId) return errorResponse('Only recipient can submit score')
  if (challenge.status !== 'active') return errorResponse('Challenge is not active')
  if (challenge.recipient_score != null) return errorResponse('Score already submitted')

  // Determine winner
  const senderScore = challenge.sender_score
  const recipientScore = score
  let outcome: string
  let senderReward: number
  let recipientReward: number

  if (recipientScore > senderScore) {
    outcome = 'win' // recipient wins
    if (challenge.wager > 0) {
      recipientReward = challenge.wager * 2
      senderReward = 0
    } else {
      recipientReward = REWARDS.winBase
      senderReward = REWARDS.loseBase
    }
  } else if (recipientScore < senderScore) {
    outcome = 'loss' // recipient loses
    if (challenge.wager > 0) {
      senderReward = challenge.wager * 2
      recipientReward = 0
    } else {
      senderReward = REWARDS.winBase
      recipientReward = REWARDS.loseBase
    }
  } else {
    outcome = 'draw'
    if (challenge.wager > 0) {
      // Refund wagers + draw bonus
      senderReward = challenge.wager + REWARDS.drawBase
      recipientReward = challenge.wager + REWARDS.drawBase
    } else {
      senderReward = REWARDS.drawBase
      recipientReward = REWARDS.drawBase
    }
  }

  // Check Gloo+ for bonus
  const { data: senderProfile } = await db.from('profiles').select('gloo_plus').eq('id', challenge.sender_id).single()
  const { data: recipientProfile } = await db.from('profiles').select('gloo_plus').eq('id', userId).single()

  if (senderProfile?.gloo_plus && senderReward > 0) {
    senderReward = Math.floor(senderReward * REWARDS.glooPlusBonusMultiplier)
  }
  if (recipientProfile?.gloo_plus && recipientReward > 0) {
    recipientReward = Math.floor(recipientReward * REWARDS.glooPlusBonusMultiplier)
  }

  // Distribute rewards
  if (senderReward > 0) {
    await db.rpc('credit_balance', { p_user_id: challenge.sender_id, p_amount: senderReward })
  }
  if (recipientReward > 0) {
    await db.rpc('credit_balance', { p_user_id: userId, p_amount: recipientReward })
  }

  // Update challenge
  await db
    .from('challenges')
    .update({
      recipient_score: recipientScore,
      status: 'completed',
      completed_at: new Date().toISOString(),
    })
    .eq('id', challengeId)

  // Get updated recipient balance
  const { data: newBalance } = await db.from('balances').select('gel_ozu').eq('user_id', userId).single()

  return jsonResponse({
    outcome,
    sender_score: senderScore,
    recipient_score: recipientScore,
    gel_reward: recipientReward,
    balance: newBalance?.gel_ozu,
  })
})
```

- [ ] **Step 8: Create claim-deep-link-challenge Edge Function**

```typescript
// supabase/functions/claim-deep-link-challenge/index.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createServiceClient, getUserId, jsonResponse, errorResponse, corsHeaders } from '../_shared/challenge_helpers.ts'

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders() })
  if (req.method !== 'POST') return errorResponse('Method not allowed', 405)

  const userId = getUserId(req)
  if (!userId) return errorResponse('Unauthorized', 401)

  const { challengeId } = await req.json()
  if (!challengeId) return errorResponse('Missing challengeId')

  const db = createServiceClient()

  const { data: challenge } = await db
    .from('challenges')
    .select('*')
    .eq('id', challengeId)
    .single()

  if (!challenge) return errorResponse('Challenge not found', 404)
  if (challenge.recipient_id != null) return errorResponse('Challenge already claimed')
  if (challenge.status !== 'pending') return errorResponse('Challenge is not pending')
  if (challenge.sender_id === userId) return errorResponse('Cannot claim own challenge')
  if (new Date(challenge.expires_at) < new Date()) return errorResponse('Challenge expired')

  // Deep link challenges have no wager
  await db
    .from('challenges')
    .update({
      recipient_id: userId,
      status: 'active',
      accepted_at: new Date().toISOString(),
    })
    .eq('id', challengeId)

  return jsonResponse({
    challenge: {
      ...challenge,
      recipient_id: userId,
      status: 'active',
      accepted_at: new Date().toISOString(),
    },
  })
})
```

- [ ] **Step 9: Deploy Edge Functions**

Run: `supabase functions deploy create-challenge accept-challenge decline-challenge cancel-challenge submit-challenge-score claim-deep-link-challenge`
Expected: All functions deployed successfully.

- [ ] **Step 10: Commit**

```bash
git add supabase/functions/ supabase/migrations/
git commit -m "feat(challenge): add 6 Edge Functions for server-authoritative challenge mutations"
```

---

## Task 4: ChallengeRepository — Dart client for Edge Functions

**Files:**
- Create: `lib/data/remote/challenge_repository.dart`
- Create: `test/challenge/challenge_repository_test.dart`

- [ ] **Step 1: Write repository tests**

```dart
// test/challenge/challenge_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/models/challenge.dart';
import 'package:gloo/data/remote/challenge_repository.dart';

void main() {
  // Unit tests for parsing logic (not integration — EF calls are mocked in widget tests)
  group('ChallengeRepository parsing', () {
    test('parseChallenge handles full map', () {
      final map = {
        'id': 'abc', 'sender_id': 'u1', 'recipient_id': 'u2',
        'sender_username': 'alice', 'recipient_username': 'bob',
        'mode': 'classic', 'challenge_type': 'score_battle',
        'seed': 42, 'wager': 25, 'sender_score': 1500,
        'recipient_score': null, 'status': 'pending',
        'expires_at': '2026-03-26T00:00:00Z', 'created_at': '2026-03-25T00:00:00Z',
        'accepted_at': null, 'completed_at': null,
      };
      final c = Challenge.fromMap(map);
      expect(c.id, 'abc');
      expect(c.wager, 25);
      expect(c.status, ChallengeStatus.pending);
    });

    test('parseChallengeResult handles win', () {
      final map = {'outcome': 'win', 'sender_score': 100, 'recipient_score': 200, 'gel_reward': 15};
      final r = ChallengeResult.fromMap(map);
      expect(r.outcome, ChallengeOutcome.win);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify pass (parsing tests reuse model)**

Run: `flutter test test/challenge/challenge_repository_test.dart`
Expected: All tests PASS.

- [ ] **Step 3: Implement ChallengeRepository**

Create `lib/data/remote/challenge_repository.dart` following the `FriendRepository` pattern:
- `isConfigured` guard on every method
- Try-catch with `kDebugMode` logging
- Edge Function calls via `SupabaseConfig.client.functions.invoke()`
- Read queries via `challenges_safe` view
- `_retry()` for score submission

Key methods:
- `createChallenge()` → invoke `create-challenge` EF
- `acceptChallenge()` → invoke `accept-challenge` EF
- `declineChallenge()` → invoke `decline-challenge` EF
- `cancelChallenge()` → invoke `cancel-challenge` EF
- `submitRecipientScore()` → invoke `submit-challenge-score` EF with `_retry()`
- `claimDeepLinkChallenge()` → invoke `claim-deep-link-challenge` EF
- `getPendingChallenges()` → SELECT from `challenges_safe` WHERE recipient_id = me AND status = 'pending'
- `getSentChallenges()` → SELECT from `challenges_safe` WHERE sender_id = me AND status IN ('pending', 'active')
- `getChallengeHistory()` → SELECT from `challenges_safe` WHERE (sender_id = me OR recipient_id = me) AND status IN ('completed', 'expired', 'declined', 'cancelled') ORDER BY completed_at DESC LIMIT limit
- `getDailyChallengeCount()` → COUNT from `challenges_safe` WHERE sender_id = me AND created_at >= today

- [ ] **Step 4: Run analyze**

Run: `flutter analyze lib/data/remote/challenge_repository.dart`
Expected: 0 issues.

- [ ] **Step 5: Commit**

```bash
git add lib/data/remote/challenge_repository.dart test/challenge/challenge_repository_test.dart
git commit -m "feat(challenge): add ChallengeRepository with EF calls and read queries"
```

---

## Task 5: ChallengeProvider — Riverpod state management

**Files:**
- Create: `lib/providers/challenge_provider.dart`
- Create: `test/challenge/challenge_provider_test.dart`

- [ ] **Step 1: Write provider tests**

Test ChallengeState computed properties, ChallengeNotifier methods with mocked repository.

- [ ] **Step 2: Implement ChallengeProvider**

Following `friend_provider.dart` pattern:
- `challengeRepositoryProvider` — Provider factory
- `challengeProvider` — StateNotifierProvider<ChallengeNotifier, ChallengeState>
- `pendingChallengeCountProvider` — derived Provider<int>
- ChallengeState: received, sent, pendingCount, dailySentCount
- ChallengeNotifier: loadChallenges, sendChallenge, acceptChallenge, declineChallenge, cancelChallenge, submitScore, claimDeepLink, refresh

- [ ] **Step 3: Run tests**

Run: `flutter test test/challenge/challenge_provider_test.dart`
Expected: All tests PASS.

- [ ] **Step 4: Run analyze**

Run: `flutter analyze lib/providers/challenge_provider.dart`
Expected: 0 issues.

- [ ] **Step 5: Commit**

```bash
git add lib/providers/challenge_provider.dart test/challenge/challenge_provider_test.dart
git commit -m "feat(challenge): add ChallengeProvider with state management"
```

---

## Task 6: l10n — Add ~30 challenge strings to all 12 languages

**Files:**
- Modify: `lib/core/l10n/app_strings.dart` — add abstract getters
- Modify: `lib/core/l10n/strings_en.dart` through `strings_pt.dart` — add implementations

- [ ] **Step 1: Add abstract getters to app_strings.dart**

Add challenge string getters (challengeSend, challengeAccept, challengeDecline, challengeWagerConfirm, challengePending, challengeActive, challengeCompleted, challengeExpired, challengeDeclined, challengeYouWon, challengeYouLost, challengeDraw, challengeRematch, challengeBannerSingle, challengeBannerMultiple, challengeDailyLimitReached, challengePlayAndSend, challengeModePick, challengeWagerPick, challengeRevealScore, challengeClaimSuccess, challengeClaimExpired, challengeClaimAlreadyClaimed, challengeCancelled, challengeTab, challengeNoActive, challengeTimeRemaining with interpolation).

- [ ] **Step 2: Implement in all 12 strings_*.dart files**

Start with `strings_en.dart`, then `strings_tr.dart`, then remaining 10.

- [ ] **Step 3: Run analyze to catch missing overrides**

Run: `flutter analyze`
Expected: 0 issues (all abstract getters implemented in all 12 files).

- [ ] **Step 4: Commit**

```bash
git add lib/core/l10n/
git commit -m "feat(challenge): add ~30 l10n strings for challenge system in 12 languages"
```

---

## Task 7: Color constants + UI constants

**Files:**
- Modify: `lib/core/constants/color_constants.dart` — add kChallengePrimary, kChallengeWin, kChallengeLose
- Modify: `lib/core/constants/color_constants_light.dart` — add light variants

- [ ] **Step 1: Add color constants**

In `color_constants.dart`:
```dart
const Color kChallengePrimary = Color(0xFFE67E22); // warm orange, distinct from kAmber
const Color kChallengeWin = kGreen;
const Color kChallengeLose = kMuted;
```

In `color_constants_light.dart`:
```dart
const Color kChallengePrimaryLight = Color(0xFFD35400); // WCAG AA on white
const Color kChallengeWinLight = kGreenLight;
const Color kChallengeLoseLight = kMutedLight;
```

- [ ] **Step 2: Run analyze**

Run: `flutter analyze lib/core/constants/`
Expected: 0 issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/
git commit -m "feat(challenge): add challenge color constants with WCAG AA compliance"
```

---

## Task 8: Router — Add challenge routes

**Files:**
- Modify: `lib/app/router.dart` — add /game/challenge, /challenges, /challenge/:challengeId routes

- [ ] **Step 1: Add routes to router.dart**

Add before `/game/duel`:
```dart
GoRoute(
  path: '/game/challenge',
  builder: (context, state) {
    final challengeId = state.uri.queryParameters['challengeId']!;
    final mode = state.uri.queryParameters['mode'] ?? 'classic';
    final seed = int.parse(state.uri.queryParameters['seed'] ?? '0');
    return GameScreen(
      mode: GameMode.fromString(mode),
      challengeId: challengeId,
      challengeSeed: seed,
    );
  },
),
```

Add after `/friend/:code`:
```dart
GoRoute(
  path: '/challenge/:challengeId',
  builder: (context, state) {
    final challengeId = state.pathParameters['challengeId']!;
    return FriendsScreen(initialChallengeId: challengeId);
  },
),
GoRoute(
  path: '/challenges',
  builder: (context, state) => const FriendsScreen(initialTab: 2),
),
```

- [ ] **Step 2: Run analyze**

Run: `flutter analyze lib/app/router.dart`
Expected: May have errors until GameScreen/FriendsScreen are updated (that's OK — will be resolved in later tasks).

- [ ] **Step 3: Commit**

```bash
git add lib/app/router.dart
git commit -m "feat(challenge): add /game/challenge, /challenges, /challenge/:id routes"
```

---

## Task 9: FriendsScreen tab refactor + Challenges tab

**Files:**
- Modify: `lib/features/friends/friends_screen.dart` — refactor to TabBar layout
- Create: `lib/features/friends/challenge_tab.dart` — challenges tab content
- Create: `lib/features/friends/challenge_widgets.dart` — ChallengeCard, countdown, wager badge
- Create: `test/challenge/challenge_widgets_test.dart`

- [ ] **Step 1: Refactor FriendsScreen to TabBar**

Add `TabController` (3 tabs: Code & Search, Friends & Followers, Challenges). Move existing ListView sections into Tab 1 and Tab 2.

- [ ] **Step 2: Create ChallengeCard widget**

Shows: sender/recipient username, mode icon, countdown timer, wager badge, accept/decline buttons.

- [ ] **Step 3: Create challenge_tab.dart**

Two sections: Received (pending challenges with accept/decline) and Sent (sent challenges with status chips). Uses `challengeProvider` to load data.

- [ ] **Step 4: Write widget tests**

Test ChallengeCard rendering, countdown display, accept/decline button taps with mocked provider.

- [ ] **Step 5: Run tests**

Run: `flutter test test/challenge/challenge_widgets_test.dart`
Expected: All tests PASS.

- [ ] **Step 6: Run analyze**

Run: `flutter analyze lib/features/friends/`
Expected: 0 issues.

- [ ] **Step 7: Commit**

```bash
git add lib/features/friends/ test/challenge/challenge_widgets_test.dart
git commit -m "feat(challenge): refactor FriendsScreen to tabs + add Challenges tab with ChallengeCard"
```

---

## Task 10: SendChallengeSheet — bottom sheet for challenge creation

**Files:**
- Create: `lib/features/friends/send_challenge_sheet.dart`

- [ ] **Step 1: Implement SendChallengeSheet**

Bottom sheet with:
1. Recipient display (username + avatar)
2. Mode selection chips (Classic, TimeTrial, ColorChef)
3. Type toggle (Score Battle enabled, Live Duel disabled/grayed with "Coming Soon")
4. Wager chips (None, 10, 25, 50 Jel Ozu) — disabled if insufficient balance
5. "Play & Send" button → navigates to `/game/challenge?challengeId=...&mode=...&seed=...`
6. Daily limit counter display

- [ ] **Step 2: Write tests**

Test chip selection, wager validation, daily limit display.

- [ ] **Step 3: Run tests + analyze**

Run: `flutter test test/challenge/ && flutter analyze lib/features/friends/send_challenge_sheet.dart`
Expected: All pass.

- [ ] **Step 4: Commit**

```bash
git add lib/features/friends/send_challenge_sheet.dart test/challenge/
git commit -m "feat(challenge): add SendChallengeSheet bottom sheet with mode/wager selection"
```

---

## Task 11: ChallengeRevealOverlay — score reveal animation

**Files:**
- Create: `lib/features/shared/challenge_reveal_overlay.dart`

- [ ] **Step 1: Implement reveal overlay**

Counter animation revealing recipient score then sender score. Confetti + gold border for winner. Wager result display. Rematch + Close buttons. Reduce motion: skip animation, show result directly. `SemanticsService.sendAnnouncement` for a11y.

- [ ] **Step 2: Write tests**

Test reveal displays correct scores, outcome text, rematch button callback.

- [ ] **Step 3: Run tests + analyze**

- [ ] **Step 4: Commit**

```bash
git add lib/features/shared/challenge_reveal_overlay.dart test/challenge/
git commit -m "feat(challenge): add ChallengeRevealOverlay with score counter animation"
```

---

## Task 12: GameScreen integration — challenge mode play + score submit

**Files:**
- Modify: `lib/features/game_screen/game_callbacks.dart` — hook challenge score submit on game over
- Modify: `lib/features/game_screen/game_over_overlay.dart` — add Challenge button

- [ ] **Step 1: Add challengeId/challengeSeed params to GameScreen**

Pass through from router query params. When challenge mode: after game over, call `challengeRepository.submitRecipientScore()` (if recipient) or `challengeRepository.createChallenge()` (if sender). Show ChallengeRevealOverlay on recipient completion.

- [ ] **Step 2: Add "Challenge" button to game over overlay**

After Home button, add Challenge icon button (visible when `gamesPlayed >= 3`). Opens SendChallengeSheet.

- [ ] **Step 3: Add offline pending score persistence**

On network failure: save `pending_challenge_score_{challengeId}` to SharedPreferences. On next app launch, check and retry.

- [ ] **Step 4: Write tests**

Test challenge score submission callback, offline persistence, game over button visibility.

- [ ] **Step 5: Run tests + analyze**

Run: `flutter test && flutter analyze`
Expected: All pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/game_screen/ test/
git commit -m "feat(challenge): integrate challenge mode into GameScreen with score submit + offline fallback"
```

---

## Task 13: HomeScreen — ActiveChallengeBanner

**Files:**
- Modify: `lib/features/home_screen/home_screen.dart` — add banner widget

- [ ] **Step 1: Add _ActiveChallengeBanner widget**

Following WeeklyRivalCard pattern. Shows pending challenge count, first challenger username, mode. Tap navigates to `/challenges`. Hidden when 0 pending. Amber wager badge.

- [ ] **Step 2: Add to HomeScreen body**

Insert after WeeklyRivalCard in the ListView.

- [ ] **Step 3: Run analyze + existing tests**

Run: `flutter analyze lib/features/home_screen/ && flutter test test/`
Expected: 0 issues, all tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/features/home_screen/
git commit -m "feat(challenge): add ActiveChallengeBanner to HomeScreen"
```

---

## Task 14: Integration points — ProfileScreen, FriendTile, WeeklyRivalCard, ShareManager

**Files:**
- Modify: `lib/features/profile/profile_screen.dart` — add "Challenge" button for mutual friends
- Modify: `lib/features/friends/friends_widgets.dart` — add challenge icon to FriendTile
- Modify: `lib/features/home_screen/widgets/weekly_rival_card.dart` — add Challenge button
- Modify: `lib/viral/share_manager.dart` — add shareChallenge method

- [ ] **Step 1: ProfileScreen — add Challenge button**

After follow/unfollow button, add "Challenge" button (visible only for mutual friends). Opens SendChallengeSheet with pre-selected recipient.

- [ ] **Step 2: FriendTile — add challenge trailing icon**

Add swords icon trailing button on mutual friend tiles. Opens SendChallengeSheet.

- [ ] **Step 3: WeeklyRivalCard — add Challenge button**

Add small "Challenge" text button next to rival info. Opens SendChallengeSheet with rival pre-selected.

- [ ] **Step 4: ShareManager — add shareChallenge**

```dart
Future<void> shareChallenge(Challenge challenge, AppStrings l) async {
  final text = '${l.challengeShareCaption(challenge.senderUsername)}\n'
      'https://gloogame.com/challenge/${challenge.id}\n\n'
      '#GlooChallenge #Gloo';
  _analytics.logShare(mode: 'challenge');
  await Share.share(text);
}
```

- [ ] **Step 5: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: All pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/profile/ lib/features/friends/ lib/features/home_screen/ lib/viral/
git commit -m "feat(challenge): add challenge entry points to Profile, FriendTile, WeeklyRival, ShareManager"
```

---

## Task 15: Notification integration

**Files:**
- Modify: `lib/services/notification_service.dart` — add challenge notification types + ID strategy

- [ ] **Step 1: Extend NotificationType enum**

Add to END of enum: `challengeReceived`, `challengeExpiring`, `syncDuelInvite`.

- [ ] **Step 2: Add challenge notification ID helper**

```dart
int challengeNotifId(String challengeId) => challengeId.hashCode.abs() % 1000000 + 1000;
```

- [ ] **Step 3: Add scheduling methods for challenge notifications**

In FirebaseNotificationService: schedule challenge received/expiring notifications using unique IDs.

- [ ] **Step 4: Run analyze**

Run: `flutter analyze lib/services/notification_service.dart`
Expected: 0 issues.

- [ ] **Step 5: Commit**

```bash
git add lib/services/notification_service.dart
git commit -m "feat(challenge): extend notification service with challenge types and unique IDs"
```

---

## Task 16: Full test suite + build verification

**Files:**
- All test files created in previous tasks

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests pass (2243+ existing + new challenge tests).

- [ ] **Step 2: Run analyze**

Run: `flutter analyze`
Expected: 0 errors, 0 warnings.

- [ ] **Step 3: Run web build**

Run: `flutter build web --release --dart-define-from-file=.env`
Expected: Build succeeds.

- [ ] **Step 4: Update todo.md**

Mark CD.27c as in progress, add completion notes.

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat(challenge): CD.27c challenge/invite system complete — Phase 1 (async Score Battle)"
```

---

## Summary

| Task | Component | Estimated Steps |
|------|-----------|----------------|
| 1 | Supabase migration | 4 |
| 2 | Dart models + tests | 6 |
| 3 | Edge Functions (6 EFs) | 10 |
| 4 | ChallengeRepository | 5 |
| 5 | ChallengeProvider | 5 |
| 6 | l10n (12 languages) | 4 |
| 7 | Color constants | 3 |
| 8 | Router routes | 3 |
| 9 | FriendsScreen tabs + Challenge tab | 7 |
| 10 | SendChallengeSheet | 4 |
| 11 | ChallengeRevealOverlay | 4 |
| 12 | GameScreen integration | 6 |
| 13 | HomeScreen banner | 4 |
| 14 | Integration points (4 files) | 6 |
| 15 | Notification integration | 5 |
| 16 | Full verification | 5 |

**Total: 16 tasks, ~81 steps**

**Phase 2 (deferred):** Sync Live Duel, expire-challenges cron, advanced notification scheduling.
