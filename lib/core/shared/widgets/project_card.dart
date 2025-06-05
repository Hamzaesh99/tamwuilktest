import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/user_role_manager.dart';
import '../utils/state_manager.dart';
import '../models/project_model.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;
  final Function(String) onComment;
  final Function(String) onLike;
  final Function(String) onOffer;
  final Function(String) onChat;
  final bool isLiked;
  final bool canOffer;

  const ProjectCard({
    super.key,  // Proper super parameter syntax
    required this.project,
    required this.onTap,
    required this.onComment,
    required this.onLike,
    required this.onOffer,
    required this.onChat,
    this.isLiked = false,
    this.canOffer = true,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  @override
  Widget build(BuildContext context) {
    // استخدام Provider للحصول على المستخدم الحالي
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    final bool isInvestor = UserRoleManager.isInvestor(currentUser);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المشروع
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                widget.project.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
            // تفاصيل المشروع
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.project.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // شريط التفاعلات (الإعجاب، التعليق، تقديم عرض، الدردشة)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // زر الإعجاب
                  _buildInteractionButton(
                    icon:
                        widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.isLiked ? Colors.red : Colors.grey,
                    label: 'إعجاب',
                    onPressed: () => widget.onLike(widget.project.id),
                  ),
                  // زر التعليق
                  _buildInteractionButton(
                    icon: Icons.comment_outlined,
                    label: 'تعليق',
                    onPressed: () => widget.onComment(widget.project.id),
                  ),
                  // زر تقديم عرض
                  _buildInteractionButton(
                    icon: Icons.attach_money,
                    label: 'تقديم عرض',
                    onPressed: widget.canOffer
                        ? () => widget.onOffer(widget.project.id)
                        : null,
                    color: widget.canOffer ? Colors.green : Colors.grey,
                  ),
                  // زر الدردشة
                  _buildInteractionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'دردشة',
                    onPressed: () => widget.onChat(widget.project.id),
                  ),
                ],
              ),
            ),
            // Add Investor Button
            if (isInvestor)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ElevatedButton(
                  onPressed: () {
                    // استخدام logger بدلاً من print
                    debugPrint('Investor button pressed!');
                    // تنفيذ إجراء المستثمر - تقديم عرض للمشروع
                    widget.onOffer(widget.project.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('تقديم عرض استثماري'),
                ),
              ),
            // مؤشر التقدم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التمويل: ${widget.project.fundingPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      Text(
                        '${widget.project.currentFunding} / ${widget.project.fundingGoal} ر.س',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: widget.project.fundingPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لإنشاء أزرار التفاعل
  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color color = Colors.grey,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 20, color: onPressed == null ? Colors.grey[400] : color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: onPressed == null ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
