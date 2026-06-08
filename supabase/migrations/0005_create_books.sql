-- In-app library + reading sessions (#15 / #16). Pages stored inline for MVP.
create table public.books (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    author text not null,
    cover_symbol text not null default 'book.closed',
    pages text[] not null default '{}',
    created_at timestamptz not null default timezone('utc', now())
);
alter table public.books enable row level security;
create policy "books_read_all" on public.books for select to authenticated using (true);

create table public.user_reading_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    book_id uuid not null references public.books(id) on delete cascade,
    duration_seconds integer not null default 0,
    takeaway text,
    xp_earned integer not null default 0,
    created_at timestamptz not null default timezone('utc', now())
);
alter table public.user_reading_sessions enable row level security;
create policy "reading_sessions_own_all" on public.user_reading_sessions
    for all to authenticated
    using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Seed books: original placeholder page text (titles referenced for flavor only).
insert into public.books (title, author, cover_symbol, pages) values
    ('Atomic Habits', 'James Clear', 'atom',
     array[
       'Tiny changes, compounded daily, become remarkable results over time. You do not rise to your goals; you fall to your systems.',
       'Make the good habit obvious, attractive, easy, and satisfying. Make the bad habit invisible, unattractive, hard, and unsatisfying.',
       'Focus on who you wish to become. Every action is a vote for the type of person you are building.',
       'Never miss twice. One slip is an accident; two is the start of a new pattern. Show up, even small.'
     ]),
    ('Deep Work', 'Cal Newport', 'brain.head.profile',
     array[
       'The ability to focus without distraction on a demanding task is becoming rare, and therefore valuable.',
       'Schedule blocks of undistracted work. Treat your attention like the scarce resource it is.',
       'Embrace boredom. The mind that cannot tolerate stillness cannot sustain deep concentration.',
       'Drain the shallows. Ruthlessly cut low-value, fragmented tasks that crowd out real work.'
     ]),
    ('Meditations', 'Marcus Aurelius', 'leaf',
     array[
       'You have power over your mind, not outside events. Realize this, and you will find strength.',
       'Confine yourself to the present. The past is gone, the future not yet here.',
       'Waste no more time debating what a good person should be. Be one.',
       'What stands in the way becomes the way. Obstacles are training for the will.'
     ]);
