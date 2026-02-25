import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showComingSoon = true;

  final _mockNotifications = [
    _MockNotification(
      type: 'exam_reminder',
      title: 'Exam reminder',
      message: 'Your IELTS Mock Test exam is in 2 days.',
      read: false,
      timeAgo: '30 minutes ago',
    ),
    _MockNotification(
      type: 'payment_success',
      title: 'Payment successful',
      message: 'Your payment for IELTS Mock Test has been received.',
      read: true,
      timeAgo: '2 hours ago',
    ),
    _MockNotification(
      type: 'result_ready',
      title: 'Result ready',
      message: 'Your IELTS Mock Test result is ready. Click to view results.',
      read: true,
      timeAgo: '1 day ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary700, AppColors.primary800],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(top: -20, right: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle))),
                Row(
                  children: [
                    Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 26)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Updates about exams, payments and results', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Coming soon
          if (_showComingSoon) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.amber600.withValues(alpha: 0.1), AppColors.error.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.amber400.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.amber600, Color(0xFFEA580C)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: AppColors.amber600.withValues(alpha: 0.3), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coming soon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('The notification system is currently under development. Soon you will receive real-time updates.', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showComingSoon = false),
                    child: Icon(Icons.close, size: 18, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Notifications list
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.inbox_rounded, size: 18, color: AppColors.primary)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent notifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                          Text('Preview mode', style: TextStyle(fontSize: 11, color: colors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                ..._mockNotifications.map((n) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: !n.read ? AppColors.primary.withValues(alpha: 0.03) : null,
                    border: Border(top: BorderSide(color: colors.border.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: n._bgColor(colors), borderRadius: BorderRadius.circular(12)),
                        child: Icon(n._icon, size: 18, color: n._iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(n.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                                if (!n.read) ...[
                                  const SizedBox(width: 6),
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(n.message, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(n.timeAgo, style: TextStyle(fontSize: 11, color: colors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.border.withValues(alpha: 0.2)))),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: colors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(child: Text('This is just a preview. Real notifications will be added soon.', style: TextStyle(fontSize: 12, color: colors.textMuted))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Features
          Row(
            children: [
              Expanded(child: _FeatureCard(icon: Icons.calendar_month_rounded, title: 'Exam reminders', subtitle: 'Get reminders before your exam date')),
              const SizedBox(width: 8),
              Expanded(child: _FeatureCard(icon: Icons.credit_card_rounded, title: 'Payment updates', subtitle: 'Get updates about payment status')),
            ],
          ),
          const SizedBox(height: 8),
          _FeatureCard(icon: Icons.bar_chart_rounded, title: 'Result updates', subtitle: 'Get notified when results are ready'),
        ],
      ),
      ),
      ),
    );
  }
}

class _MockNotification {
  final String type;
  final String title;
  final String message;
  final bool read;
  final String timeAgo;

  _MockNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.timeAgo,
  });

  IconData get _icon {
    switch (type) {
      case 'exam_reminder': return Icons.calendar_month_rounded;
      case 'payment_success': return Icons.check_circle_rounded;
      case 'result_ready': return Icons.bar_chart_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color get _iconColor {
    switch (type) {
      case 'payment_success': return AppColors.success;
      default: return AppColors.primary;
    }
  }

  Color _bgColor(AppColorsExtension colors) {
    switch (type) {
      case 'payment_success': return colors.successBg;
      default: return colors.primary100;
    }
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary500, AppColors.primary]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)],
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: colors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
