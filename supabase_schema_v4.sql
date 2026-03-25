-- supabase_schema_v4.sql
-- 1. Upgrade profiles table with new columns for cover photo and headline
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS cover_image_url TEXT,
ADD COLUMN IF NOT EXISTS headline VARCHAR(150);

-- 2. Create Storage bucket for the covers (background frames)
insert into storage.buckets (id, name, public) values ('covers', 'covers', true) on conflict do nothing;

-- 3. Storage Policies for covers
create policy "Covers are publicly accessible" on storage.objects for select using (bucket_id = 'covers');
create policy "Users can upload covers" on storage.objects for insert with check (bucket_id = 'covers' and auth.role() = 'authenticated');
create policy "Users can update covers" on storage.objects for update using (bucket_id = 'covers' and auth.uid() = owner);
