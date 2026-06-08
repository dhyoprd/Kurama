-- profiles (#3): one row per user, created at end of onboarding (#4).
create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    username text unique not null,
    life_class text not null check (life_class in ('warrior','scholar','builder','monk','strategist')),
    level integer not null default 1,
    xp integer not null default 0,
    rank text not null default 'E' check (rank in ('E','D','C','B','A','S')),
    intensity text not null default 'normal' check (intensity in ('easy','normal','hard')),
    main_goals text[],
    original_selfie_url text,
    avatar_url text,
    weight numeric,
    height numeric,
    target_weight numeric,
    strength integer not null default 10,
    intelligence integer not null default 10,
    discipline integer not null default 10,
    charisma integer not null default 10,
    wealth integer not null default 10,
    mind integer not null default 10,
    created_at timestamptz not null default timezone('utc', now())
);

alter table public.profiles enable row level security;

create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy "profiles_delete_own" on public.profiles for delete using (auth.uid() = id);
