# إعداد قاعدة البيانات - حل مشكلة عمود email

## المشكلة
كان هناك خطأ في التطبيق يشير إلى أن عمود 'email' غير موجود في جدول 'profiles' في Supabase.

## السبب
كان هناك تضارب في أسماء الأعمدة في الكود:
- في بعض الأماكن يتم استخدام `account_type`
- في أماكن أخرى يتم استخدام `user_role`
- عمود `email` لم يكن موجوداً في جدول `profiles`

## الحل

### 1. تنفيذ مخطط قاعدة البيانات الصحيح

قم بتنفيذ الملف `database_schema.sql` في Supabase SQL Editor:

1. اذهب إلى لوحة تحكم Supabase
2. اختر مشروعك
3. اذهب إلى SQL Editor
4. انسخ محتوى ملف `database_schema.sql`
5. اضغط على "Run" لتنفيذ الأوامر

### 2. التحقق من إنشاء الجداول

بعد تنفيذ المخطط، تأكد من وجود الجداول التالية:

```sql
-- التحقق من وجود جدول profiles
SELECT * FROM information_schema.tables 
WHERE table_name = 'profiles' AND table_schema = 'public';

-- التحقق من أعمدة جدول profiles
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profiles' AND table_schema = 'public';
```

### 3. التحقق من سياسات RLS

```sql
-- التحقق من سياسات RLS لجدول profiles
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'profiles';
```

## التغييرات التي تمت في الكود

### 1. ملف `user_provider.dart`
- تم تغيير `account_type` إلى `user_role`
- تم إصلاح تضارب أسماء الأعمدة

### 2. ملف `account_verification_service.dart`
- تم تغيير `account_type` إلى `user_role`
- تم إصلاح استعلامات قاعدة البيانات

### 3. ملف `auth_service.dart`
- تم تغيير `account_type` إلى `user_role`

### 4. ملف `login_screen.dart`
- تم تغيير `account_type` إلى `user_role`

## هيكل جدول profiles الجديد

```sql
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
```

## اختبار الحل

### 1. اختبار إنشاء ملف شخصي جديد

```dart
// في التطبيق، جرب تسجيل مستخدم جديد
// يجب أن يتم إنشاء ملف شخصي تلقائياً
```

### 2. اختبار قراءة الملف الشخصي

```dart
// جرب تسجيل الدخول بمستخدم موجود
// يجب أن يتم قراءة الملف الشخصي بنجاح
```

### 3. اختبار تحديث الملف الشخصي

```dart
// جرب تحديث معلومات المستخدم
// يجب أن يتم التحديث بنجاح
```

## ملاحظات مهمة

1. **Trigger تلقائي**: تم إنشاء trigger لإنشاء ملف شخصي تلقائياً عند تسجيل مستخدم جديد
2. **RLS مفعل**: تم تفعيل Row Level Security لحماية البيانات
3. **فهارس**: تم إنشاء فهارس للبحث السريع
4. **قيم افتراضية**: تم تعيين قيم افتراضية مناسبة

## استكشاف الأخطاء

إذا استمرت المشكلة:

1. تحقق من تنفيذ مخطط قاعدة البيانات بشكل صحيح
2. تحقق من سياسات RLS
3. تحقق من وجود Trigger `on_auth_user_created`
4. تحقق من سجلات الأخطاء في Supabase

## أوامر مفيدة للتحقق

```sql
-- التحقق من وجود Trigger
SELECT trigger_name, event_manipulation, event_object_table 
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- التحقق من وجود الدوال
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name IN ('handle_new_user', 'update_updated_at_column');

-- اختبار إنشاء مستخدم جديد
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES (gen_random_uuid(), 'test@example.com', 'encrypted_password', NOW(), NOW(), NOW());
``` 