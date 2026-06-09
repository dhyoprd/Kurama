-- Quest proof submissions + proofs storage bucket (#11).
create table public.proof_submissions (
    id uuid primary key default gen_random_uuid(),
    user_quest_id uuid not null references public.user_quests(id) on delete cascade,
    proof_type text not null check (proof_type in ('photo','screenshot','text_note','link')),
    proof_url text not null,
    created_at timestamptz not null default timezone('utc', now())
);
alter table public.proof_submissions enable row level security;
create policy "proof_own_all" on public.proof_submissions
    for all to authenticated
    using (exists (select 1 from public.user_quests uq where uq.id = user_quest_id and uq.user_id = auth.uid()))
    with check (exists (select 1 from public.user_quests uq where uq.id = user_quest_id and uq.user_id = auth.uid()));

insert into storage.buckets (id, name, public)
values ('proofs', 'proofs', false) on conflict (id) do nothing;

create policy "proofs_own_all" on storage.objects
    for all to authenticated
    using (bucket_id = 'proofs' and owner = auth.uid())
    with check (bucket_id = 'proofs' and owner = auth.uid());
