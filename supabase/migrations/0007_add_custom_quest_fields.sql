-- Custom quest difficulty/stat for user-created quests (#10).
alter table public.user_quests
    add column custom_difficulty text check (custom_difficulty in ('E','D','C','B','A')),
    add column custom_stat_reward text;
