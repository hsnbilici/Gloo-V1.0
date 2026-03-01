-- M.4: PvP Seed Server-Side Uretim
--
-- Seed degerini client yerine sunucu tarafinda uretir.
-- clock_timestamp() kullanilir: statement-level degil, cagri anindaki zamani verir.
-- Bu sayede ayni transaction icinde bile benzersiz seed garantilenir.
--
-- S7-SEC-1: seed kolonu INTEGER idi, ancak microsecond epoch (~1.74e15)
-- INTEGER max degerini (2^31-1 = 2,147,483,647) asiyor.
-- Kolon tipi BIGINT'e yukseltilerek overflow onlenir.

ALTER TABLE pvp_matches
  ALTER COLUMN seed TYPE BIGINT;

ALTER TABLE pvp_matches
  ALTER COLUMN seed SET DEFAULT (extract(epoch from clock_timestamp()) * 1000000)::bigint;

-- seed artik nullable degildir ve NOT NULL kisitlamasi zaten mevcut.
-- DEFAULT deger sayesinde INSERT'te seed gonderilmezse sunucu otomatik uretir.
