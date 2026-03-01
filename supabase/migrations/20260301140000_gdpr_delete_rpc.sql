-- S7-SEC-4: GDPR silme transaction wrapping
-- Tum kullanici verisini tek transaction'da, dogru sirada siler.
-- SECURITY DEFINER: RLS bypass eder (gerekli cunku cross-table referanslar var).

-- 1. redeem_usages icin DELETE RLS politikasi (guard-in-depth)
CREATE POLICY redeem_usages_delete ON redeem_usages
  FOR DELETE USING (auth.uid() = user_id);

-- 2. Transactional silme RPC
CREATE OR REPLACE FUNCTION delete_user_data(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- Auth kontrolu: sadece kendi verisini silebilir
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: can only delete own data';
  END IF;

  -- Dogru sira: FK bagimliliklari ve RLS referanslari dikkate alinir
  -- pvp_obstacles ONCE (pvp_matches'a referans veriyor)
  DELETE FROM pvp_obstacles WHERE sender_id = p_user_id;
  -- pvp_matches (obstacles temizlendi, artik guvenle silinebilir)
  DELETE FROM pvp_matches WHERE player1_id = p_user_id OR player2_id = p_user_id;
  -- redeem_usages (redeem_codes FK)
  DELETE FROM redeem_usages WHERE user_id = p_user_id;
  -- Bagimsiz tablolar
  DELETE FROM meta_states WHERE user_id = p_user_id;
  DELETE FROM scores WHERE user_id = p_user_id;
  DELETE FROM daily_tasks WHERE user_id = p_user_id;
  -- profiles en son (diger tablolar FK referans verebilir)
  DELETE FROM profiles WHERE id = p_user_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
