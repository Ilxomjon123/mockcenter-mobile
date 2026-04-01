import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../widgets/glass_card.dart';
import '../../../utils/date_utils.dart';

class QuickStats extends StatelessWidget {
  final String? nextExamDate;
  final String? averageScore;
  final int completedExamsCount;
  final int pendingPaymentCount;

  const QuickStats({
    super.key,
    this.nextExamDate,
    this.averageScore,
    this.completedExamsCount = 0,
    this.pendingPaymentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_month_rounded,
            iconColor: AppColors.primary500,
            label: 'NEXT EXAM',
            value: nextExamDate != null
                ? _formatDate(nextExamDate!)
                : 'No exam',
            valueColor: nextExamDate != null ? null : colors.textMuted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.amber600,
            label: 'AVG SCORE',
            value: averageScore != null ? 'Band $averageScore' : 'No results',
            valueColor: averageScore != null ? null : colors.textMuted,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = parseTashkentDate(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    } catch (_) {
      return dateStr;
    }
  }
}

class QuickStatsRow2 extends StatelessWidget {
  final int completedExamsCount;
  final int pendingPaymentCount;

  const QuickStatsRow2({
    super.key,
    this.completedExamsCount = 0,
    this.pendingPaymentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
            label: 'COMPLETED',
            value: '$completedExamsCount ${completedExamsCount == 1 ? "exam" : "exams"}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.credit_card_rounded,
            iconColor: pendingPaymentCount > 0 ? AppColors.amber600 : colors.textMuted,
            label: 'PAYMENTS',
            value: pendingPaymentCount > 0 ? '$pendingPaymentCount pending' : 'All clear',
            valueColor: pendingPaymentCount > 0 ? AppColors.amber600 : colors.textMuted,
            borderColor: pendingPaymentCount > 0 ? AppColors.amber400.withValues(alpha: 0.3) : null,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? borderColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
