-- =============================================================================
-- Migration: Leaderboard bug fixes
-- =============================================================================
-- Fixes:
--   1. leaderboard_view shows ALL scores → best score per user per mode
--   2. get_user_rank counts all scores → counts unique users
--   3. get_user_rank weekly filter doesn't apply to own score lookup
--   4. PvP ELO leaderboard can't read other profiles due to RLS
-- =============================================================================

-- ─── 1. Fix leaderboard_view: best score per user per mode ────────────────
-- Old: returns ALL score rows → one user can occupy multiple leaderboard slots
-- New: returns only highest score per (user_id, mode) pair

CREATE OR REPLACE VIEW leaderboard_view
  WITH (security_invoker = false)
AS
SELECT DISTINCT ON (s.user_id, s.mode)
  s.id,
  s.user_id,
  s.mode,
  s.score,
  s.created_at,
  p.username
FROM scores s
LEFT JOIN profiles p ON p.id = s.user_id
ORDER BY s.user_id, s.mode, s.score DESC;

-- View'a okuma izni ver
GRANT SELECT ON leaderboard_view TO anon, authenticated;

-- ─── 2. Create elo_leaderboard_view ───────────────────────────────────────
-- profiles RLS is auth.uid() = id → ELO query only returns own profile.
-- This SECURITY DEFINER view bypasses RLS for leaderboard display.

CREATE OR REPLACE VIEW elo_leaderboard_view
  WITH (security_invoker = false)
AS
SELECT
  p.id,
  p.username,
  p.elo,
  p.pvp_wins,
  p.pvp_losses
FROM profiles p
WHERE p.elo > 0
ORDER BY p.elo DESC;

GRANT SELECT ON elo_leaderboard_view TO anon, authenticated;

-- ─── 3. Fix get_user_rank: unique users + weekly-aware own score ──────────
-- Old issues:
--   a) Gets user's ALL-TIME top score even when p_weekly=true
--   b) Counts ALL scores above user's top (not unique users)
-- New: applies weekly filter to own score lookup + counts distinct users

CREATE OR REPLACE FUNCTION get_user_rank(
  p_mode TEXT,
  p_weekly BOOLEAN DEFAULT FALSE
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_top_score INTEGER;
  v_rank INTEGER;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RETURN NULL;
  END IF;

  -- Get user's highest score for this mode (with weekly filter if requested)
  IF p_weekly THEN
    SELECT score INTO v_top_score
    FROM scores
    WHERE user_id = v_user_id
      AND mode = p_mode
      AND created_at >= NOW() - INTERVAL '7 days'
    ORDER BY score DESC
    LIMIT 1;
  ELSE
    SELECT score INTO v_top_score
    FROM scores
    WHERE user_id = v_user_id AND mode = p_mode
    ORDER BY score DESC
    LIMIT 1;
  END IF;

  IF v_top_score IS NULL THEN
    RETURN NULL;
  END IF;

  -- Count unique users with a higher top score
  IF p_weekly THEN
    SELECT COUNT(*) + 1 INTO v_rank
    FROM (
      SELECT DISTINCT user_id
      FROM scores
      WHERE mode = p_mode
        AND score > v_top_score
        AND created_at >= NOW() - INTERVAL '7 days'
    ) AS unique_users;
  ELSE
    SELECT COUNT(*) + 1 INTO v_rank
    FROM (
      SELECT DISTINCT user_id
      FROM scores
      WHERE mode = p_mode
        AND score > v_top_score
    ) AS unique_users;
  END IF;

  RETURN v_rank;
END;
$$;

GRANT EXECUTE ON FUNCTION get_user_rank(TEXT, BOOLEAN) TO authenticated;
