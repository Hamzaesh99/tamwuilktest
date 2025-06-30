-- إعادة إنشاء جدول profiles مع تحديث مخبأ المخطط
BEGIN;

-- حفظ البيانات الموجودة في جدول مؤقت
CREATE TEMP TABLE profiles_backup AS SELECT * FROM public.profiles;

-- حذف الجدول الحالي
DROP TABLE IF EXISTS public.profiles CASCADE;

-- إعادة إنشاء الجدول بالتعريف الصحيح
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT,
    name TEXT,
    user_role TEXT DEFAULT 'investor' CHECK (user_role IN ('investor', 'project_owner', 'admin', 'guest')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_premium BOOLEAN DEFAULT FALSE,
    phone_number TEXT,
    avatar_url TEXT,
    bio TEXT,
    city TEXT,
    interests TEXT[] DEFAULT '{}',
    preferences JSONB DEFAULT '{}'
);

-- استعادة البيانات
INSERT INTO public.profiles 
SELECT 
    id,
    email,
    name,
    user_role,
    COALESCE(created_at, NOW()),
    COALESCE(updated_at, NOW()),
    COALESCE(is_premium, FALSE),
    phone_number,
    avatar_url,
    bio,
    city,
    COALESCE(interests, '{}'),
    COALESCE(preferences, '{}')
FROM profiles_backup;

-- إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_profiles_user_role ON public.profiles(user_role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- تفعيل RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- إعادة إنشاء سياسات RLS
CREATE POLICY "Allow users to read all profiles" ON public.profiles
    FOR SELECT USING (true);

CREATE POLICY "Allow users to create own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Allow users to update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow users to delete own profile" ON public.profiles
    FOR DELETE USING (auth.uid() = id);

-- تحديث مخبأ المخطط
NOTIFY pgrst, 'reload schema';

COMMIT;

-- التحقق من النتيجة
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position; 