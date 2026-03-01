-- Per-user redeem code kullanim takibi
-- Ayni kullanicinin ayni kodu birden fazla kullanmasini onler

CREATE TABLE IF NOT EXISTS redeem_usages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  code_id uuid REFERENCES redeem_codes(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  redeemed_at timestamptz DEFAULT now(),
  UNIQUE(code_id, user_id)
);

ALTER TABLE redeem_usages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own usages"
  ON redeem_usages
  FOR SELECT
  USING (auth.uid() = user_id);
