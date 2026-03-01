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
  user_id UUID NOT NULL REFERENCES profiles(id),
  mode TEXT NOT NULL,
  score INTEGER NOT NULL CHECK (score >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_scores_mode_score ON scores (mode, score DESC);
CREATE INDEX IF NOT EXISTS idx_scores_user_mode ON scores (user_id, mode);

-- ─── Gunluk Bulmaca ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS daily_tasks (
  id BIGSERIAL PRIMARY KEY,
  date DATE NOT NULL,
  user_id UUID NOT NULL REFERENCES profiles(id),
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

-- ─── Meta-Game State ──────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS meta_states (
  user_id UUID PRIMARY KEY REFERENCES profiles(id),
  island_state JSONB NOT NULL DEFAULT '{}'::jsonb,
  character_state JSONB NOT NULL DEFAULT '{}'::jsonb,
  season_pass_state JSONB NOT NULL DEFAULT '{}'::jsonb,
  quest_progress JSONB NOT NULL DEFAULT '{}'::jsonb,
  quest_date TEXT,
  gel_energy INTEGER NOT NULL DEFAULT 0,
  total_earned_energy INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
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

-- NOT: Dogrudan INSERT devre disi birakildi.
-- Skor gondermek icin submit_score() RPC fonksiyonu kullanilmali.
-- Bu fonksiyon mod bazli skor sinirini dogrular.

-- ─── daily_tasks ─────────────────────────────────────────────────────────────

ALTER TABLE daily_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY daily_tasks_select ON daily_tasks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY daily_tasks_insert ON daily_tasks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY daily_tasks_update ON daily_tasks
  FOR UPDATE USING (auth.uid() = user_id);

-- ─── redeem_codes ────────────────────────────────────────────────────────────
-- NOT: Client dogrudan redeem_codes tablosuna erismemeli.
-- Tum redeem islemleri supabase/functions/redeem-code Edge Function uzerinden yapilir.
-- Edge Function service_role key ile RLS'i bypass eder.

ALTER TABLE redeem_codes ENABLE ROW LEVEL SECURITY;

-- Client tarafindan SELECT/UPDATE YAPILAMAZ.
-- Tum erisim Edge Function (service_role) uzerinden saglanir.

-- ─── pvp_matches ─────────────────────────────────────────────────────────────

ALTER TABLE pvp_matches ENABLE ROW LEVEL SECURITY;

CREATE POLICY pvp_matches_select ON pvp_matches
  FOR SELECT USING (
    auth.uid() = player1_id OR auth.uid() = player2_id
  );

CREATE POLICY pvp_matches_insert ON pvp_matches
  FOR INSERT WITH CHECK (auth.uid() = player1_id);

-- NOT: pvp_matches icin UPDATE politikasi KALDIRILDI.
-- Client dogrudan winner_id, status, completed_at guncelleyemez.
-- Skor gondermek icin submit_pvp_score() RPC fonksiyonu kullanilmali.

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

-- ─── meta_states ────────────────────────────────────────────────────────────

ALTER TABLE meta_states ENABLE ROW LEVEL SECURITY;

CREATE POLICY meta_states_select ON meta_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY meta_states_insert ON meta_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY meta_states_update ON meta_states
  FOR UPDATE USING (auth.uid() = user_id);

-- =============================================================================
-- GDPR DELETE Politikalari (Right to Erasure)
-- =============================================================================
-- Kullanici yalnizca kendi verisini silebilir.

CREATE POLICY profiles_delete ON profiles
  FOR DELETE USING (auth.uid() = id);

CREATE POLICY scores_delete ON scores
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY daily_tasks_delete ON daily_tasks
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY pvp_matches_delete ON pvp_matches
  FOR DELETE USING (auth.uid() = player1_id OR auth.uid() = player2_id);

CREATE POLICY meta_states_delete ON meta_states
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY pvp_obstacles_delete ON pvp_obstacles
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM pvp_matches
      WHERE id = pvp_obstacles.match_id
        AND (player1_id = auth.uid() OR player2_id = auth.uid())
    )
  );

-- =============================================================================
-- RPC Fonksiyonlari
-- =============================================================================

-- ─── PvP Skor Gonderimi ────────────────────────────────────────────────────
-- Client dogrudan pvp_matches tablosunu guncelleyemez.
-- Bu fonksiyon:
--   1. Auth'dan user_id alir
--   2. User'in match'in player1 veya player2'si oldugunu dogrular
--   3. Ilgili skor alanini gunceller (player1_score veya player2_score)
--   4. Her iki skor da girildiyse: winner_id hesaplar, status='completed', completed_at=now()

CREATE OR REPLACE FUNCTION submit_pvp_score(p_match_id UUID, p_score INT)
RETURNS JSON AS $$
DECLARE
  v_match pvp_matches%ROWTYPE;
  v_user_id UUID := auth.uid();
  v_winner_id UUID;
BEGIN
  -- Mac bilgisini getir
  SELECT * INTO v_match FROM pvp_matches WHERE id = p_match_id;

  IF v_match IS NULL THEN
    RETURN json_build_object('error', 'Match not found');
  END IF;

  -- Mac aktif olmali
  IF v_match.status != 'active' THEN
    RETURN json_build_object('error', 'Match is not active');
  END IF;

  -- Hangi oyuncu oldugunu belirle ve skoru guncelle
  IF v_user_id = v_match.player1_id THEN
    UPDATE pvp_matches SET player1_score = p_score WHERE id = p_match_id;
  ELSIF v_user_id = v_match.player2_id THEN
    UPDATE pvp_matches SET player2_score = p_score WHERE id = p_match_id;
  ELSE
    RETURN json_build_object('error', 'Not a participant');
  END IF;

  -- Guncel mac verisini yeniden oku
  SELECT * INTO v_match FROM pvp_matches WHERE id = p_match_id;

  -- Her iki skor da girildiyse winner belirle ve maci tamamla
  IF v_match.player1_score IS NOT NULL AND v_match.player2_score IS NOT NULL THEN
    IF v_match.player1_score > v_match.player2_score THEN
      v_winner_id := v_match.player1_id;
    ELSIF v_match.player2_score > v_match.player1_score THEN
      v_winner_id := v_match.player2_id;
    END IF;
    -- v_winner_id beraberliklerde NULL kalir

    UPDATE pvp_matches
    SET winner_id = v_winner_id,
        status = 'completed',
        completed_at = NOW()
    WHERE id = p_match_id;
  END IF;

  RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── PvP Stat Atomic Increment ───────────────────────────────────────────
-- Client read-then-write yerine atomic increment kullanir.
-- Race condition riski olmadan pvp_wins veya pvp_losses arttirir.

CREATE OR REPLACE FUNCTION increment_pvp_stat(p_stat TEXT)
RETURNS VOID AS $$
BEGIN
  IF p_stat = 'win' THEN
    UPDATE profiles SET pvp_wins = pvp_wins + 1 WHERE id = auth.uid();
  ELSIF p_stat = 'loss' THEN
    UPDATE profiles SET pvp_losses = pvp_losses + 1 WHERE id = auth.uid();
  ELSE
    RAISE EXCEPTION 'Invalid stat: %', p_stat;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── Skor Gonderimi (Mod Bazli Sinirli) ──────────────────────────────────
-- Client dogrudan scores tablosuna INSERT yapamaz.
-- Bu fonksiyon mod bazli makul maks skor sinirini dogrular:
--   classic: 100000, colorChef: 50000, timeTrial: 100000,
--   zen: 999999, daily: 100000, level: 50000, duel: 100000

CREATE OR REPLACE FUNCTION submit_score(p_mode TEXT, p_score INT)
RETURNS JSON AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_max_score INT;
BEGIN
  -- Auth kontrolu
  IF v_user_id IS NULL THEN
    RETURN json_build_object('error', 'Authentication required');
  END IF;

  -- Negatif skor reddet
  IF p_score < 0 THEN
    RETURN json_build_object('error', 'Score cannot be negative');
  END IF;

  -- Mod bazli maks skor siniri
  CASE p_mode
    WHEN 'classic' THEN v_max_score := 100000;
    WHEN 'colorChef' THEN v_max_score := 50000;
    WHEN 'timeTrial' THEN v_max_score := 100000;
    WHEN 'zen' THEN v_max_score := 999999;
    WHEN 'daily' THEN v_max_score := 100000;
    WHEN 'level' THEN v_max_score := 50000;
    WHEN 'duel' THEN v_max_score := 100000;
    ELSE RETURN json_build_object('error', 'Invalid game mode');
  END CASE;

  IF p_score > v_max_score THEN
    RETURN json_build_object('error', 'Score exceeds maximum for mode');
  END IF;

  -- Skoru kaydet
  INSERT INTO scores (user_id, mode, score)
  VALUES (v_user_id, p_mode, p_score);

  RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
