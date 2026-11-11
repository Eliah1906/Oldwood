-- OLDWOOD Galerie: einmal im Supabase SQL Editor ausführen
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  published boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.post_images (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  image_url text not null,
  image_path text not null,
  description text not null default '',
  position integer not null default 0
);
alter table public.posts enable row level security;
alter table public.post_images enable row level security;
drop policy if exists "Public can view published posts" on public.posts;
create policy "Public can view published posts" on public.posts for select using (published = true);
drop policy if exists "Admins manage posts" on public.posts;
create policy "Admins manage posts" on public.posts for all to authenticated using (true) with check (true);
drop policy if exists "Public can view images of published posts" on public.post_images;
create policy "Public can view images of published posts" on public.post_images for select using (
  exists (select 1 from public.posts p where p.id = post_id and p.published = true)
);
drop policy if exists "Admins manage post images" on public.post_images;
create policy "Admins manage post images" on public.post_images for all to authenticated using (true) with check (true);
insert into storage.buckets (id, name, public) values ('oldwood-gallery','oldwood-gallery',true)
on conflict (id) do update set public = true;
drop policy if exists "Public can view OLDWOOD gallery files" on storage.objects;
create policy "Public can view OLDWOOD gallery files" on storage.objects for select using (bucket_id = 'oldwood-gallery');
drop policy if exists "Admins upload OLDWOOD gallery files" on storage.objects;
create policy "Admins upload OLDWOOD gallery files" on storage.objects for insert to authenticated with check (bucket_id = 'oldwood-gallery');
drop policy if exists "Admins update OLDWOOD gallery files" on storage.objects;
create policy "Admins update OLDWOOD gallery files" on storage.objects for update to authenticated using (bucket_id = 'oldwood-gallery') with check (bucket_id = 'oldwood-gallery');
drop policy if exists "Admins delete OLDWOOD gallery files" on storage.objects;
create policy "Admins delete OLDWOOD gallery files" on storage.objects for delete to authenticated using (bucket_id = 'oldwood-gallery');
