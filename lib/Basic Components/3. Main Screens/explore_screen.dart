import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tamwuilktest/core/shared/constants/app_colors.dart';
import 'package:tamwuilktest/core/shared/utils/user_role_manager.dart';
import 'package:tamwuilktest/core/shared/utils/state_manager.dart';
import 'package:tamwuilktest/core/shared/models/user_model.dart';

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
    final User? currentUser = userProvider.currentUser;

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

    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildFilters(),
          _buildProjectsList(isInvestor, isProjectOwner),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCategoryFilter(),
            const SizedBox(height: 12),
            _buildSortFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'تصفية حسب التخصص',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _categories.map((category) {
          return DropdownMenuItem(value: category, child: Text(category));
        }).toList(),
        onChanged: _onCategoryChanged,
      ),
    );
  }

  Widget _buildSortFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _sortBy,
        decoration: InputDecoration(
          labelText: 'ترتيب حسب',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: const [
          DropdownMenuItem(value: 'الأحدث', child: Text('الأحدث')),
          DropdownMenuItem(value: 'الأقدم', child: Text('الأقدم')),
          DropdownMenuItem(
            value: 'الأعلى تقييماً',
            child: Text('الأعلى تقييماً'),
          ),
          DropdownMenuItem(
            value: 'الأكثر تمويلاً',
            child: Text('الأكثر تمويلاً'),
          ),
        ],
        onChanged: _onSortChanged,
      ),
    );
  }

  Widget _buildProjectsList(bool isInvestor, bool isProjectOwner) {
    if (_projects.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'لا توجد مشاريع متاحة حالياً',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ProjectCard(
              project: _projects[index],
              isInvestor: isInvestor,
              isProjectOwner: isProjectOwner,
              onTap: () => _navigateToProjectDetails(
                context,
                _projects[index],
                isInvestor,
                isProjectOwner,
              ),
            ),
          );
        }, childCount: _projects.length),
      ),
    );
  }

  void _navigateToProjectDetails(
    BuildContext context,
    Project project,
    bool isInvestor,
    bool isProjectOwner,
  ) {
    Navigator.pushNamed(
      context,
      '/project_details',
      arguments: {
        'project': project,
        'canInvest': isInvestor && !isProjectOwner,
      },
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
  final bool isInvestor;
  final bool isProjectOwner;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.isInvestor,
    required this.isProjectOwner,
    required this.onTap,
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
              _buildDescription(),
              const SizedBox(height: 16),
              _buildProgress(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  project.category,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                project.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.star, size: 16, color: Colors.amber.shade800),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      project.description,
      style: TextStyle(color: Colors.grey[600], height: 1.5),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgress() {
    final progressPercentage = (project.progress * 100).toInt();
    Color progressColor = AppColors.primary;

    if (progressPercentage < 30) {
      progressColor = Colors.red.shade400;
    } else if (progressPercentage < 70) {
      progressColor = Colors.orange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('التمويل المكتمل', style: TextStyle(color: Colors.grey[600])),
            Text(
              '$progressPercentage%',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
