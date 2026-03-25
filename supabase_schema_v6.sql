-- supabase_schema_v6.sql
-- Change the headline type to TEXT to allow for longer profile summaries
ALTER TABLE public.profiles 
ALTER COLUMN headline TYPE TEXT USING headline::TEXT;
