-- Analytics events (#24). Insert-only from the client; user owns their rows.
create table public.analytics_events (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references auth.users(id) on delete cascade,
    event text not null,
    properties jsonb not null default '{}',
    created_at timestamptz not null default timezone('utc', now())
);
alter table public.analytics_events enable row level security;
create policy "analytics_insert_own" on public.analytics_events
    for insert to authenticated
    with check (auth.uid() = user_id);
