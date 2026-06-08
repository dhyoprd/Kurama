-- Storage buckets for avatar generation (#5).
insert into storage.buckets (id, name, public)
values ('selfies', 'selfies', false), ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Users manage only their own selfies (private bucket).
create policy "selfies_own_all" on storage.objects
    for all to authenticated
    using (bucket_id = 'selfies' and owner = auth.uid())
    with check (bucket_id = 'selfies' and owner = auth.uid());

-- Avatars: public read (bucket is public); authenticated users may write their own.
create policy "avatars_own_write" on storage.objects
    for insert to authenticated
    with check (bucket_id = 'avatars' and owner = auth.uid());

create policy "avatars_public_read" on storage.objects
    for select to public
    using (bucket_id = 'avatars');
