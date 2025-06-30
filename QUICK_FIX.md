# حل سريع لمشكلة عمود email

## المشكلة
```
خطأ في إنشاء ملف تعريف المستخدم: PostgrestException(message: Could not find the 'email' column of 'profiles' in the schema cache, code: PGRST204, details: Bad Request, hint: null)
```

## الحل السريع

### الخطوة 1: تنفيذ إصلاح قاعدة البيانات

1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. اذهب إلى **SQL Editor**
4. انسخ محتوى ملف `fix_profiles_table.sql`
5. اضغط **Run**

### الخطوة 2: التحقق من النتيجة

بعد تنفيذ الملف، يجب أن ترى رسائل مثل:
- `تم إضافة عمود email إلى جدول profiles`
- `تم إضافة عمود user_role إلى جدول profiles`
- `تم إنشاء سياسة القراءة`

### الخطوة 3: اختبار التطبيق

1. أعد تشغيل التطبيق
2. جرب تسجيل مستخدم جديد
3. يجب أن تعمل بدون أخطاء

## إذا استمرت المشكلة

### تحقق من هيكل الجدول

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public';
```

### تحقق من سياسات RLS

```sql
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'profiles';
```

## التغييرات التي تمت في الكود

✅ تم إصلاح `user_provider.dart`
✅ تم إصلاح `account_verification_service.dart`
✅ تم إصلاح `auth_service.dart`
✅ تم إصلاح `login_screen.dart`

جميع الملفات الآن تستخدم `user_role` بدلاً من `account_type`.

## ملاحظة مهمة

إذا كان لديك بيانات موجودة في عمود `account_type`، سيتم نسخها تلقائياً إلى `user_role` عند تنفيذ الإصلاح. 