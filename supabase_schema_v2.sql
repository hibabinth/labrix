-- SUPABASE V2 MIGRATION SCRIPT
-- RUN THIS IN YOUR SUPABASE SQL EDITOR

-- 1. Add fields to Worker Profiles
ALTER TABLE workers ADD COLUMN IF NOT EXISTS skills TEXT[] DEFAULT '{}';
ALTER TABLE workers ADD COLUMN IF NOT EXISTS education TEXT;
ALTER TABLE workers ADD COLUMN IF NOT EXISTS portfolio_urls TEXT[] DEFAULT '{}';

-- 2. Create Job Vacancies Table
CREATE TABLE IF NOT EXISTS job_vacancies (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    location TEXT NOT NULL,
    budget NUMERIC NOT NULL,
    date_needed TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT DEFAULT 'open', -- 'open', 'assigned', 'completed', 'cancelled'
    assigned_worker_id UUID REFERENCES workers(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create Job Applications Table
CREATE TABLE IF NOT EXISTS job_applications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    job_vacancy_id UUID REFERENCES job_vacancies(id) ON DELETE CASCADE,
    worker_id UUID REFERENCES workers(id) ON DELETE CASCADE,
    cover_letter TEXT NOT NULL,
    proposed_price NUMERIC NOT NULL,
    status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_vacancy_id, worker_id) -- A worker can only apply once per job
);

-- Note: We will handle Super Admin / Admin logic by changing simple role strings 
-- in the `profiles` table directly. No new role tables needed at this stage.

-- 4. Add new fields to User Profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS company_name TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS details TEXT;
