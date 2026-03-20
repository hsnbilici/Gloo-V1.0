-- D.4: Server-side leaderboard rank calculation
-- Replaces two client-side queries with single atomic RPC

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

  -- Get user's highest score for this mode
  SELECT score INTO v_top_score
  FROM scores
  WHERE user_id = v_user_id AND mode = p_mode
  ORDER BY score DESC
  LIMIT 1;

  IF v_top_score IS NULL THEN
    RETURN NULL;
  END IF;

  -- Count scores above user's top score
  IF p_weekly THEN
    SELECT COUNT(*) + 1 INTO v_rank
    FROM scores
    WHERE mode = p_mode
      AND score > v_top_score
      AND created_at >= NOW() - INTERVAL '7 days';
  ELSE
    SELECT COUNT(*) + 1 INTO v_rank
    FROM scores
    WHERE mode = p_mode
      AND score > v_top_score;
  END IF;

  RETURN v_rank;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION get_user_rank(TEXT, BOOLEAN) TO authenticated;
