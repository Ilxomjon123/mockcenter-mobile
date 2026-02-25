import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../dialogs/location_modal.dart';
import '../../dialogs/promo_code_modal.dart';
import '../../dialogs/qr_code_modal.dart';
import 'widgets/exam_card.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  int? _registeringExamId;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchUpcomingExams();
    });
  }

  void _handleRegister(int examId) async {
    setState(() => _registeringExamId = examId);
    try {
      await context.read<ExamProvider>().registerForExam(examId);
      setState(() {
        _successMessage = 'Successfully registered for the exam!';
        _registeringExamId = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _registeringExamId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final examProvider = context.watch<ExamProvider>();

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
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Book an Exam', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Register for upcoming mock tests', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Success / Error
            if (_successMessage != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(12),
                borderColor: colors.successBorder,
                backgroundColor: colors.successBg,
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 20, color: AppColors.success),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_successMessage!, style: TextStyle(fontSize: 13, color: colors.successText))),
                    GestureDetector(
                      onTap: () => setState(() => _successMessage = null),
                      child: const Icon(Icons.close, size: 16, color: AppColors.success),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_errorMessage != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(12),
                borderColor: colors.errorBorder,
                backgroundColor: colors.errorBg,
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 20, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_errorMessage!, style: TextStyle(fontSize: 13, color: colors.errorText))),
                    GestureDetector(
                      onTap: () => setState(() => _errorMessage = null),
                      child: const Icon(Icons.close, size: 16, color: AppColors.error),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Loading
            if (examProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: LoadingIndicator(message: 'Loading available exams...'),
              )
            else if (examProvider.upcomingExams.isEmpty)
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 48, color: colors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text('No upcoming exams', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Check back later for new exam dates', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                  ],
                ),
              )
            else
              ...examProvider.upcomingExams.map((exam) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExamCard(
                  exam: exam,
                  isRegistering: _registeringExamId == exam.id,
                  formatPrice: examProvider.formatPrice,
                  onRegister: _handleRegister,
                  onOpenPromo: (examId) {
                    PromoCodeModal.show(context, examId: examId, examProvider: examProvider);
                  },
                  onOpenLocation: (location) => LocationModal.show(context, location),
                  onOpenCredentials: (_) {},
                  onDirectPayment: (_, __) {},
                  onShowQrCode: (examUserId, provider) {
                    QrCodeModal.show(context, provider: provider, examUserId: examUserId);
                  },
                  onOpenSpeakingSlot: (_, __) {},
                ),
              )),
          ],
        ),
      ),
    );
  }
}
