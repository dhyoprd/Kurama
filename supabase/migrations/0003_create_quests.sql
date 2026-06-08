-- Master quest pool + per-user daily assignments (#6).
create table public.quests (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    description text not null default '',
    difficulty text not null check (difficulty in ('E','D','C','B','A','S')),
    stat_reward text not null,
    xp_reward integer not null,
    is_proof_required boolean not null default false,
    life_class text check (life_class in ('warrior','scholar','builder','monk','strategist')),
    created_at timestamptz not null default timezone('utc', now())
);
alter table public.quests enable row level security;
create policy "quests_read_all" on public.quests for select to authenticated using (true);

create table public.user_quests (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    quest_id uuid references public.quests(id) on delete set null,
    custom_title text,
    custom_description text,
    status text not null default 'active' check (status in ('active','completed','skipped')),
    skip_reason text,
    assigned_date date not null default current_date,
    completed_at timestamptz,
    xp_earned integer not null default 0,
    stat_earned text
);
alter table public.user_quests enable row level security;
create policy "user_quests_own_all" on public.user_quests
    for all to authenticated
    using (auth.uid() = user_id) with check (auth.uid() = user_id);

create index user_quests_user_date_idx on public.user_quests (user_id, assigned_date);

insert into public.quests (title, difficulty, stat_reward, xp_reward, is_proof_required, life_class) values
    ('Drink 2L of water', 'E', 'discipline', 50, false, null),
    ('Take a 10-minute walk', 'E', 'strength', 50, false, null),
    ('Tidy your space for 5 minutes', 'D', 'discipline', 100, false, null),
    ('20-minute workout', 'E', 'strength', 50, false, 'warrior'),
    ('50 push-ups', 'D', 'strength', 100, true, 'warrior'),
    ('Run 5km', 'C', 'strength', 150, true, 'warrior'),
    ('Full gym session', 'B', 'strength', 250, true, 'warrior'),
    ('Personal record attempt', 'A', 'strength', 400, true, 'warrior'),
    ('Read 10 pages', 'E', 'intelligence', 50, false, 'scholar'),
    ('Study for 30 minutes', 'D', 'intelligence', 100, false, 'scholar'),
    ('Finish a course module', 'C', 'intelligence', 150, true, 'scholar'),
    ('Sketch a product idea', 'E', 'charisma', 50, false, 'builder'),
    ('Commit one small feature', 'D', 'wealth', 100, true, 'builder'),
    ('Ship a mini project', 'B', 'wealth', 250, true, 'builder'),
    ('Meditate for 5 minutes', 'E', 'mind', 50, false, 'monk'),
    ('Journal one page', 'D', 'mind', 100, false, 'monk'),
    ('Digital detox for 1 hour', 'C', 'mind', 150, false, 'monk'),
    ('Track today''s expenses', 'E', 'wealth', 50, false, 'strategist'),
    ('Plan tomorrow''s tasks', 'D', 'discipline', 100, false, 'strategist'),
    ('Record a public-speaking practice', 'A', 'charisma', 400, true, 'strategist');
