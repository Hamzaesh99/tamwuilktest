# تطبيق تمويلك

تطبيق Flutter لتمويل المشاريع مع دعم Supabase وصلاحيات Row Level Security (RLS).

## مقدمة

هذا الدليل يشرح كيفية استخدام Supabase في تطبيق تمويلك مع تطبيق صلاحيات Row Level Security (RLS).

## إعداد Supabase

### 1. تثبيت المكتبات

تم إضافة مكتبة Supabase في ملف `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^1.10.6
```

### 2. تهيئة Supabase

تم تهيئة Supabase في ملف `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT_ID.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );
  runApp(MyApp());
}
```

## هيكل قاعدة البيانات

### جداول قاعدة البيانات

1. **profiles**: معلومات المستخدمين
   - `id`: معرف المستخدم (مرتبط بـ auth.users)
   - `email`: البريد الإلكتروني
   - `name`: اسم المستخدم
   - `user_role`: دور المستخدم (investor, project_owner, admin)
   - `created_at`: تاريخ الإنشاء
   - `is_premium`: حالة الاشتراك المدفوع

2. **projects**: المشاريع
   - `id`: معرف المشروع
   - `title`: عنوان المشروع
   - `description`: وصف المشروع
   - `category`: تصنيف المشروع
   - `image_url`: رابط صورة المشروع
   - `funding_goal`: هدف التمويل
   - `current_funding`: التمويل الحالي
   - `status`: حالة المشروع (pending, active, funded, completed)
   - `owner_id`: معرف مالك المشروع
   - `created_at`: تاريخ الإنشاء
   - `city`: المدينة
   - `single_investor`: قبول مستثمر واحد فقط
   - `investors`: قائمة معرفات المستثمرين

3. **offers**: عروض الاستثمار
   - `id`: معرف العرض
   - `investor_id`: معرف المستثمر
   - `project_id`: معرف المشروع
   - `amount`: مبلغ العرض
   - `message`: رسالة العرض
   - `status`: حالة العرض (pending, accepted, rejected)
   - `created_at`: تاريخ الإنشاء

4. **comments**: التعليقات
   - `id`: معرف التعليق
   - `user_id`: معرف المستخدم
   - `project_id`: معرف المشروع
   - `content`: محتوى التعليق
   - `created_at`: تاريخ الإنشاء
   - `likes`: قائمة معرفات المستخدمين الذين أعجبوا بالتعليق

5. **subscriptions**: الاشتراكات المدفوعة
   - `id`: معرف الاشتراك
   - `user_id`: معرف المستخدم
   - `plan`: نوع الخطة
   - `start_date`: تاريخ بداية الاشتراك
   - `end_date`: تاريخ نهاية الاشتراك
   - `status`: حالة الاشتراك (active, cancelled)

## سياسات RLS

### 1. جدول profiles

```sql
-- السماح للمستخدمين بقراءة جميع الملفات الشخصية
CREATE POLICY "Allow users to read all profiles" ON profiles
  FOR SELECT USING (true);

-- السماح للمستخدمين بتحديث ملفاتهم الشخصية فقط
CREATE POLICY "Allow users to update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
```

### 2. جدول projects

```sql
-- السماح للجميع بقراءة المشاريع
CREATE POLICY "Allow public to read projects" ON projects
  FOR SELECT USING (true);

-- السماح لمالك المشروع بتحديث مشروعه
CREATE POLICY "Allow project owners to update their projects" ON projects
  FOR UPDATE USING (auth.uid() = owner_id);

-- السماح لمالك المشروع بحذف مشروعه
CREATE POLICY "Allow project owners to delete their projects" ON projects
  FOR DELETE USING (auth.uid() = owner_id);

-- السماح للمستخدمين بإنشاء مشاريع جديدة
CREATE POLICY "Allow authenticated users to create projects" ON projects
  FOR INSERT WITH CHECK (auth.uid() = owner_id);
```

### 3. جدول offers

```sql
-- السماح للجميع بقراءة العروض
CREATE POLICY "Allow public to read offers" ON offers
  FOR SELECT USING (true);

-- السماح للمستثمرين بإنشاء عروض جديدة
CREATE POLICY "Allow investors to create offers" ON offers
  FOR INSERT WITH CHECK (auth.uid() = investor_id);

-- السماح للمستثمرين بتحديث عروضهم
CREATE POLICY "Allow investors to update their offers" ON offers
  FOR UPDATE USING (auth.uid() = investor_id);

-- السماح للمستثمرين بحذف عروضهم
CREATE POLICY "Allow investors to delete their offers" ON offers
  FOR DELETE USING (auth.uid() = investor_id);
```

### 4. جدول comments

```sql
-- السماح للجميع بقراءة التعليقات
CREATE POLICY "Allow public to read comments" ON comments
  FOR SELECT USING (true);

-- السماح للمستخدمين بإنشاء تعليقات جديدة
CREATE POLICY "Allow authenticated users to create comments" ON comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- السماح للمستخدمين بتحديث تعليقاتهم
CREATE POLICY "Allow users to update their comments" ON comments
  FOR UPDATE USING (auth.uid() = user_id);

-- السماح للمستخدمين بحذف تعليقاتهم
CREATE POLICY "Allow users to delete their comments" ON comments
  FOR DELETE USING (auth.uid() = user_id);
```

### 5. جدول subscriptions

```sql
-- السماح للمستخدمين بقراءة اشتراكاتهم فقط
CREATE POLICY "Allow users to read their subscriptions" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- السماح للمستخدمين بإنشاء اشتراكات جديدة
CREATE POLICY "Allow authenticated users to create subscriptions" ON subscriptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- السماح للمستخدمين بتحديث اشتراكاتهم
CREATE POLICY "Allow users to update their subscriptions" ON subscriptions
  FOR UPDATE USING (auth.uid() = user_id);
```

## أمثلة عملية لاستخدام خدمة Supabase

### 1. تسجيل مستخدم جديد

```dart
Future<void> signUp(String email, String password, String role) async {
  try {
    // تسجيل المستخدم في نظام المصادقة
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    
    if (response.error != null) {
      throw response.error!;
    }
    
    final userId = response.user!.id;
    
    // إنشاء سجل في جدول profiles
    await supabase.from('profiles').insert({
      'id': userId,
      'email': email,
      'user_role': role,
      'created_at': DateTime.now().toIso8601String(),
    });
    
  } catch (e) {
    LoggerService.error('Error during sign up: $e');
    rethrow;
  }
}
```

### 2. إنشاء مشروع جديد

```dart
Future<void> createProject(Project project) async {
  try {
    final userId = supabase.auth.currentUser!.id;
    
    // التأكد من أن المستخدم هو مالك المشروع
    project.ownerId = userId;
    
    final response = await supabase
        .from('projects')
        .insert(project.toMap())
        .select();
    
    if (response.error != null) {
      throw response.error!;
    }
    
  } catch (e) {
    LoggerService.error('Error creating project: $e');
    rethrow;
  }
}
```

### 3. تقديم عرض استثماري

```dart
Future<void> submitOffer(Offer offer) async {
  try {
    final userId = supabase.auth.currentUser!.id;
    
    // التأكد من أن المستخدم هو المستثمر
    offer.investorId = userId;
    
    final response = await supabase
        .from('offers')
        .insert(offer.toMap())
        .select();
    
    if (response.error != null) {
      throw response.error!;
    }
    
  } catch (e) {
    LoggerService.error('Error submitting offer: $e');
    rethrow;
  }
}
```

### 4. إضافة تعليق على مشروع

```dart
Future<void> addComment(Comment comment) async {
  try {
    final userId = supabase.auth.currentUser!.id;
    
    // التأكد من أن المستخدم هو صاحب التعليق
    comment.userId = userId;
    
    final response = await supabase
        .from('comments')
        .insert(comment.toMap())
        .select();
    
    if (response.error != null) {
      throw response.error!;
    }
    
  } catch (e) {
    LoggerService.error('Error adding comment: $e');
    rethrow;
  }
}
```
