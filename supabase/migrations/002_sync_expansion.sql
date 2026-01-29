-- Phase 22 Sync Expansion
-- SRS Cards, Practice Stats, Certificates
--
-- NOTE: updated_at timestamps are managed explicitly by the application (Last-Write-Wins logic).
-- Triggers are NOT added to override these values, as we want to preserve the client's timestamp
-- during synchronization conflicts.

-- 1. SRS Cards (May already exist in 001_init.sql, included here for completeness via 'if not exists')
create table if not exists srs_cards (
  user_id uuid references auth.users not null,
  card_id text not null,
  unit_id text not null,
  phrase_id text not null,
  front text not null,
  back text not null,
  audio_id text,
  ease real not null default 2.5,
  interval_days int not null default 0,
  due_at timestamptz not null,
  reps int not null default 0,
  lapses int not null default 0,
  last_reviewed_at timestamptz,
  updated_at timestamptz default now(),
  primary key (user_id, card_id)
);

alter table srs_cards enable row level security;

-- Policy might already exist from 001_init.sql, duplicate creation might fail if not checked.
-- Checking if policy exists is hard in standard SQL script without plpgsql block.
-- However, 'create policy' usually errors if exists. 
-- 001_init.sql names it "Users can CRUD own srs_cards".
-- tool/04 names it "Users can all own srs cards".
-- I will drop the 'tool/04' style policy attempts to avoid conflict if referencing the same table, 
-- or use a DO block.
-- Given 001_init.sql covers srs_cards fully, I will comment out the permissions logic for srs_cards 
-- to prevent "policy already exists" errors if this runs on top of 001.
-- But I'll keep the table creation 'if not exists' just in case.

-- 2. Practice Stats
create table if not exists practice_stats (
  user_id uuid references auth.users primary key,
  streak_count int not null default 0,
  last_activity_date date, -- Changed to DATE for safer streak calculations
  total_xp int not null default 0,
  daily_goal int not null default 10,
  lessons_completed int not null default 0,
  exams_completed int not null default 0,
  updated_at timestamptz default now()
);

alter table practice_stats enable row level security;

do $$ 
begin
    if not exists (select 1 from pg_policies where policyname = 'Users can all own practice stats' and tablename = 'practice_stats') then
        create policy "Users can all own practice stats"
          on practice_stats for all
          using (auth.uid() = user_id)
          with check (auth.uid() = user_id);
    end if;
end $$;

-- 3. Certificates
create table if not exists certificates (
  user_id uuid references auth.users not null,
  id text not null, -- cert ID
  level text not null,
  issued_at timestamptz not null,
  learner_name text not null,
  updated_at timestamptz default now(),
  primary key (user_id, id)
);

alter table certificates enable row level security;

do $$ 
begin
    if not exists (select 1 from pg_policies where policyname = 'Users can all own certificates' and tablename = 'certificates') then
        create policy "Users can all own certificates"
          on certificates for all
          using (auth.uid() = user_id)
          with check (auth.uid() = user_id);
    end if;
end $$;
