-- S7-SEC-2: Redeem code atomik artırma
-- Race condition fix: read-then-write yerine tek atomik UPDATE.
-- Etkilenen satır 0 ise kod limiti aşılmış demektir.

CREATE OR REPLACE FUNCTION increment_redeem_usage(p_code_id UUID)
RETURNS INT AS $$
DECLARE
  v_new_count INT;
BEGIN
  UPDATE redeem_codes
  SET current_uses = current_uses + 1
  WHERE id = p_code_id AND current_uses < max_uses
  RETURNING current_uses INTO v_new_count;

  -- 0 satır etkilendiyse limit aşılmış
  IF v_new_count IS NULL THEN
    RETURN -1;
  END IF;

  RETURN v_new_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
