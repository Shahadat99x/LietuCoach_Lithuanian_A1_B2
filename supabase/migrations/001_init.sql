-- LietuCoach Database Schema
-- Phase 5: Supabase Auth + Cloud Sync
-- 
-- Apply this migration via Supabase SQL Editor or CLI:
-- supabase db push

-- ============================================
-- PROFILES TABLE
-- ============================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile" 
  on public.profiles for select 
  using (auth.uid() = id);

create policy "Users can update own profile" 
  on public.profiles for update 
  using (auth.uid() = id);

create policy "Users can insert own profile" 
  on public.profiles for insert 
  with check (auth.uid() = id);

-- Auto-create profile on user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ============================================
-- LESSON PROGRESS TABLE
-- ============================================
create table if not exists public.lesson_progress (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  unit_id text not null,
  lesson_id text not null,
  completed boolean not null default false,
  score int,
  xp int,
  updated_at timestamptz not null default now(),
  unique(user_id, unit_id, lesson_id)
);

alter table public.lesson_progress enable row level security;

create policy "Users can CRUD own lesson_progress" 
  on public.lesson_progress for all 
  using (auth.uid() = user_id);

-- ============================================
-- UNIT PROGRESS TABLE
-- ============================================
create table if not exists public.unit_progress (
  user_id uuid references auth.users(id) on delete cascade not null,
  unit_id text not null,
  exam_passed boolean not null default false,
  exam_score int,
  updated_at timestamptz not null default now(),
  primary key(user_id, unit_id)
);

alter table public.unit_progress enable row level security;

create policy "Users can CRUD own unit_progress" 
  on public.unit_progress for all 
  using (auth.uid() = user_id);

-- ============================================
-- SRS CARDS TABLE
-- ============================================
create table if not exists public.srs_cards (
  user_id uuid references auth.users(id) on delete cascade not null,
  card_id text not null,
  unit_id text not null,
  phrase_id text not null,
  front text not null,
  back text not null,
  audio_id text not null,
  ease real not null default 2.5,
  interval_days int not null default 0,
  due_at timestamptz not null,
  reps int not null default 0,
  lapses int not null default 0,
  last_reviewed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key(user_id, card_id)
);

alter table public.srs_cards enable row level security;

create policy "Users can CRUD own srs_cards" 
  on public.srs_cards for all 
  using (auth.uid() = user_id);

-- ============================================
-- INDEXES FOR SYNC QUERIES
-- ============================================
create index if not exists idx_lesson_progress_user_updated 
  on public.lesson_progress(user_id, updated_at);

create index if not exists idx_unit_progress_user_updated 
  on public.unit_progress(user_id, updated_at);

create index if not exists idx_srs_cards_user_updated 
  on public.srs_cards(user_id, updated_at);
