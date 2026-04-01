import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';
import '../providers/exam_provider.dart';
import '../widgets/glass_input.dart';
import '../widgets/glass_button.dart';

class PromoCodeModal extends StatefulWidget {
  final int examId;
  final ExamProvider examProvider;
  final String mode; // 'register' or 'apply'
  final String? examUserId; // required for 'apply' mode

  const PromoCodeModal({
    super.key,
    required this.examId,
    required this.examProvider,
    this.mode = 'register',
    this.examUserId,
  });

  static Future<void> show(BuildContext context, {
    required int examId,
    required ExamProvider examProvider,
    String mode = 'register',
    String? examUserId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: PromoCodeModal(
          examId: examId,
          examProvider: examProvider,
          mode: mode,
          examUserId: examUserId,
        ),
      ),
    );
  }

  @override
  State<PromoCodeModal> createState() => _PromoCodeModalState();
}

class _PromoCodeModalState extends State<PromoCodeModal> {
  final _controller = TextEditingController();
  bool _isValidating = false;
  bool _isValidated = false;
  bool _isRegistering = false;
  String? _error;
  Map<String, dynamic>? _discount;

  Future<void> _validate() async {
    if (_controller.text.isEmpty) return;
    setState(() { _isValidating = true; _error = null; });
    try {
      final result = await widget.examProvider.validatePromoCode(_controller.text, widget.examId);
      if (result['valid'] == true) {
        setState(() { _isValidated = true; _discount = result; });
      } else {
        setState(() => _error = result['message'] as String? ?? 'Invalid promo code');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isValidating = false);
    }
  }

  Future<void> _submit() async {
    if (widget.mode == 'apply' && !_isValidated) return;
    setState(() => _isRegistering = true);
    try {
      if (widget.mode == 'apply') {
        await widget.examProvider.applyPromoCode(
          widget.examUserId!,
          _controller.text,
        );
      } else {
        await widget.examProvider.registerForExam(
          widget.examId,
          promoCode: _isValidated ? _controller.text : null,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _isRegistering = false; });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: colors.modalBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.amber600.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.confirmation_number_rounded, color: AppColors.amber600, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Promo Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      Text('Enter a promo code to get a discount', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Input
              Row(
                children: [
                  Expanded(
                    child: GlassInput(
                      controller: _controller,
                      hintText: 'Enter promo code',
                      textCapitalization: TextCapitalization.characters,
                      enabled: !_isValidated,
                      onSubmitted: (_) => _validate(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_isValidated)
                    GestureDetector(
                      onTap: _isValidating ? null : _validate,
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                        child: _isValidating
                            ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                            : const Icon(Icons.check, color: Colors.white),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => setState(() { _isValidated = false; _discount = null; _controller.clear(); }),
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: colors.bgTertiary, borderRadius: BorderRadius.circular(14)),
                        child: Icon(Icons.close, color: colors.textSecondary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Error
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.errorBorder)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: TextStyle(fontSize: 12, color: colors.errorText))),
                    ],
                  ),
                ),

              // Discount info
              if (_isValidated && _discount != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: colors.successBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.successBorder)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text('Promo code applied!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.successText)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Original price:', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                          Text('${_discount!['original_amount_formatted'] ?? ''}', style: TextStyle(fontSize: 12, color: colors.textMuted, decoration: TextDecoration.lineThrough)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount:', style: TextStyle(fontSize: 12, color: colors.textTertiary)),
                          Text('-${_discount!['discount_formatted'] ?? ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(height: 1, color: colors.successBorder),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                          Text('${_discount!['discounted_amount_formatted'] ?? ''}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.success)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  GlassButton(
                    text: 'Cancel',
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassButton(
                      text: widget.mode == 'apply' ? 'Apply Promo' : 'Book Your Seat',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: (widget.mode == 'apply' && !_isValidated) ? null : _submit,
                      isLoading: _isRegistering,
                    ),
                  ),
                ],
              ),
              if (!_isValidated && widget.mode == 'register') ...[
                const SizedBox(height: 10),
                Text('Click "Book Your Seat" to continue without a promo code', style: TextStyle(fontSize: 11, color: colors.textMuted), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
