-- S7-SEC-5: PvP seed spoofing korumasi
-- Timestamp tabanli tahmin edilebilir seed yerine kriptografik random.
-- random() PostgreSQL'de pg_prng ile uretilir — tahmin edilemez.
-- 16 haneli pozitif BIGINT araligi: 1000000000000000 — 9999999999999999

ALTER TABLE pvp_matches
  ALTER COLUMN seed SET DEFAULT (floor(random() * 9000000000000000) + 1000000000000000)::bigint;
