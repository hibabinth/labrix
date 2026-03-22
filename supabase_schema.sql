-- Supabase Schema for Labrix

-- Profiles table (extends auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  role TEXT CHECK (role IN ('user', 'worker')) NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  location TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workers table (specific to workers)
CREATE TABLE public.workers (
  id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
  category TEXT NOT NULL,
  experience_years INT DEFAULT 0,
  price_range TEXT,
  is_online BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Services (Categories)
CREATE TABLE public.services (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert initial services
INSERT INTO public.services (name) VALUES ('Plumbing'), ('Electrician'), ('Cleaning'), ('Welding'), ('Carpentry');

-- Bookings table
CREATE TABLE public.bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) NOT NULL,
  worker_id UUID REFERENCES public.workers(id) NOT NULL,
  service_id INT REFERENCES public.services(id),
  status TEXT CHECK (status IN ('pending', 'accepted', 'in_progress', 'completed', 'cancelled')) DEFAULT 'pending',
  date DATE,
  time TIME,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages table (for Realtime Chat)
CREATE TABLE public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES public.profiles(id) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews table
CREATE TABLE public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  reviewer_id UUID REFERENCES public.profiles(id) NOT NULL,
  worker_id UUID REFERENCES public.workers(id) NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Portfolios table (Worker images)
CREATE TABLE public.portfolios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  worker_id UUID REFERENCES public.workers(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Basic RLS Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolios ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Workers are viewable by everyone" ON public.workers FOR SELECT USING (true);
CREATE POLICY "Workers can insert own worker profile" ON public.workers FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Workers can update own worker profile" ON public.workers FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Services are viewable by everyone" ON public.services FOR SELECT USING (true);

CREATE POLICY "Users can view their own bookings" ON public.bookings FOR SELECT USING (auth.uid() = user_id OR auth.uid() = worker_id);
CREATE POLICY "Users can create bookings" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Participants can update booking status" ON public.bookings FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = worker_id);

CREATE POLICY "Participants can view chat messages" ON public.messages FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = messages.booking_id AND (b.user_id = auth.uid() OR b.worker_id = auth.uid()))
);
CREATE POLICY "Participants can insert chat messages" ON public.messages FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = messages.booking_id AND (b.user_id = auth.uid() OR b.worker_id = auth.uid())) AND auth.uid() = sender_id
);

CREATE POLICY "Reviews viewable by everyone" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "Users can insert reviews for their bookings" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);
