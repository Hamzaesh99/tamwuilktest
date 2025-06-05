import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// استيراد للصفحة التالية
import 'project_create_details_screen.dart';

class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen(
      {super.key}); // Updated to use super parameter syntax

  @override
  State<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  // مفتاح للفورم للتحقق من البيانات
  final _formKey = GlobalKey<FormState>();

  // بيانات المشروع
  String _projectName = '';
  String _amount = '';
  String _description = '';
  String _category = 'عقاري'; // القيمة الافتراضية للتخصص
  String _city = ''; // حقل المدينة
  bool _singleInvestor = true; // مستثمر واحد فقط

  // ملفات المشروع
  File? _pdfFile;
  File? _videoFile;
  final List<File> _imageFiles = [];
  VideoPlayerController? _videoPlayerController;
  bool _isVideoPlaying = false;

  // قائمة التخصصات
  final List<String> _categories = [
    'عقاري',
    'زراعة',
    'تكنولوجيا المعلومات',
    'صحة',
    'تعليم',
    'سياحة',
    'بيئة',
    'فن',
    'رياضة',
    'خدمات',
    'صناعة النفط والغاز',
    'صناعات غذائية',
    'صناعات دوائية',
    'مقاولات وبناء',
    'تصميم الجرافيك',
    'الكتابة الإبداعية',
  ];

  // قائمة المدن الليبية
  final List<String> _cities = [
    'طرابلس',
    'بنغازي',
    'مصراتة',
    'الزاوية',
    'صبراتة',
    'زليتن',
    'سبها',
    'سرت',
    'اجدابيا',
    'البيضاء',
    'درنة',
    'طبرق',
    'غريان',
    'الخمس',
    'ترهونة',
    'الكفرة',
    'غدامس',
    'جادو',
    'يفرن',
    'زوارة',
  ];

  @override
  void dispose() {
    // التخلص من مشغل الفيديو عند إغلاق الشاشة
    _videoPlayerController?.dispose();
    super.dispose();
  }

  // اختيار ملف PDF
  Future<void> _pickPdf() async {
    if (kIsWeb) {
      _showErrorDialog('اختيار الملفات غير مدعوم في نسخة الويب');
      return;
    }

    try {
      final XTypeGroup pdfGroup = XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: [pdfGroup],
      );

      if (file != null) {
        setState(() {
          _pdfFile = File(file.path);
        });
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء اختيار الملف: $e');
    }
  }

  // حذف ملف PDF
  void _removePdf() {
    setState(() {
      _pdfFile = null;
    });
  }

  // اختيار فيديو
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final duration = await _getVideoDuration(file);

      if (duration.inSeconds <= 30) {
        setState(() {
          _videoFile = file;
          _videoPlayerController?.dispose();
          _videoPlayerController = VideoPlayerController.file(_videoFile!)
            ..initialize().then((_) {
              setState(() {});
            });
        });
      } else {
        _showErrorDialog('يجب أن يكون الفيديو أقل من 30 ثانية.');
      }
    }
  }

  // حذف الفيديو
  void _removeVideo() {
    setState(() {
      _videoFile = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    });
  }

  // تشغيل/إيقاف الفيديو
  void _toggleVideoPlayback() {
    setState(() {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
        _isVideoPlaying = false;
      } else {
        _videoPlayerController!.play();
        _isVideoPlaying = true;
      }
    });
  }

  // الحصول على مدة الفيديو
  Future<Duration> _getVideoDuration(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    final duration = controller.value.duration;
    controller.dispose();
    return duration;
  }

  // اختيار صور من المعرض
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // التقاط صورة من الكاميرا
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  // حذف صورة محددة
  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  // عرض رسالة خطأ
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  // التحقق وإرسال النموذج
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // الانتقال إلى الشاشة التالية مع تمرير البيانات
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectCreateDetailsScreen(
            projectName: _projectName,
            amount: _amount,
            description: _description,
            projectCategory: _category,
            city: _city,
            singleInvestor: _singleInvestor,
            investors: _singleInvestor ? 1 : 0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد الألوان بناءً على ثيم التطبيق
    const primaryColor = Color(0xFF009688);
    final backgroundColor = Colors.grey[50];
    const cardColor = Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('إنشاء مشروع جديد',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // بطاقة معلومات المشروع الأساسية
              _buildSectionCard(
                title: 'معلومات المشروع الأساسية',
                icon: Icons.business,
                color: primaryColor,
                cardColor: cardColor,
                children: [
                  // اسم المشروع
                  _buildTextField(
                    labelText: 'اسم المشروع',
                    hintText: 'أدخل اسم المشروع',
                    icon: Icons.business_center,
                    validator: (value) => value == null || value.isEmpty
                        ? 'يرجى إدخال اسم المشروع'
                        : null,
                    onChanged: (value) => _projectName = value,
                  ),
                  const SizedBox(height: 16),

                  // تخصص المشروع
                  _buildDropdownField(
                    labelText: 'تخصص المشروع',
                    icon: Icons.category,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    value: _category,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // المبلغ المطلوب
                  _buildTextField(
                    labelText: 'المبلغ المطلوب (د.ل)',
                    hintText: 'أدخل المبلغ المطلوب',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'يرجى إدخال المبلغ المطلوب'
                        : null,
                    onChanged: (value) => _amount = value,
                  ),
                  const SizedBox(height: 16),

                  // وصف المشروع
                  _buildTextField(
                    labelText: 'وصف المشروع',
                    hintText: 'أدخل وصف تفصيلي للمشروع',
                    icon: Icons.description,
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty
                        ? 'يرجى إدخال وصف للمشروع'
                        : null,
                    onChanged: (value) => _description = value,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // بطاقة معلومات المستثمر
              _buildSectionCard(
                title: 'معلومات المستثمر',
                icon: Icons.person,
                color: primaryColor,
                cardColor: cardColor,
                children: [
                  // المدينة
                  _buildDropdownField(
                    labelText: 'المدينة',
                    icon: Icons.location_city,
                    hint: 'اختر المدينة',
                    items: _cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    value: _city.isEmpty ? null : _city,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _city = value;
                        });
                      }
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'يرجى اختيار المدينة'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // مستثمر واحد فقط
                  _buildSwitchListTile(
                    title: 'مستثمر واحد فقط',
                    subtitle: 'هذا المشروع مخصص لمستثمر واحد فقط',
                    value: _singleInvestor,
                    onChanged: (value) {
                      setState(() {
                        _singleInvestor = value;
                      });
                    },
                    activeColor: primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // بطاقة ملفات المشروع
              _buildSectionCard(
                title: 'ملفات المشروع',
                icon: Icons.folder_open,
                color: primaryColor,
                cardColor: cardColor,
                children: [
                  // ملف PDF
                  _buildAttachmentSection(
                    title: 'ملف PDF (اختياري)',
                    subtitle: 'أضف ملف PDF يحتوي على تفاصيل إضافية عن المشروع',
                    icon: Icons.picture_as_pdf,
                    file: _pdfFile,
                    onPickPressed: _pickPdf,
                    onRemovePressed: _removePdf,
                    buttonText: 'اختيار ملف PDF',
                  ),
                  const SizedBox(height: 16),

                  // فيديو المشروع
                  _buildAttachmentSection(
                    title: 'فيديو المشروع (اختياري)',
                    subtitle: 'أضف فيديو قصير عن المشروع (بحد أقصى 30 ثانية)',
                    icon: Icons.videocam,
                    file: _videoFile,
                    onPickPressed: _pickVideo,
                    onRemovePressed: _removeVideo,
                    buttonText: 'اختيار فيديو',
                  ),

                  // عرض الفيديو إذا كان موجوداً
                  if (_videoPlayerController != null &&
                      _videoPlayerController!.value.isInitialized)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio:
                                  _videoPlayerController!.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController!),
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: _toggleVideoPlayback,
                            backgroundColor: primaryColor
                                .withAlpha(178), // Replaced withOpacity(0.7)
                            mini: true,
                            child: Icon(
                              _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // صور المشروع
                  _buildImagesSection(
                    primaryColor: primaryColor,
                    onPickFromGallery: _pickImages,
                    onTakePhoto: _takePhoto,
                    imageFiles: _imageFiles,
                    onRemoveImage: _removeImage,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // زر التالي
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  // Added const
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'التالي',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // بناء بطاقة قسم
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  // بناء حقل نص
  Widget _buildTextField({
    required String labelText,
    required String hintText,
    required IconData icon,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
    );
  }

  // بناء حقل قائمة منسدلة
  Widget _buildDropdownField({
    required String labelText,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    FormFieldValidator<String?>? validator,
    String? hint,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
      ),
      hint: hint != null ? Text(hint) : null,
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
    );
  }

  // بناء مفتاح تبديل مع وصف
  Widget _buildSwitchListTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // بناء قسم المرفقات (PDF & فيديو)
  Widget _buildAttachmentSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onPickPressed,
    required VoidCallback onRemovePressed,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF009688)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onPickPressed,
            icon: const Icon(Icons.upload_file),
            label: Text(buttonText),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF009688),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          if (file != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF009688)
                    .withAlpha(25), // Replaced withOpacity(0.1)
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF009688),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تم اختيار الملف: ${file.path.split('/').last}',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onRemovePressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // بناء قسم الصور
  Widget _buildImagesSection({
    required Color primaryColor,
    required VoidCallback onPickFromGallery,
    required VoidCallback onTakePhoto,
    required List<File> imageFiles,
    required Function(int) onRemoveImage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image, color: Color(0xFF009688)),
              SizedBox(width: 8),
              Text(
                'صور المشروع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'أضف صور توضيحية للمشروع (يمكنك إضافة أكثر من صورة)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('اختيار من المعرض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTakePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('التقاط صورة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (imageFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'الصور المختارة (${imageFiles.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageFiles.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            imageFiles[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => onRemoveImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
