-- =============================================================================
-- Migration: Create challenges table + balances table for CD.27c Challenge/Invite system
--
-- challenges: Score battle invites between friends (all mutations via Edge Functions)
-- balances: Server-authoritative Jel Ozu balance for wager escrow
-- challenges_safe: View that hides seed + sender_score from recipient until appropriate
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. challenges table
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
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

-- ---------------------------------------------------------------------------
-- 2. RLS (SELECT only — all mutations via Edge Functions)
-- ---------------------------------------------------------------------------
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY challenges_select ON challenges FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

-- ---------------------------------------------------------------------------
-- 3. challenges_safe view (hides seed + sender_score until appropriate status)
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 4. Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX idx_challenges_recipient_status ON challenges(recipient_id, status);
CREATE INDEX idx_challenges_sender_status ON challenges(sender_id, status);
CREATE INDEX idx_challenges_sender_daily ON challenges(sender_id, created_at);
CREATE INDEX idx_challenges_expires_at ON challenges(expires_at) WHERE status IN ('pending', 'active');

-- ---------------------------------------------------------------------------
-- 5. balances table (server-authoritative wager escrow)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS balances (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  gel_ozu INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE balances ENABLE ROW LEVEL SECURITY;

CREATE POLICY balances_select ON balances FOR SELECT
  USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 6. Atomic balance RPC helpers (SECURITY DEFINER)
-- ---------------------------------------------------------------------------
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
