-- Weekly boss master + per-user weekly assignment (#12).
create table public.weekly_bosses (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    description text not null default '',
    xp_reward integer not null default 1000,
    stat_rewards jsonb not null default '{}',
    badge_reward text,
    required_count integer not null default 3,
    life_class text check (life_class in ('warrior','scholar','builder','monk','strategist')),
    created_at timestamptz not null default timezone('utc', now())
);
alter table public.weekly_bosses enable row level security;
create policy "weekly_bosses_read_all" on public.weekly_bosses for select to authenticated using (true);

create table public.user_weekly_bosses (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    boss_id uuid not null references public.weekly_bosses(id) on delete cascade,
    week_start_date date not null,
    status text not null default 'active' check (status in ('active','completed','failed')),
    progress integer not null default 0,
    rerolls_used integer not null default 0,
    completed_at timestamptz,
    unique (user_id, week_start_date)
);
alter table public.user_weekly_bosses enable row level security;
create policy "user_weekly_bosses_own_all" on public.user_weekly_bosses
    for all to authenticated
    using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into public.weekly_bosses (title, description, stat_rewards, badge_reward, required_count, life_class) values
    ('The Iron Trial', 'Conquer 3 workouts this week.', '{"strength":10,"discipline":5}', 'iron_will', 3, 'warrior'),
    ('The Archive', 'Finish 5 study sessions this week.', '{"intelligence":10,"mind":5}', 'sage_mind', 5, 'scholar'),
    ('Ship It', 'Ship 1 mini project this week.', '{"wealth":8,"charisma":7}', 'the_builder', 1, 'builder'),
    ('Stillness', 'Meditate on 7 days this week.', '{"mind":15}', 'inner_peace', 7, 'monk'),
    ('The Ledger', 'Hit your weekly savings target.', '{"wealth":10,"charisma":5}', 'tactician', 1, 'strategist'),
    ('Momentum', 'Complete 10 daily quests this week.', '{"discipline":15}', 'unbroken', 10, null);
