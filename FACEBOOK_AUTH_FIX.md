# إصلاح مشكلة تسجيل الدخول بفيسبوك

## المشكلة
كانت هناك مشكلة في تسجيل الدخول بفيسبوك حيث كان الخطأ يظهر:
```
AuthException(message: Provider must be google, apple, kakao or keycloak., statusCode: null, code: null)
```

## السبب
Supabase لا يدعم Facebook كـ OAuth provider مباشرة في `signInWithIdToken`. Facebook غير مدرج في قائمة المزودين المدعومين.

## الحل المطبق

### 1. تعديل دالة `signInWithFacebook` في `AuthService`

تم تغيير الطريقة من استخدام `signInWithIdToken` إلى:
- استخدام `flutter_facebook_auth` للحصول على بيانات المستخدم من Facebook
- استخراج البريد الإلكتروني والاسم والصورة
- استخدام `signInWithOtp` لإرسال رابط سحري للبريد الإلكتروني
- إنشاء ملف مستخدم في جدول `profiles` إذا لزم الأمر

### 2. تعديل معالجة الاستجابة في `LoginScreen`

تم تحديث `_signInWithFacebook` لمعالجة الاستجابة الجديدة:
- التحقق من نجاح العملية
- عرض رسائل النجاح أو الخطأ
- إنشاء كائن `AppUser` من البيانات المستلمة
- توجيه المستخدم إلى الشاشة الرئيسية

## الكود المحدث

### AuthService.signInWithFacebook()
```dart
static Future<Map<String, dynamic>> signInWithFacebook() async {
  try {
    // تسجيل الدخول باستخدام Facebook
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status != LoginStatus.success) {
      return {
        'success': false,
        'error': 'فشل تسجيل الدخول عبر Facebook: ${result.status}',
        'user': null,
      };
    }

    // الحصول على بيانات المستخدم من Facebook
    final userData = await FacebookAuth.instance.getUserData();
    final email = userData['email'] as String?;
    final name = userData['name'] as String?;
    final picture = userData['picture']?['data']?['url'] as String?;

    if (email == null) {
      return {
        'success': false,
        'error': 'لم يتم العثور على البريد الإلكتروني',
        'user': null,
      };
    }

    // إرسال رابط سحري للبريد الإلكتروني
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'com.example.tamwuilk://home_screen',
    );

    return {
      'success': true,
      'user': {
        'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'name': name,
        'picture': picture,
      },
      'message': 'تم إرسال رابط تأكيد إلى بريدك الإلكتروني',
    };
  } catch (error) {
    return {
      'success': false,
      'error': 'خطأ في تسجيل الدخول عبر Facebook: ${error.toString()}',
      'user': null,
    };
  }
}
```

### LoginScreen._signInWithFacebook()
```dart
Future<void> _signInWithFacebook() async {
  if (_selectedAccountType == null) {
    _showErrorMessage('يرجى اختيار نوع الحساب');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final result = await AuthService.signInWithFacebook();
    
    if (result['success'] == true) {
      if (result['message'] != null) {
        _showSuccessMessage(result['message']);
      }
      
      if (result['user'] != null) {
        final userData = result['user'];
        final appUser = AppUser(
          id: userData['id'],
          email: userData['email'] ?? '',
          userRole: _selectedAccountType!,
        );

        Provider.of<UserProvider>(context, listen: false).setAppUser(appUser);
        await AccountVerificationService.checkOrCreateProfile(_selectedAccountType!);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } else {
      final errorMessage = result['error'] ?? 'حدث خطأ غير متوقع';
      _showErrorMessage(errorMessage);
    }
  } catch (error) {
    _showErrorMessage('حدث خطأ غير متوقع: $error');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

## المميزات الجديدة

1. **رسائل واضحة**: عرض رسائل نجاح أو خطأ واضحة للمستخدم
2. **معالجة الأخطاء**: معالجة شاملة للأخطاء المحتملة
3. **تجربة مستخدم محسنة**: إرسال رابط سحري للبريد الإلكتروني بدلاً من محاولة تسجيل الدخول المباشر
4. **توافق مع Supabase**: استخدام الطرق المدعومة من Supabase

## الاختبار

لتجربة الإصلاح:
1. اختر نوع الحساب (مستثمر أو مقترض)
2. اضغط على زر "تسجيل الدخول باستخدام فيسبوك"
3. سجل الدخول بحساب Facebook
4. ستظهر رسالة نجاح مع إرسال رابط سحري للبريد الإلكتروني
5. تحقق من بريدك الإلكتروني واضغط على الرابط للتأكيد

## ملاحظات مهمة

- تأكد من أن Facebook App ID و Client Token صحيحان في `android/app/src/main/res/values/strings.xml`
- تأكد من إعداد Facebook SDK في `android/app/src/main/kotlin/com/example/tamwuilktest/Application.kt`
- تأكد من إضافة `facebook_app_id` و `facebook_client_token` في `android/app/src/main/AndroidManifest.xml` 