-- Receipt replay korumasi: ayni receipt'in birden fazla hesapta kullanilmasini onle
-- purchase_verifications tablosuna receipt_hash kolonu + unique constraint ekle

ALTER TABLE purchase_verifications
  ADD COLUMN IF NOT EXISTS receipt_hash TEXT;

-- Ayni receipt, farkli user tarafindan basariyla kullanilamamali
-- Ayni user ayni receipt'i tekrar gonderebilir (idempotent)
CREATE UNIQUE INDEX IF NOT EXISTS uq_receipt_hash_verified
  ON purchase_verifications (receipt_hash)
  WHERE verified = true;
