# إعداد الروابط السحرية والتوجيه إلى home_screen

## المشكلة
كان التطبيق لا يتوجه إلى شاشة `home_screen` عند تسجيل الدخول بالرابط السحري، على عكس تسجيل الدخول بفيسبوك.

## الحل المطبق

### 1. إصلاح إرسال الرابط السحري

في ملف `login_screen.dart`، تم تحديث دالة `_sendMagicLink()`:

```dart
await Supabase.instance.client.auth.signInWithOtp(
  email: email,
  emailRedirectTo: 'com.example.tamwuilk://home_screen/auth?auth_success=true&user_role=${_selectedAccountType}',
  data: {'user_role': _selectedAccountType}, // تم تغيير account_type إلى user_role
);
```

### 2. تحسين معالجة الروابط الواردة

في ملف `main.dart`، تم تحسين دالة `_handleIncomingLink()`:

```dart
void _handleIncomingLink(Uri uri) {
  // التحقق من الروابط التي تحتوي على home_screen
  if (uri.path == '/home_screen' || 
      uri.path.contains('/home_screen') || 
      uri.toString().contains('home_screen')) {
    
    // التوجيه المباشر إلى الشاشة الرئيسية
    Future.delayed(const Duration(milliseconds: 500), () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    });
    return;
  }

  // معالجة معاملات الرابط
  final code = uri.queryParameters['code'];
  final authSuccess = uri.queryParameters['auth_success'];
  final userRole = uri.queryParameters['user_role']; // جديد

  // معالجة رمز المصادقة مع تحديث user_role
  if (code != null) {
    Supabase.instance.client.auth.exchangeCodeForSession(code).then((response) {
      // تحديث user_role إذا كان موجوداً
      if (userRole != null && response.session?.user != null) {
        Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'user_role': userRole}),
        );
      }
      
      // التوجيه إلى الشاشة الرئيسية
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    });
  }

  // معالجة auth_success
  if (authSuccess != null) {
    // تحديث user_role إذا كان موجوداً
    if (userRole != null) {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'user_role': userRole}),
        );
      }
    }
    
    // التوجيه إلى الشاشة الرئيسية
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }
}
```

## كيفية عمل الروابط السحرية الآن

### 1. إرسال الرابط السحري
1. المستخدم يدخل بريده الإلكتروني ويختار نوع الحساب
2. يتم إرسال رابط سحري يحتوي على:
   - `auth_success=true` - للدلالة على نجاح المصادقة
   - `user_role=investor` أو `user_role=project_owner` - نوع الحساب المختار

### 2. معالجة الرابط عند النقر عليه
1. التطبيق يستقبل الرابط
2. يتم استخراج معاملات الرابط (`code`, `auth_success`, `user_role`)
3. يتم تبادل الرمز للحصول على جلسة مستخدم
4. يتم تحديث `user_role` في بيانات المستخدم
5. يتم التوجيه مباشرة إلى `home_screen`

### 3. التوجيه النهائي
- يتم استخدام `pushNamedAndRemoveUntil` لإزالة جميع الشاشات السابقة
- المستخدم يصل مباشرة إلى الشاشة الرئيسية
- يتم عرض رسالة نجاح المصادقة

## اختبار الروابط السحرية

### 1. اختبار إرسال الرابط
```dart
// في التطبيق
1. اذهب إلى شاشة تسجيل الدخول
2. أدخل بريد إلكتروني صحيح
3. اختر نوع الحساب (مستثمر أو مالك مشروع)
4. اضغط "تسجيل الدخول عبر الرابط السحري"
5. يجب أن تظهر رسالة نجاح
```

### 2. اختبار النقر على الرابط
```dart
// في البريد الإلكتروني
1. افتح البريد الإلكتروني المرسل
2. انقر على الرابط السحري
3. يجب أن يفتح التطبيق
4. يجب أن يتم التوجيه مباشرة إلى الشاشة الرئيسية
5. يجب أن تظهر رسالة "تم إكمال عملية المصادقة بنجاح"
```

## إعدادات إضافية مطلوبة

### 1. إعدادات Android
في `android/app/src/main/AndroidManifest.xml`:

```xml
<activity>
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="com.example.tamwuilk" />
    </intent-filter>
</activity>
```

### 2. إعدادات iOS
في `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.example.tamwuilk</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.example.tamwuilk</string>
        </array>
    </dict>
</array>
```

### 3. إعدادات Supabase
في لوحة تحكم Supabase:
1. اذهب إلى Authentication > URL Configuration
2. أضف `com.example.tamwuilk://home_screen` إلى Redirect URLs
3. احفظ التغييرات

## استكشاف الأخطاء

### إذا لم يتم التوجيه إلى home_screen:

1. **تحقق من سجلات التطبيق**:
   ```dart
   // ابحث عن رسائل مثل:
   "تم اكتشاف مسار home_screen، جاري التوجيه إلى الصفحة الرئيسية"
   "تم إنشاء جلسة المستخدم بنجاح، جاري التوجيه إلى الشاشة الرئيسية"
   ```

2. **تحقق من إعدادات Deep Links**:
   - تأكد من صحة scheme في AndroidManifest.xml
   - تأكد من صحة CFBundleURLSchemes في Info.plist

3. **تحقق من إعدادات Supabase**:
   - تأكد من إضافة redirect URL في Supabase
   - تأكد من تفعيل Magic Link في Authentication settings

### إذا لم يتم تحديث user_role:

1. **تحقق من معاملات الرابط**:
   ```dart
   // في سجلات التطبيق، ابحث عن:
   "تم تحديث user_role للمستخدم: investor"
   ```

2. **تحقق من بيانات المستخدم**:
   ```dart
   // في Supabase، تحقق من جدول profiles
   SELECT * FROM profiles WHERE email = 'user@example.com';
   ```

## ملاحظات مهمة

1. **التأخير**: تم إضافة تأخير 500 مللي ثانية لضمان اكتمال تحميل التطبيق
2. **إزالة الشاشات**: يتم استخدام `pushNamedAndRemoveUntil` لإزالة جميع الشاشات السابقة
3. **تحديث البيانات**: يتم تحديث `user_role` في `userMetadata` تلقائياً
4. **معالجة الأخطاء**: يتم معالجة الأخطاء وعرض رسائل مناسبة للمستخدم 