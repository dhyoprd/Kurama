-- Streak + activity tracking for the recovery system (#17).
alter table public.profiles
    add column last_active_at timestamptz,
    add column current_streak integer not null default 0;
