-- مخطط قاعدة البيانات لتطبيق تمويلك
-- إنشاء جدول profiles مع الأعمدة الصحيحة

-- إنشاء جدول profiles
CREATE TABLE IF NOT EXISTS public.profiles (
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

-- إنشاء فهرس على user_role للبحث السريع
CREATE INDEX IF NOT EXISTS idx_profiles_user_role ON public.profiles(user_role);

-- إنشاء فهرس على email للبحث السريع
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- تفعيل RLS (Row Level Security)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- سياسات RLS لجدول profiles
-- السماح للمستخدمين بقراءة جميع الملفات الشخصية
CREATE POLICY "Allow users to read all profiles" ON public.profiles
    FOR SELECT USING (true);

-- السماح للمستخدمين بإنشاء ملفاتهم الشخصية
CREATE POLICY "Allow users to create own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- السماح للمستخدمين بتحديث ملفاتهم الشخصية فقط
CREATE POLICY "Allow users to update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- السماح للمستخدمين بحذف ملفاتهم الشخصية فقط
CREATE POLICY "Allow users to delete own profile" ON public.profiles
    FOR DELETE USING (auth.uid() = id);

-- دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء trigger لتحديث updated_at
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- دالة لإنشاء ملف شخصي تلقائياً عند تسجيل مستخدم جديد
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, user_role)
    VALUES (NEW.id, NEW.email, 'investor');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إنشاء trigger لإنشاء ملف شخصي تلقائياً
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- إنشاء جدول projects
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    image_url TEXT,
    funding_goal DECIMAL(15,2) NOT NULL,
    current_funding DECIMAL(15,2) DEFAULT 0,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'funded', 'completed', 'cancelled')),
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    city TEXT,
    single_investor BOOLEAN DEFAULT FALSE,
    investors UUID[] DEFAULT '{}'
);

-- تفعيل RLS لجدول projects
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- سياسات RLS لجدول projects
CREATE POLICY "Allow public to read projects" ON public.projects
    FOR SELECT USING (true);

CREATE POLICY "Allow project owners to create projects" ON public.projects
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Allow project owners to update their projects" ON public.projects
    FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Allow project owners to delete their projects" ON public.projects
    FOR DELETE USING (auth.uid() = owner_id);

-- إنشاء جدول offers
CREATE TABLE IF NOT EXISTS public.offers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    investor_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
    amount DECIMAL(15,2) NOT NULL,
    message TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- تفعيل RLS لجدول offers
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;

-- سياسات RLS لجدول offers
CREATE POLICY "Allow public to read offers" ON public.offers
    FOR SELECT USING (true);

CREATE POLICY "Allow investors to create offers" ON public.offers
    FOR INSERT WITH CHECK (auth.uid() = investor_id);

CREATE POLICY "Allow investors to update their offers" ON public.offers
    FOR UPDATE USING (auth.uid() = investor_id);

CREATE POLICY "Allow investors to delete their offers" ON public.offers
    FOR DELETE USING (auth.uid() = investor_id);

-- إنشاء جدول comments
CREATE TABLE IF NOT EXISTS public.comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    likes UUID[] DEFAULT '{}'
);

-- تفعيل RLS لجدول comments
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- سياسات RLS لجدول comments
CREATE POLICY "Allow public to read comments" ON public.comments
    FOR SELECT USING (true);

CREATE POLICY "Allow authenticated users to create comments" ON public.comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to update their comments" ON public.comments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Allow users to delete their comments" ON public.comments
    FOR DELETE USING (auth.uid() = user_id);

-- إنشاء جدول subscriptions
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan TEXT NOT NULL,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_date TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- تفعيل RLS لجدول subscriptions
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- سياسات RLS لجدول subscriptions
CREATE POLICY "Allow users to read their subscriptions" ON public.subscriptions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Allow authenticated users to create subscriptions" ON public.subscriptions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to update their subscriptions" ON public.subscriptions
    FOR UPDATE USING (auth.uid() = user_id);

-- إنشاء triggers لتحديث updated_at لجميع الجداول
CREATE TRIGGER update_projects_updated_at 
    BEFORE UPDATE ON public.projects 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_offers_updated_at 
    BEFORE UPDATE ON public.offers 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at 
    BEFORE UPDATE ON public.comments 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at 
    BEFORE UPDATE ON public.subscriptions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column(); 