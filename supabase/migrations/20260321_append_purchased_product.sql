CREATE OR REPLACE FUNCTION append_purchased_product(p_user_id uuid, p_product_id text)
RETURNS void AS $$
BEGIN
  UPDATE profiles
  SET purchased_products = array_append(
    COALESCE(purchased_products, ARRAY[]::text[]),
    p_product_id
  )
  WHERE id = p_user_id
  AND NOT (p_product_id = ANY(COALESCE(purchased_products, ARRAY[]::text[])));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
