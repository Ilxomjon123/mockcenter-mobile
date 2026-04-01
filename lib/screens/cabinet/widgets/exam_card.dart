import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_colors_extension.dart';
import '../../../models/exam.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/glass_button.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final bool isRegistering;
  final bool isHighlighted;
  final String? payingExamId;
  final String? payingProvider;
  final String Function(num) formatPrice;
  final void Function(int examId) onRegister;
  final void Function(int examId) onOpenPromo;
  final void Function(ExamLocation location) onOpenLocation;
  final void Function(Exam exam) onOpenCredentials;
  final void Function(String examUserId, String provider) onDirectPayment;
  final void Function(String examUserId, String provider) onShowQrCode;
  final void Function(int examId, String examUserId) onOpenSpeakingSlot;
  final void Function(int examId, String examUserId)? onApplyPromo;

  const ExamCard({
    super.key,
    required this.exam,
    this.isRegistering = false,
    this.isHighlighted = false,
    this.payingExamId,
    this.payingProvider,
    required this.formatPrice,
    required this.onRegister,
    required this.onOpenPromo,
    required this.onOpenLocation,
    required this.onOpenCredentials,
    required this.onDirectPayment,
    required this.onShowQrCode,
    required this.onOpenSpeakingSlot,
    this.onApplyPromo,
  });

  Color _borderColor(AppColorsExtension colors) {
    if (isHighlighted) return AppColors.amber400;
    if (exam.isFull) return AppColors.error.withValues(alpha: 0.3);
    if (exam.examUser != null && exam.examUser!.isPaid) {
      return AppColors.success.withValues(alpha: 0.3);
    }
    if (exam.examUser != null && exam.examUser!.needsPayment) {
      return AppColors.amber400.withValues(alpha: 0.3);
    }
    return colors.glassBorder;
  }

  bool get _isIelts => exam.type == 'ielts';
  Color get _typeColor => _isIelts ? AppColors.primary : AppColors.emerald600;
  Color get _typeColorLight => _isIelts ? AppColors.primary500 : AppColors.emerald500;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final examDate = DateTime.parse(exam.datetime);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: _borderColor(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_typeColorLight, _typeColor],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _typeColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isIelts ? Icons.auto_stories_rounded : Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isIelts ? 'IELTS Mock Test' : 'CEFR Exam',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _typeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _formatShortDate(examDate),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(colors),
            ],
          ),
          const SizedBox(height: 14),

          // Info grid
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.primary,
                  label: 'DATE & TIME',
                  value: _formatShortDate(examDate),
                  subvalue: _formatTime(examDate),
                ),
              ),
              const SizedBox(width: 10),
              if (exam.location != null)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onOpenLocation(exam.location!),
                    child: _InfoTile(
                      icon: Icons.location_on_rounded,
                      iconColor: AppColors.secondary,
                      label: 'LOCATION',
                      value: exam.location!.name,
                      subvalue: 'View on map',
                      subvalueColor: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),

          // Speaking slot info
          if (exam.examUser != null &&
              exam.examUser!.isPaid &&
              (exam.examUser!.speakingSlotTime != null || exam.speakingDatetime != null)) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.bgPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_rounded, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SPEAKING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 0.5)),
                      Text(
                        exam.examUser!.speakingSlotTime ?? exam.speakingDatetime ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: exam.examUser!.speakingSlotTime != null
                              ? AppColors.primary700
                              : colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          Container(height: 1, color: colors.border.withValues(alpha: 0.3)),
          const SizedBox(height: 14),

          // Footer - actions
          _buildFooter(colors),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AppColorsExtension colors) {
    if (exam.examUser != null && exam.examUser!.isPaid) {
      return _Badge(
        icon: Icons.check_circle_rounded,
        text: exam.examUser!.isAdminApproved ? 'Paid' : 'Paid',
        bgColor: colors.successBg,
        textColor: colors.successText,
      );
    }
    if (exam.examUser != null && exam.examUser!.needsPayment) {
      return _Badge(
        icon: Icons.access_time_rounded,
        text: 'Pay Now',
        bgColor: colors.warningBg,
        textColor: colors.warningText,
        pulse: true,
      );
    }
    if (exam.isFull) {
      return _Badge(
        icon: Icons.cancel_rounded,
        text: 'Full',
        bgColor: colors.errorBg,
        textColor: colors.errorText,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFooter(AppColorsExtension colors) {
    // Not registered
    if (exam.examUser == null) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 0.5)),
                  Text(formatPrice(exam.price), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                ],
              ),
              if (exam.maxParticipants != null)
                Text(
                  exam.seatsLeft < 10
                      ? 'Only ${exam.seatsLeft} ${exam.seatsLeft == 1 ? "seat" : "seats"} left!'
                      : '${exam.seatsLeft} seats available',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: exam.seatsLeft < 10 ? AppColors.error : colors.textTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  text: exam.isFull ? 'Full' : 'Book Your Seat',
                  onPressed: exam.isFull ? null : () => onRegister(exam.id),
                  isLoading: isRegistering,
                  icon: exam.isFull ? null : Icons.arrow_forward_rounded,
                ),
              ),
              if (exam.price > 0 && !exam.isFull) ...[
                const SizedBox(width: 8),
                GlassButton(
                  text: 'Promo',
                  icon: Icons.confirmation_number_rounded,
                  onPressed: () => onOpenPromo(exam.id),
                  isOutlined: true,
                  backgroundColor: colors.amber50,
                  textColor: AppColors.amber700,
                ),
              ],
            ],
          ),
        ],
      );
    }

    // Needs payment
    if (exam.examUser!.needsPayment) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AMOUNT DUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 0.5)),
                  if (exam.examUser!.promoCode != null && exam.examUser!.discountAmount != null) ...[
                    Text(
                      formatPrice(exam.examUser!.originalAmount ?? 0),
                      style: TextStyle(fontSize: 12, color: colors.textMuted, decoration: TextDecoration.lineThrough),
                    ),
                    Text(
                      formatPrice(exam.examUser!.finalAmount ?? 0),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.success),
                    ),
                  ] else
                    Text(formatPrice(exam.price), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.amber600),
                  const SizedBox(width: 4),
                  const Text('Payment required', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.amber600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PaymentButton(
                  label: 'Payme',
                  color: AppColors.payme,
                  onPressed: () => onDirectPayment(exam.examUser!.id, 'payme'),
                  onQrPressed: () => onShowQrCode(exam.examUser!.id, 'payme'),
                  isLoading: payingExamId == exam.examUser!.id && payingProvider == 'payme',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PaymentButton(
                  label: 'Click',
                  color: AppColors.click,
                  onPressed: () => onDirectPayment(exam.examUser!.id, 'click'),
                  onQrPressed: () => onShowQrCode(exam.examUser!.id, 'click'),
                  isLoading: payingExamId == exam.examUser!.id && payingProvider == 'click',
                ),
              ),
              if (onApplyPromo != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onApplyPromo!(exam.id, exam.examUser!.id),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.amber50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.amber400.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.confirmation_number_rounded, size: 20, color: AppColors.amber700),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    // Paid / Confirmed
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (exam.examUser!.needsSpeakingSlot)
          _ActionChip(
            icon: Icons.mic_rounded,
            label: 'Speaking',
            color: AppColors.amber700,
            bgColor: colors.amber50,
            borderColor: colors.warningBorder,
            onTap: () => onOpenSpeakingSlot(exam.id, exam.examUser!.id),
          ),
        if (exam.examUser!.speakingSlotTime != null && exam.speakingDatetime != null && !exam.examUser!.needsSpeakingSlot) ...[
          _ActionChip(
            icon: Icons.repeat_rounded,
            label: 'Speaking',
            color: colors.textTertiary,
            bgColor: colors.bgTertiary,
            borderColor: colors.border,
            onTap: () => onOpenSpeakingSlot(exam.id, exam.examUser!.id),
          ),
          const SizedBox(width: 8),
        ],
        if (exam.examUser!.needsSpeakingSlot) const SizedBox(width: 8),
        _ActionChip(
          icon: Icons.key_rounded,
          label: 'Login Info',
          color: AppColors.primary,
          bgColor: colors.primary50,
          borderColor: AppColors.primary200,
          onTap: () => onOpenCredentials(exam),
        ),
      ],
    );
  }

  String _formatShortDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color textColor;
  final bool pulse;

  const _Badge({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subvalue;
  final Color? subvalueColor;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subvalue,
    this.subvalueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.bgPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 0.5)),
                Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary), overflow: TextOverflow.ellipsis),
                if (subvalue != null)
                  Text(subvalue!, style: TextStyle(fontSize: 10, color: subvalueColor ?? colors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
