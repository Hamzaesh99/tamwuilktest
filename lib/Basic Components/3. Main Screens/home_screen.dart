import 'package:flutter/material.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart'; // Import provider
import '../../../core/shared/models/project_model.dart';
import '../../../core/shared/widgets/project_card.dart';
import '../../../Routing/app_routes.dart';
import '../../../core/services/supabase_service.dart';
import 'dart:developer';
import '../../../core/shared/utils/user_provider.dart'; // Import UserProvider
import '../../../core/models/app_user.dart'; // Import AppUser model

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabaseService = SupabaseService;
  String selectedCategory = 'جميع التخصصات';
  bool isGuestUser = false;
  final List<String> categories = [
    'جميع التخصصات',
    'تقنية',
    'عقاري',
    'زراعي',
    'صناعي',
    'تجاري',
    'خدمي',
  ];

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _startAutoScroll();
    // تأخير تهيئة WebView حتى نتأكد من حالة المستخدم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isGuestUser) {
        _initializeWebView();
      }
    });
  }

  void _checkUserStatus() {
    final AppUser? currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    setState(() {
      isGuestUser = currentUser?.userRole == 'guest';
    });

    // إذا كان المستخدم زائرًا، نعرض رسالة توضيحية
    if (isGuestUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('مرحبًا بك كزائر! بعض الميزات قد تكون محدودة'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  int _currentPage = 0;
  final PageController _pageController = PageController();
  final List<String> _bannerImages = ['c1.png', 'c2.png', 'c3.png'];
  Timer? _timer;

  late WebViewController _webViewController;
  bool _showWebView = false;

  void _initializeWebView() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                // يمكنك إضافة مؤشر تحميل هنا
              },
              onPageFinished: (String url) {
                // إخفاء مؤشر التحميل هنا
              },
              onWebResourceError: (WebResourceError error) {
                _handleNavigationBack();
              },
            ),
          )
          ..loadFlutterAsset('assets/html/Tamwuilk.html')
          ..addJavaScriptChannel(
            'JavaScriptChannel',
            onMessageReceived: (JavaScriptMessage message) {
              if (message.message == 'goToHomeScreen') {
                _handleNavigationBack();
              }
            },
          );
  }

  void _handleNavigationBack() {
    if (mounted) {
      setState(() => _showWebView = false);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('تم تسجيل الدخول بنجاح!'),
              content: const Text('هل تريد الانتقال إلى الشاشة الرئيسية؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AppRoutes.navigateTo(context, AppRoutes.home);
                  },
                  child: const Text('نعم'),
                ),
              ],
            ),
      );
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/image.png'),
        ),
        title: const Text(''),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          _buildAppBarIcon(Icons.notifications, AppRoutes.notifications),
          _buildAppBarIcon(Icons.person, AppRoutes.profile),
          _buildAppBarIcon(Icons.search, null),
        ],
      ),
      body: Column(
        children: [
          _buildWebViewToggle(),
          _showWebView ? _buildWebView() : _buildBannerSection(),
          _buildCategoryFilter(),
          _buildProjectList(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildAppBarIcon(IconData icon, String? route) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        if (isGuestUser &&
            (route == AppRoutes.notifications || route == AppRoutes.profile)) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('تنبيه'),
                  content: const Text(
                    'يرجى تسجيل الدخول للوصول إلى هذه الميزة',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text('تسجيل الدخول'),
                    ),
                  ],
                ),
          );
        } else if (route != null) {
          AppRoutes.navigateTo(context, route);
        }
      },
    );
  }

  Widget _buildWebViewToggle() {
    // إذا كان المستخدم زائرًا، نعرض رسالة بدلاً من زر التبديل
    if (isGuestUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () {
            // عند النقر، نعرض رسالة للمستخدم الزائر
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'هذه الميزة غير متاحة للزوار. يرجى تسجيل الدخول للوصول إلى جميع الميزات.',
                ),
                duration: Duration(seconds: 3),
              ),
            );
          },
          child: const Text(
            'فتح صفحة تمويلك (متاح للمستخدمين المسجلين فقط)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey, // لون رمادي للإشارة إلى أنه غير متاح
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    }

    // للمستخدمين المسجلين، نعرض زر التبديل كالمعتاد
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap:
            () => setState(() {
              _showWebView = !_showWebView;
              if (_showWebView) _webViewController.reload();
            }),
        child: Text(
          _showWebView ? 'إغلاق الويب فيو' : 'فتح صفحة تمويلك',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.teal,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    // إذا كان المستخدم زائرًا، نعرض رسالة بدلاً من WebView
    if (isGuestUser) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'هذه الميزة غير متاحة للزوار',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'يرجى تسجيل الدخول للوصول إلى جميع ميزات التطبيق',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // للمستخدمين المسجلين، نعرض WebView كالمعتاد
    return Expanded(child: WebViewWidget(controller: _webViewController));
  }

  Widget _buildBannerSection() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemCount: _bannerImages.length,
            itemBuilder:
                (context, index) => Image.asset(
                  'assets/images/${_bannerImages[index]}',
                  fit: BoxFit.cover,
                ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImages.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.teal : Colors.grey.withAlpha(128),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder:
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(categories[index]),
                selected: selectedCategory == categories[index],
                onSelected:
                    (selected) =>
                        setState(() => selectedCategory = categories[index]),
              ),
            ),
      ),
    );
  }

  Widget _buildProjectList() {
    return Expanded(
      child: FutureBuilder(
        future: SupabaseService.select('projects'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }
          return _buildProjectListView(snapshot.data);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: Colors.teal));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'حدث خطأ في تحميل البيانات: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildProjectListView(dynamic data) {
    final projects = List<Map<String, dynamic>>.from(data ?? []);
    if (projects.isEmpty) return _buildEmptyState();

    final filteredProjects =
        selectedCategory == 'جميع التخصصات'
            ? projects
            : projects.where((p) => p['category'] == selectedCategory).toList();

    return ListView.builder(
      itemCount: filteredProjects.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final project = Project.fromMap(filteredProjects[index]);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ProjectCard(
            onTap: () => _navigateToProjectDetails(project),
            project: project,
            onLike: (id) => _handleProjectAction(id, 'like'),
            onComment: (id) => _handleProjectAction(id, 'comment'),
            onOffer: (id) => _handleProjectAction(id, 'offer'),
            onChat: (id) => _handleProjectAction(id, 'chat'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'لا توجد مشاريع متاحة حالياً',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  void _navigateToProjectDetails(Project project) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.projectDetails,
      arguments: {'project': project},
    );
  }

  void _handleProjectAction(String projectId, String action) {
    // يمكنك إضافة المنطق الخاص بكل إجراء هنا
    log('$action action triggered for project $projectId');
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) => _handleBottomNavTap(index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'المشاريع المميزة',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'استكشاف'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'إنشاء',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'الدردشة'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ],
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 1:
        AppRoutes.navigateTo(context, AppRoutes.explore);
        break;
      case 2:
        AppRoutes.navigateTo(context, AppRoutes.createProject);
        break;
      case 3:
        AppRoutes.navigateTo(
          context,
          AppRoutes.chat,
          arguments: {'chatId': 'chat_list'},
        );
        break;
      case 4:
        AppRoutes.navigateTo(context, AppRoutes.settings);
        break;
    }
  }
}
