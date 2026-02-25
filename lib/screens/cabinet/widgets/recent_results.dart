import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../models/result.dart';
import '../../../widgets/glass_card.dart';

class RecentResults extends StatelessWidget {
  final List<ExamResult> results;
  final VoidCallback? onViewAll;

  const RecentResults({
    super.key,
    required this.results,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Results',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...results.take(2).map((result) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ResultCard(result: result),
        )),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ExamResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final examDate = DateTime.parse(result.exam.datetime);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(examDate),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    result.exam.type == 'ielts' ? 'IELTS' : 'CEFR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result.overall,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'OVERALL',
                    style: TextStyle(
                      fontSize: 9,
                      color: colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ScoreChip(label: 'L', value: result.listeningScore),
              const SizedBox(width: 8),
              _ScoreChip(label: 'R', value: result.readingScore),
              const SizedBox(width: 8),
              _ScoreChip(label: 'W', value: result.writingScore),
              const SizedBox(width: 8),
              _ScoreChip(label: 'S', value: result.speakingScore),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final String? value;

  const _ScoreChip({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        children: [
          Text(
            value ?? '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
