import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/exam_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../models/exam.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/loading_indicator.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String? _payingExamId;
  String? _payingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchUpcomingExams();
    });
  }

  List<Exam> _pendingExams(ExamProvider provider) {
    return provider.upcomingExams
        .where((e) => e.examUser != null && e.examUser!.needsPayment)
        .toList();
  }

  List<Exam> _paidExams(ExamProvider provider) {
    return provider.upcomingExams
        .where((e) => e.examUser != null && e.examUser!.isPaid)
        .toList();
  }

  Future<void> _handlePayment(String examUserId, String provider) async {
    setState(() {
      _payingExamId = examUserId;
      _payingProvider = provider;
    });
    try {
      final url = await context.read<ExamProvider>().getPaymentUrl(examUserId, provider);
      if (url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
    } finally {
      setState(() {
        _payingExamId = null;
        _payingProvider = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final examProvider = context.watch<ExamProvider>();
    final pending = _pendingExams(examProvider);
    final paid = _paidExams(examProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => examProvider.fetchUpcomingExams(),
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primary700, AppColors.primary800],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(top: -20, right: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle))),
                  Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.payment_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Payments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Manage your exam payments', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (examProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: LoadingIndicator(message: 'Loading payments...'),
              )
            else ...[
              // Pending payments
              if (pending.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.amber600),
                    const SizedBox(width: 6),
                    Text(
                      'Pending Payments (${pending.length})',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pending.map((exam) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PaymentCard(
                    exam: exam,
                    isPending: true,
                    payingExamId: _payingExamId,
                    payingProvider: _payingProvider,
                    onPay: _handlePayment,
                    formatPrice: examProvider.formatPrice,
                  ),
                )),
                const SizedBox(height: 16),
              ],

              // Paid
              if (paid.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Paid (${paid.length})',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...paid.map((exam) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PaymentCard(
                    exam: exam,
                    isPending: false,
                    formatPrice: examProvider.formatPrice,
                  ),
                )),
              ],

              if (pending.isEmpty && paid.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                  child: Column(
                    children: [
                      Icon(Icons.payment_rounded, size: 48, color: colors.textMuted.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text('No payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Register for an exam to see payments', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Exam exam;
  final bool isPending;
  final String? payingExamId;
  final String? payingProvider;
  final void Function(String, String)? onPay;
  final String Function(num) formatPrice;

  const _PaymentCard({
    required this.exam,
    required this.isPending,
    this.payingExamId,
    this.payingProvider,
    this.onPay,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final examDate = DateTime.parse(exam.datetime);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: isPending ? AppColors.amber400.withValues(alpha: 0.4) : colors.successBorder.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.type == 'ielts' ? 'IELTS Mock Test' : 'CEFR',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.5),
                  ),
                  Text(
                    '${months[examDate.month - 1]} ${examDate.day}, ${examDate.year}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? colors.warningBg : colors.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Paid',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPending ? colors.warningText : colors.successText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatPrice(exam.examUser?.finalAmount ?? exam.price),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
          ),
          if (isPending && onPay != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PaymentButton(
                    label: 'Payme',
                    color: AppColors.payme,
                    onPressed: () => onPay!(exam.examUser!.id, 'payme'),
                    isLoading: payingExamId == exam.examUser!.id && payingProvider == 'payme',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PaymentButton(
                    label: 'Click',
                    color: AppColors.click,
                    onPressed: () => onPay!(exam.examUser!.id, 'click'),
                    isLoading: payingExamId == exam.examUser!.id && payingProvider == 'click',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
