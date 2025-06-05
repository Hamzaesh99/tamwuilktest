import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tamwuilktest/core/shared/constants/app_colors.dart';
import 'package:tamwuilktest/core/shared/models/project_model.dart';
import 'package:tamwuilktest/core/shared/models/offer_model.dart';
import 'package:tamwuilktest/core/shared/models/comment_model.dart';
import 'package:tamwuilktest/core/shared/models/user_model.dart' as user_model;
import 'package:tamwuilktest/core/shared/utils/user_role_manager.dart';
// Removed unused state_manager import

// فئة Message لتمثيل الرسائل في الدردشة
class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  Message({required this.text, required this.isMe, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final user_model.User? currentUser;
  final int? initialTabIndex;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    this.currentUser,
    this.initialTabIndex,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLiked = false;
  final List<Comment> comments = [];
  final List<Offer> offers = [];
  final List<Message> messages = [];
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _offerAmountController = TextEditingController();
  final TextEditingController _offerMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // تعيين التبويب الافتراضي إذا تم تحديده
    if (widget.initialTabIndex != null) {
      _tabController.index = widget.initialTabIndex!;
    }

    // هنا يمكن تحميل البيانات من قاعدة البيانات
    // مثل التعليقات والعروض والإعجابات
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _offerAmountController.dispose();
    _offerMessageController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      isLiked = !isLiked;
    });
    // Implementar lógica para guardar en favoritos
  }

  void _investInProject() {
    // Verificar si el usuario tiene permiso para invertir
    if (UserRoleManager.canInvest(widget.currentUser)) {
      // Navegar a la pantalla de inversión
      Navigator.pushNamed(context, '/invest', arguments: widget.project);
    } else {
      UserRoleManager.showAccessDeniedMessage(context, 'make_offer');
    }
  }

  void _contactOwner() {
    // Abrir chat con el dueño del proyecto
    // Navigator.pushNamed(context, '/chat', arguments: widget.project.ownerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProjectHeader(),
                  const SizedBox(height: 24),
                  _buildFundingProgress(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildUpdatesTab(),
                _buildCommentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.project.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.project.imageUrl.isNotEmpty
                ? Image.network(widget.project.imageUrl, fit: BoxFit.cover)
                : Image.asset(
                    'assets/images/project_placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x8A000000)],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // Implementar compartir
          },
        ),
      ],
    );
  }

  Widget _buildProjectHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.project.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.project.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Creado ${timeago.format(widget.project.createdAt)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),
        Text(
          widget.project.description,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFundingProgress() {
    final double progressPercent = widget.project.fundingPercentage / 100;
    final bool isFunded = widget.project.isFunded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${widget.project.currentFunding.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'de \$${widget.project.fundingGoal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 12,
          percent: progressPercent > 1.0 ? 1.0 : progressPercent,
          backgroundColor: Colors.grey[300],
          progressColor: isFunded ? AppColors.success : AppColors.primary,
          barRadius: const Radius.circular(8),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.project.fundingPercentage.toStringAsFixed(1)}% financiado',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.project.status == 'active'
                    ? AppColors.success
                    : widget.project.status == 'pending'
                    ? AppColors.warning
                    : AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.project.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _investInProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Invertir en Proyecto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: _contactOwner,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Contactar',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppColors.primary,
      tabs: const [
        Tab(text: 'Detalles'),
        Tab(text: 'Actualizaciones'),
        Tab(text: 'Comentarios'),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acerca del Proyecto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Información adicional sobre el proyecto estará disponible aquí.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text(
            'Documentos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDocumentItem(
            'Plan de Negocios',
            'PDF',
            Icons.picture_as_pdf,
            Colors.red,
          ),
          const Divider(),
          _buildDocumentItem(
            'Presentación del Proyecto',
            'PPTX',
            Icons.slideshow,
            Colors.orange,
          ),
          const Divider(),
          _buildDocumentItem(
            'Análisis Financiero',
            'XLSX',
            Icons.table_chart,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
    String name,
    String type,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(
          red: color.r * 0.2,
          green: color.g * 0.2,
          blue: color.b * 0.2,
          alpha: 255.0,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(name),
      subtitle: Text(type),
      trailing: const Icon(Icons.download),
      onTap: () {
        // Abrir o descargar documento
      },
    );
  }

  Widget _buildUpdatesTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Ejemplo de 3 actualizaciones
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return _buildUpdateItem(
          'Actualización ${3 - index}',
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla facilisi. Sed euismod, nisl vel ultricies lacinia, nisl nisl aliquam nisl, quis aliquam nisl nisl sit amet nisl.',
          DateTime.now().subtract(Duration(days: index * 7)),
        );
      },
    );
  }

  Widget _buildUpdateItem(String title, String content, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              timeago.format(date),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 5, // Ejemplo de 5 comentarios
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return _buildCommentItem(
                'Usuario ${index + 1}',
                'assets/images/avatar_placeholder.png',
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla facilisi.',
                DateTime.now().subtract(Duration(hours: index * 5)),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Escribe un comentario...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    // Enviar comentario
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(
    String userName,
    String userAvatar,
    String comment,
    DateTime date,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundImage: AssetImage(userAvatar)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    timeago.format(date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment),
            ],
          ),
        ),
      ],
    );
  }
}
