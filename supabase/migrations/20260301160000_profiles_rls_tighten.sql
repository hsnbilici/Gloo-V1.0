-- =============================================================================
-- Migration: profiles SELECT RLS sikilastirma
-- =============================================================================
-- Sorun: profiles_select USING (true) — herkes tum profilleri okuyabilir.
--        Simdiki veri hassas degil ama gelecekte PII eklenirse risk olusur.
--
-- Cozum:
--   1. leaderboard_view olustur (SECURITY DEFINER — RLS bypass ile profiles join)
--   2. profiles SELECT policy'yi auth.uid() = id ile kisitla
--   3. Leaderboard sorgulari view uzerinden yapilir
--
-- NOT: View SECURITY DEFINER olmali cunku profiles SELECT artik
--      auth.uid() = id ile kisitli. INVOKER modda view sadece mevcut
--      kullanicinin username'ini gosterir, diger profiller NULL olur.
--      DEFINER modda view sahibi (postgres) olarak calisir ve tum
--      username'leri leaderboard icin okuyabilir.
-- =============================================================================

-- ─── 1. Leaderboard View (SECURITY DEFINER) ─────────────────────────────────
-- scores + profiles join: sadece leaderboard icin gerekli alanlari expose eder.
-- created_at dahil (haftalik filtre icin gerekli).
-- profiles.created_at, profiles.elo, profiles.pvp_wins/losses HARIC.

CREATE OR REPLACE VIEW leaderboard_view
  WITH (security_invoker = false)
AS
SELECT
  s.id,
  s.user_id,
  s.mode,
  s.score,
  s.created_at,
  p.username
FROM scores s
LEFT JOIN profiles p ON p.id = s.user_id;

-- View'a okuma izni ver
GRANT SELECT ON leaderboard_view TO anon, authenticated;

-- ─── 2. profiles SELECT policy sikilastirma ─────────────────────────────────
-- Eski policy: USING (true) → herkes tum profilleri okuyabilir
-- Yeni policy: USING (auth.uid() = id) → sadece kendi profilini okuyabilir

DROP POLICY IF EXISTS profiles_select ON profiles;

CREATE POLICY profiles_select ON profiles
  FOR SELECT USING (auth.uid() = id);
