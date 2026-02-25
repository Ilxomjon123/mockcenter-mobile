import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_colors_extension.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final int? daysUntilNextExam;

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.daysUntilNextExam,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, $userName',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (daysUntilNextExam != null && daysUntilNextExam! > 0)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: colors.textMuted),
                      children: [
                        const TextSpan(text: 'Next exam in '),
                        TextSpan(
                          text: '$daysUntilNextExam ${daysUntilNextExam == 1 ? "day" : "days"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (daysUntilNextExam == 0)
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: colors.textMuted),
                      children: const [
                        TextSpan(text: 'Your exam is '),
                        TextSpan(
                          text: 'today!',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Manage your mock exams and results',
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primary700],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}
