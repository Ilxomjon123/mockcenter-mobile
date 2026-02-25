import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../models/result.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_indicator.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final examProvider = context.watch<ExamProvider>();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => examProvider.fetchResults(),
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
                    child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle)),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Exam Results', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('View your mock test scores', style: TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Average score summary
            if (examProvider.averageScore != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary500, AppColors.primary]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        examProvider.averageScore!,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Average Band Score', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                        Text('Based on ${examProvider.completedExamsCount} ${examProvider.completedExamsCount == 1 ? "exam" : "exams"}', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Loading
            if (examProvider.isLoadingResults)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: LoadingIndicator(message: 'Loading results...'),
              )
            else if (examProvider.results.isEmpty)
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 48, color: colors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text('No results yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Complete a mock test to see your results', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                  ],
                ),
              )
            else
              ...examProvider.results.map((result) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DetailedResultCard(result: result),
              )),
          ],
        ),
      ),
    );
  }
}

class _DetailedResultCard extends StatelessWidget {
  final ExamResult result;

  const _DetailedResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final examDate = DateTime.parse(result.exam.datetime);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(examDate),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  Text(
                    result.exam.type == 'ielts' ? 'IELTS Mock Test' : 'CEFR',
                    style: TextStyle(fontSize: 11, color: colors.textMuted, letterSpacing: 0.3),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary500, AppColors.primary]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(result.overall, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                    const Text('Overall', style: TextStyle(fontSize: 9, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Score bars
          _ScoreBar(label: 'Listening', value: result.listeningScore, icon: Icons.headphones_rounded),
          const SizedBox(height: 8),
          _ScoreBar(label: 'Reading', value: result.readingScore, icon: Icons.auto_stories_rounded),
          const SizedBox(height: 8),
          _ScoreBar(label: 'Writing', value: result.writingScore, icon: Icons.edit_rounded),
          const SizedBox(height: 8),
          _ScoreBar(label: 'Speaking', value: result.speakingScore, icon: Icons.mic_rounded),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;

  const _ScoreBar({required this.label, this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final score = double.tryParse(value ?? '') ?? 0;
    final progress = score / 9.0;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 65,
          child: Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: colors.bgTertiary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0, 1),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary400, AppColors.primary]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            value ?? '-',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
