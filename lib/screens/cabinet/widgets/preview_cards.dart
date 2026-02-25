import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../services/api_service.dart';
import '../../../widgets/glass_card.dart';

class PreviewCards extends StatelessWidget {
  const PreviewCards({super.key});

  static const _cards = [
    _PreviewItem(
      type: 'listening',
      icon: Icons.headphones_rounded,
      title: 'Listening Preview',
      description: 'Listen to 4 recordings and answer 40 questions.',
    ),
    _PreviewItem(
      type: 'reading',
      icon: Icons.auto_stories_rounded,
      title: 'Reading Preview',
      description: 'Read 3 long texts and answer 40 questions.',
    ),
    _PreviewItem(
      type: 'writing',
      icon: Icons.edit_rounded,
      title: 'Writing Preview',
      description: 'Complete two writing tasks.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Try CD IELTS Interface',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Text(
              'Free preview',
              style: TextStyle(
                fontSize: 11,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            onTap: () => _openPreview(card.type),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.primary100),
                  ),
                  child: Icon(card.icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        card.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new_rounded, size: 16, color: colors.textMuted),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Future<void> _openPreview(String type) async {
    final url = Uri.parse('${ApiService.examBaseUrl}/preview/$type');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _PreviewItem {
  final String type;
  final IconData icon;
  final String title;
  final String description;

  const _PreviewItem({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
  });
}
