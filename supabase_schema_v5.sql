-- supabase_schema_v5.sql
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS dob VARCHAR(50);
