-- إصلاح جدول profiles - إضافة عمود email إذا لم يكن موجوداً
-- قم بتنفيذ هذا الملف في Supabase SQL Editor

-- التحقق من وجود عمود email
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'email' 
        AND table_schema = 'public'
    ) THEN
        -- إضافة عمود email إذا لم يكن موجوداً
        ALTER TABLE public.profiles ADD COLUMN email TEXT;
        RAISE NOTICE 'تم إضافة عمود email إلى جدول profiles';
    ELSE
        RAISE NOTICE 'عمود email موجود بالفعل في جدول profiles';
    END IF;
END $$;

-- التحقق من وجود عمود user_role
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'user_role' 
        AND table_schema = 'public'
    ) THEN
        -- إضافة عمود user_role إذا لم يكن موجوداً
        ALTER TABLE public.profiles ADD COLUMN user_role TEXT DEFAULT 'investor';
        RAISE NOTICE 'تم إضافة عمود user_role إلى جدول profiles';
    ELSE
        RAISE NOTICE 'عمود user_role موجود بالفعل في جدول profiles';
    END IF;
END $$;

-- إزالة عمود account_type إذا كان موجوداً (لأننا نستخدم user_role)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'account_type' 
        AND table_schema = 'public'
    ) THEN
        -- نسخ البيانات من account_type إلى user_role إذا لم تكن موجودة
        UPDATE public.profiles 
        SET user_role = account_type 
        WHERE user_role IS NULL OR user_role = 'investor';
        
        -- إزالة عمود account_type
        ALTER TABLE public.profiles DROP COLUMN account_type;
        RAISE NOTICE 'تم إزالة عمود account_type من جدول profiles';
    ELSE
        RAISE NOTICE 'عمود account_type غير موجود في جدول profiles';
    END IF;
END $$;

-- إنشاء فهرس على user_role إذا لم يكن موجوداً
CREATE INDEX IF NOT EXISTS idx_profiles_user_role ON public.profiles(user_role);

-- إنشاء فهرس على email إذا لم يكن موجوداً
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- تفعيل RLS إذا لم يكن مفعلاً
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسات RLS إذا لم تكن موجودة
DO $$
BEGIN
    -- سياسة القراءة
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Allow users to read all profiles'
    ) THEN
        CREATE POLICY "Allow users to read all profiles" ON public.profiles
            FOR SELECT USING (true);
        RAISE NOTICE 'تم إنشاء سياسة القراءة';
    END IF;
    
    -- سياسة الإنشاء
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Allow users to create own profile'
    ) THEN
        CREATE POLICY "Allow users to create own profile" ON public.profiles
            FOR INSERT WITH CHECK (auth.uid() = id);
        RAISE NOTICE 'تم إنشاء سياسة الإنشاء';
    END IF;
    
    -- سياسة التحديث
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Allow users to update own profile'
    ) THEN
        CREATE POLICY "Allow users to update own profile" ON public.profiles
            FOR UPDATE USING (auth.uid() = id);
        RAISE NOTICE 'تم إنشاء سياسة التحديث';
    END IF;
    
    -- سياسة الحذف
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND policyname = 'Allow users to delete own profile'
    ) THEN
        CREATE POLICY "Allow users to delete own profile" ON public.profiles
            FOR DELETE USING (auth.uid() = id);
        RAISE NOTICE 'تم إنشاء سياسة الحذف';
    END IF;
END $$;

-- التحقق من النتيجة النهائية
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position; 