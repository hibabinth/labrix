-- 1. Upgrade profiles table with new columns
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS followers INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS following INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS about_me TEXT,
ADD COLUMN IF NOT EXISTS interests TEXT[] DEFAULT '{}';

-- 2. Upgrade workers table with rating stats
ALTER TABLE public.workers
ADD COLUMN IF NOT EXISTS rating NUMERIC DEFAULT 0.0,
ADD COLUMN IF NOT EXISTS rating_count INTEGER DEFAULT 0;

-- 3. Create the posts table for the new social feature
CREATE TABLE IF NOT EXISTS public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS on posts
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- Post Policies
CREATE POLICY "Posts are viewable by everyone" ON public.posts FOR SELECT USING (true);
CREATE POLICY "Users can insert their own posts" ON public.posts FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4. Create Storage buckets for the images (avatars, posts)
-- Depending on your Supabase version, this might need to be run in the SQL editor or done manually in the UI.
insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true) on conflict do nothing;
insert into storage.buckets (id, name, public) values ('posts', 'posts', true) on conflict do nothing;

-- Storage Policies
create policy "Avatars are publicly accessible" on storage.objects for select using (bucket_id = 'avatars');
create policy "Users can upload avatars" on storage.objects for insert with check (bucket_id = 'avatars' and auth.role() = 'authenticated');

create policy "Posts images are publicly accessible" on storage.objects for select using (bucket_id = 'posts');
create policy "Users can upload post images" on storage.objects for insert with check (bucket_id = 'posts' and auth.role() = 'authenticated');
