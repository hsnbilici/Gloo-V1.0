-- =============================================================================
-- Gloo — Supabase Veritabani Semasi
-- =============================================================================
-- Bu dosyayi Supabase SQL Editor'da calistirin.
-- Siralama onemlidir: once tablolar, sonra RLS politikalari.
-- =============================================================================

-- ─── Profiller ───────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  username TEXT NOT NULL DEFAULT 'Player',
  elo INTEGER NOT NULL DEFAULT 1000,
  pvp_wins INTEGER NOT NULL DEFAULT 0,
  pvp_losses INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Skorlar ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS scores (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  mode TEXT NOT NULL,
  score INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_scores_mode_score ON scores (mode, score DESC);
CREATE INDEX IF NOT EXISTS idx_scores_user_mode ON scores (user_id, mode);

-- ─── Gunluk Bulmaca ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS daily_tasks (
  id BIGSERIAL PRIMARY KEY,
  date DATE NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  completed BOOLEAN NOT NULL DEFAULT false,
  score INTEGER NOT NULL DEFAULT 0,
  completed_at TIMESTAMPTZ,
  UNIQUE(date, user_id)
);

-- ─── Redeem Kodlari ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS redeem_codes (
  id BIGSERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  product_ids JSONB NOT NULL DEFAULT '[]',
  max_uses INTEGER NOT NULL DEFAULT 1,
  current_uses INTEGER NOT NULL DEFAULT 0,
  expires_at TIMESTAMPTZ
);

-- ─── PvP Eslesmeleri ────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS pvp_matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player1_id UUID NOT NULL REFERENCES auth.users(id),
  player2_id UUID REFERENCES auth.users(id),  -- NULL = bot eslestirme
  seed INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',       -- active, completed, expired
  player1_score INTEGER,
  player2_score INTEGER,
  winner_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_pvp_matches_status ON pvp_matches (status)
  WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_pvp_matches_players ON pvp_matches (player1_id, player2_id);

-- ─── PvP Engel Kayitlari ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS pvp_obstacles (
  id BIGSERIAL PRIMARY KEY,
  match_id UUID NOT NULL REFERENCES pvp_matches(id),
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  obstacle_type TEXT NOT NULL,  -- ice, locked, stone
  count INTEGER NOT NULL DEFAULT 1,
  area_size INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================================
-- RLS Politikalari
-- =============================================================================

-- ─── profiles ────────────────────────────────────────────────────────────────

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_select ON profiles
  FOR SELECT USING (true);

CREATE POLICY profiles_insert ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY profiles_update ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- ─── scores ──────────────────────────────────────────────────────────────────

ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY scores_select ON scores
  FOR SELECT USING (true);

CREATE POLICY scores_insert ON scores
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ─── daily_tasks ─────────────────────────────────────────────────────────────

ALTER TABLE daily_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY daily_tasks_select ON daily_tasks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY daily_tasks_insert ON daily_tasks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY daily_tasks_update ON daily_tasks
  FOR UPDATE USING (auth.uid() = user_id);

-- ─── redeem_codes ────────────────────────────────────────────────────────────

ALTER TABLE redeem_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY redeem_codes_select ON redeem_codes
  FOR SELECT USING (true);

CREATE POLICY redeem_codes_update ON redeem_codes
  FOR UPDATE USING (true);  -- current_uses artirimi icin

-- ─── pvp_matches ─────────────────────────────────────────────────────────────

ALTER TABLE pvp_matches ENABLE ROW LEVEL SECURITY;

CREATE POLICY pvp_matches_select ON pvp_matches
  FOR SELECT USING (
    auth.uid() = player1_id OR auth.uid() = player2_id
  );

CREATE POLICY pvp_matches_insert ON pvp_matches
  FOR INSERT WITH CHECK (auth.uid() = player1_id);

CREATE POLICY pvp_matches_update ON pvp_matches
  FOR UPDATE USING (
    auth.uid() = player1_id OR auth.uid() = player2_id
  );

-- ─── pvp_obstacles ───────────────────────────────────────────────────────────

ALTER TABLE pvp_obstacles ENABLE ROW LEVEL SECURITY;

CREATE POLICY pvp_obstacles_select ON pvp_obstacles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM pvp_matches
      WHERE id = pvp_obstacles.match_id
        AND (player1_id = auth.uid() OR player2_id = auth.uid())
    )
  );

CREATE POLICY pvp_obstacles_insert ON pvp_obstacles
  FOR INSERT WITH CHECK (auth.uid() = sender_id);
