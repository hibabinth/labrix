-- supabase_schema_v7.sql
-- 1. Create the user_follows junction table
CREATE TABLE IF NOT EXISTS public.user_follows (
  follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (follower_id, following_id)
);

-- Enable RLS
ALTER TABLE public.user_follows ENABLE ROW LEVEL SECURITY;

-- 2. Policies
-- Anyone can see who follows who
CREATE POLICY "Follows are viewable by everyone" 
ON public.user_follows FOR SELECT 
USING (true);

-- Authenticated users can follow others (inserting for themselves)
CREATE POLICY "Users can follow others" 
ON public.user_follows FOR INSERT 
WITH CHECK (auth.uid() = follower_id);

-- Authenticated users can unfollow others
CREATE POLICY "Users can unfollow others" 
ON public.user_follows FOR DELETE 
USING (auth.uid() = follower_id);

-- 3. Trigger Function to Update Profile Counters
CREATE OR REPLACE FUNCTION public.handle_user_follows()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    -- Increment the follower count of the target
    UPDATE public.profiles SET followers = followers + 1 WHERE id = NEW.following_id;
    -- Increment the following count of the current user
    UPDATE public.profiles SET following = following + 1 WHERE id = NEW.follower_id;
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    -- Decrement the follower count of the target
    UPDATE public.profiles SET followers = followers - 1 WHERE id = OLD.following_id;
    -- Decrement the following count of the current user
    UPDATE public.profiles SET following = following - 1 WHERE id = OLD.follower_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Attach Trigger to user_follows
DROP TRIGGER IF EXISTS on_user_follow_change ON public.user_follows;
CREATE TRIGGER on_user_follow_change
  AFTER INSERT OR DELETE ON public.user_follows
  FOR EACH ROW EXECUTE FUNCTION public.handle_user_follows();
