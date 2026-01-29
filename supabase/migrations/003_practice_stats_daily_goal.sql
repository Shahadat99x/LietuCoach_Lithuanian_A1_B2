-- Add daily_goal column to practice_stats if it doesn't exist
-- This fixes a sync error where the app expects this column but the DB is missing it.

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'practice_stats'
        AND column_name = 'daily_goal'
    ) THEN
        ALTER TABLE practice_stats
        ADD COLUMN daily_goal INTEGER NOT NULL DEFAULT 10;
    END IF;
END $$;
