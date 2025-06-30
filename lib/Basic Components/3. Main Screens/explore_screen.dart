import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tamwuilktest/core/shared/constants/app_colors.dart';
import 'package:tamwuilktest/core/shared/utils/user_role_manager.dart';
import 'package:tamwuilktest/core/shared/models/user_model.dart';
import 'package:tamwuilktest/core/shared/utils/user_provider.dart';

import 'notifications_screen.dart';

/// نموذج المشروع
class Project {
  final String id;
  final String title;
  final String description;
  final String amount;
  final double progress;
  final String category;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.progress,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.imageUrl = '',
    required this.createdAt,
  });
}

/// شاشة استكشاف المشاريع
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  ExploreScreenState createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  // حالة الصفحة
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  // تصفية وفرز
  String _selectedCategory = 'جميع التخصصات';
  String _sortBy = 'الأحدث';

  // قائمة المشاريع
  final List<Project> _projects = [];
  bool _hasMoreProjects = true;
  bool _isLoadingMore = false;

  // قائمة التصنيفات
  final List<String> _categories = [
    'جميع التخصصات',
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
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _setupScrollListener();
  }

  Future<void> _initializeScreen() async {
    await _loadProjects();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoadingMore &&
          _hasMoreProjects) {
        _loadMoreProjects();
      }
    });
  }

  Future<void> _loadProjects() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // محاكاة تحميل البيانات
      await Future.delayed(const Duration(seconds: 1));
      final newProjects = _getMockProjects();

      if (!mounted) return;

      setState(() {
        _projects.clear();
        _projects.addAll(newProjects);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'حدث خطأ أثناء تحميل المشاريع';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProjects() async {
    if (_isLoadingMore || !_hasMoreProjects) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      final newProjects = _getMockProjects();

      if (!mounted) return;

      setState(() {
        _projects.addAll(newProjects);
        _isLoadingMore = false;
        _hasMoreProjects = newProjects.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<Project> _getMockProjects() {
    return [
      Project(
        id: DateTime.now().toString(),
        title: 'مشروع تطوير عقاري',
        description:
            'وصف مختصر لمشروع تطوير عقاري يهدف إلى بناء مجمع سكني حديث ومتكامل الخدمات في منطقة حيوية.',
        amount: '500,000 د.ل',
        progress: 0.6,
        category: 'عقاري',
        rating: 4.5,
        reviewCount: 120,
        createdAt: DateTime.now(),
      ),
      Project(
        id: DateTime.now().toString(),
        title: 'مشروع زراعي مستدام',
        description:
            'يهدف المشروع إلى تطبيق تقنيات الزراعة المائية لإنتاج خضروات عضوية عالية الجودة.',
        amount: '300,000 د.ل',
        progress: 0.75,
        category: 'زراعة',
        rating: 4.8,
        reviewCount: 85,
        createdAt: DateTime.now(),
      ),
    ];
  }

  void _onCategoryChanged(String? newCategory) {
    if (newCategory == null || newCategory == _selectedCategory) return;

    setState(() {
      _selectedCategory = newCategory;
      _projects.clear();
      _hasMoreProjects = true;
    });

    _loadProjects();
  }

  void _onSortChanged(String? newSort) {
    if (newSort == null || newSort == _sortBy) return;

    setState(() {
      _sortBy = newSort;
      _projects.clear();
      _hasMoreProjects = true;
    });

    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final userProvider = Provider.of<UserProvider>(context);
    final appUser = userProvider.currentUser;

    // تحويل AppUser إلى User لاستخدامه مع UserRoleManager
    final User? currentUser = appUser != null
        ? User(
            id: appUser.id,
            name: '',
            email: appUser.email,
            createdAt: DateTime.now(),
            userRole: appUser.userRole ?? 'investor',
            accountType: appUser.userRole == 'project_owner'
                ? 'project_owner'
                : 'investor',
          )
        : null;

    final bool isInvestor =
        currentUser != null && UserRoleManager.isInvestor(currentUser);
    final bool isProjectOwner =
        currentUser != null && UserRoleManager.isProjectOwner(currentUser);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        floatingActionButton: _buildFloatingActionButton(
          context,
          isProjectOwner,
        ),
        body: _buildBody(isInvestor, isProjectOwner),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'استكشاف المشاريع',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: AppColors.primary),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    bool isProjectOwner,
  ) {
    if (!isProjectOwner) return null;

    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/create_project'),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildBody(bool isInvestor, bool isProjectOwner) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProjects,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مشاريع متاحة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'جرب تغيير معايير البحث أو عد لاحقاً',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProjects,
              child: const Text('تحديث'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadProjects,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _projects.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _projects.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final project = _projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProjectCard(
                    project: project,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/project-details',
                      arguments: {'project': project},
                    ),
                    isInvestor: isInvestor,
                    isProjectOwner: isProjectOwner,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 13, red: null, green: null, blue: null),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصفية المشاريع',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  'التخصص',
                  _selectedCategory,
                  _categories,
                  _onCategoryChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('ترتيب حسب', _sortBy, const [
                  'الأحدث',
                  'الأقدم',
                  'المبلغ الأعلى',
                  'المبلغ الأقل',
                ], _onSortChanged),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// بطاقة عرض المشروع
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final bool isInvestor;
  final bool isProjectOwner;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.isInvestor,
    required this.isProjectOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildBody(context),
              const SizedBox(height: 16),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 26, red: null, green: null, blue: null),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            project.category,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              project.rating.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              '(${project.reviewCount})',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final Color progressColor = project.progress < 0.3
        ? Colors.red
        : project.progress < 0.7
        ? Colors.orange
        : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          project.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نسبة الإنجاز',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${(project.progress * 100).toInt()}%',
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: project.progress,
            backgroundColor: Colors.grey[200],
            color: progressColor,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المبلغ المطلوب',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              project.amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isInvestor && !isProjectOwner ? 'تقديم عرض' : 'عرض التفاصيل',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
