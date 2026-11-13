-- ==============================================================================
-- SubTrack - Supabase PostgreSQL Database Schema & Row Level Security (RLS)
-- ==============================================================================
-- INSTRUCTIONS FOR USER:
-- 1. Go to your Supabase Dashboard: https://supabase.com/dashboard/project/fnbcoehktdaixsmxtcam
-- 2. In the left navigation bar, click on "SQL Editor".
-- 3. Click "New query", paste the contents of this file, and click "Run".
-- 4. Verify in "Table Editor" that 'profiles' and 'subscriptions' tables exist.
-- ==============================================================================

-- 1. PROFILES TABLE
-- Extends Supabase auth.users with public profile metadata
create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text not null,
  full_name text,
  avatar_url text,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security (RLS) for Profiles
alter table public.profiles enable row level security;

-- Profiles RLS Policies: Ensure users can only read and modify their own profile
drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Index for profile queries
create index if not exists idx_profiles_id on public.profiles(id);

-- 2. AUTOMATIC PROFILE TRIGGER ON SIGN-UP
-- Automatically inserts a new profile row when a user is created in auth.users
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url, updated_at)
  values (
    new.id,
    coalesce(new.email, ''),
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url',
    timezone('utc'::text, now())
  )
  on conflict (id) do update
  set email = excluded.email,
      full_name = coalesce(excluded.full_name, profiles.full_name),
      updated_at = timezone('utc'::text, now());
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- 3. SUBSCRIPTIONS TABLE
-- Stores individual user subscriptions
create table if not exists public.subscriptions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  category text not null default 'Entertainment',
  amount numeric(10, 2) not null default 0.00,
  currency text not null default 'USD',
  billing_cycle text not null default 'monthly', -- monthly, yearly, weekly, quarterly
  start_date date not null default current_date,
  next_renewal_date date,
  is_active boolean not null default true,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Indexes for performance
create index if not exists idx_subscriptions_user_id on public.subscriptions(user_id);
create index if not exists idx_subscriptions_renewal_date on public.subscriptions(next_renewal_date);
create index if not exists idx_subscriptions_is_active on public.subscriptions(is_active);

-- Enable Row Level Security (RLS) for Subscriptions
alter table public.subscriptions enable row level security;

-- Subscriptions RLS Policies: Ensure users can strictly access only their own data
drop policy if exists "Users can view their own subscriptions" on public.subscriptions;
create policy "Users can view their own subscriptions"
  on public.subscriptions for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own subscriptions" on public.subscriptions;
create policy "Users can insert their own subscriptions"
  on public.subscriptions for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own subscriptions" on public.subscriptions;
create policy "Users can update their own subscriptions"
  on public.subscriptions for update
  using (auth.uid() = user_id);

drop policy if exists "Users can delete their own subscriptions" on public.subscriptions;
create policy "Users can delete their own subscriptions"
  on public.subscriptions for delete
  using (auth.uid() = user_id);

