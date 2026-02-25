import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exam_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../widgets/loading_indicator.dart';
import '../../dialogs/location_modal.dart';
import '../../dialogs/credentials_modal.dart';
import '../../dialogs/promo_code_modal.dart';
import '../../dialogs/qr_code_modal.dart';
import '../../dialogs/speaking_slot_modal.dart';
import 'widgets/welcome_header.dart';
import 'widgets/quick_stats.dart';
import 'widgets/next_exam_countdown.dart';
import 'widgets/exam_card.dart';
import 'widgets/book_exam_banner.dart';
import 'widgets/recent_results.dart';
import 'widgets/preview_cards.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _payingExamId;
  String? _payingProvider;
  int? _registeringExamId;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchDashboardData();
    });
  }

  Future<void> _refresh() async {
    await context.read<ExamProvider>().fetchDashboardData();
  }

  int? _daysUntilNextExam(ExamProvider examProvider) {
    if (examProvider.nextPaidExam == null) return null;
    final examDate = DateTime.parse(examProvider.nextPaidExam!.datetime);
    return examDate.difference(DateTime.now()).inDays;
  }

  void _handleRegister(int examId) async {
    setState(() => _registeringExamId = examId);
    try {
      await context.read<ExamProvider>().registerForExam(examId);
      setState(() {
        _successMessage = 'Successfully registered!';
        _registeringExamId = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _registeringExamId = null;
      });
    }
  }

  void _handleDirectPayment(String examUserId, String provider) async {
    setState(() {
      _payingExamId = examUserId;
      _payingProvider = provider;
    });
    try {
      final url = await context.read<ExamProvider>().getPaymentUrl(examUserId, provider);
      if (url.isNotEmpty) {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
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
    final auth = context.watch<AuthProvider>();
    final examProvider = context.watch<ExamProvider>();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Alerts
            if (_successMessage != null) ...[
              _AlertBanner(
                message: _successMessage!,
                isError: false,
                onDismiss: () => setState(() => _successMessage = null),
              ),
              const SizedBox(height: 12),
            ],
            if (_errorMessage != null) ...[
              _AlertBanner(
                message: _errorMessage!,
                isError: true,
                onDismiss: () => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 12),
            ],

            // Welcome header
            WelcomeHeader(
              userName: auth.user?.name ?? 'User',
              daysUntilNextExam: _daysUntilNextExam(examProvider),
            ),
            const SizedBox(height: 16),

            // Quick stats
            QuickStats(
              nextExamDate: examProvider.nextPaidExam?.datetime,
              averageScore: examProvider.averageScore,
            ),
            const SizedBox(height: 10),
            QuickStatsRow2(
              completedExamsCount: examProvider.completedExamsCount,
              pendingPaymentCount: examProvider.pendingPaymentCount,
            ),
            const SizedBox(height: 16),

            // Next exam countdown
            if (examProvider.nextPaidExam != null) ...[
              NextExamCountdown(
                exam: examProvider.nextPaidExam!,
                onLocationTap: examProvider.nextPaidExam!.location != null
                    ? () => LocationModal.show(context, examProvider.nextPaidExam!.location!)
                    : null,
              ),
              const SizedBox(height: 16),
            ],

            // Loading
            if (examProvider.isLoading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: LoadingIndicator(message: 'Loading exams...'),
              ),
            ] else ...[
              // Pending payment banner
              if (examProvider.pendingPaymentCount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.warningBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.warningBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.amber600),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You have ${examProvider.pendingPaymentCount} pending ${examProvider.pendingPaymentCount == 1 ? "payment" : "payments"}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.amber700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Exam cards
              if (examProvider.upcomingExams.isEmpty) ...[
                BookExamBanner(onTap: () {
                  // Navigate to Book tab
                }),
              ] else ...[
                ...examProvider.upcomingExams.map((exam) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ExamCard(
                    exam: exam,
                    isRegistering: _registeringExamId == exam.id,
                    payingExamId: _payingExamId,
                    payingProvider: _payingProvider,
                    formatPrice: examProvider.formatPrice,
                    onRegister: _handleRegister,
                    onOpenPromo: (examId) {
                      PromoCodeModal.show(context, examId: examId, examProvider: examProvider);
                    },
                    onOpenLocation: (location) {
                      LocationModal.show(context, location);
                    },
                    onOpenCredentials: (exam) {
                      CredentialsModal.show(
                        context,
                        examTitle: '${exam.type == "ielts" ? "IELTS" : "CEFR"} Mock Test',
                        number: exam.examUser?.id ?? '',
                        key: exam.examUser?.id ?? '',
                      );
                    },
                    onDirectPayment: _handleDirectPayment,
                    onShowQrCode: (examUserId, provider) async {
                      QrCodeModal.show(context, provider: provider, isLoading: true);
                      try {
                        final url = await context.read<ExamProvider>().getPaymentUrl(examUserId, provider);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (url.isNotEmpty) {
                          QrCodeModal.show(
                            context,
                            provider: provider,
                            paymentUrl: url,
                            onOpenPaymentUrl: () async {
                              final uri = Uri.parse(url);
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                          );
                        }
                      } catch (e) {
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    onOpenSpeakingSlot: (examId, examUserId) {
                      SpeakingSlotModal.show(
                        context,
                        examId: examId,
                        examUserId: examUserId,
                        examProvider: examProvider,
                      );
                    },
                  ),
                )),
              ],

              const SizedBox(height: 16),

              // Recent results
              RecentResults(
                results: examProvider.results.take(2).toList(),
                onViewAll: () {
                  // Navigate to Results tab
                },
              ),

              const SizedBox(height: 16),

              // Preview cards
              const PreviewCards(),
            ],
          ],
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _AlertBanner({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? colors.errorBg : colors.successBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError ? colors.errorBorder : colors.successBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 20,
            color: isError ? AppColors.error : AppColors.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: isError ? colors.errorText : colors.successText,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close,
              size: 18,
              color: isError ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
