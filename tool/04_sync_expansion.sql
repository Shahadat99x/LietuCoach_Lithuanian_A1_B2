-- Phase 22 Sync Expansion
-- SRS Cards, Practice Stats, Certificates

-- 1. SRS Cards
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

create policy "Users can all own srs cards"
  on srs_cards for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 2. Practice Stats
create table if not exists practice_stats (
  user_id uuid references auth.users primary key,
  streak_count int not null default 0,
  last_activity_date timestamptz,
  total_xp int not null default 0,
  lessons_completed int not null default 0,
  exams_completed int not null default 0,
  updated_at timestamptz default now()
);

alter table practice_stats enable row level security;

create policy "Users can all own practice stats"
  on practice_stats for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

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

create policy "Users can all own certificates"
  on certificates for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
