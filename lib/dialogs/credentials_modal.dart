import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';
import '../widgets/glass_button.dart';

class CredentialsModal extends StatefulWidget {
  final String examTitle;
  final String number;
  final String examKey;

  const CredentialsModal({
    super.key,
    required this.examTitle,
    required this.number,
    required this.examKey,
  });

  static Future<void> show(BuildContext context, {
    required String examTitle,
    required String number,
    required String key,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CredentialsModal(examTitle: examTitle, number: number, examKey: key),
    );
  }

  @override
  State<CredentialsModal> createState() => _CredentialsModalState();
}

class _CredentialsModalState extends State<CredentialsModal> {
  String? _copiedField;

  void _copy(String text, String field) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedField = field);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedField = null);
    });
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
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.key_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exam Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      Text(widget.examTitle, style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colors.bgTertiary, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border.withValues(alpha: 0.3))),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: colors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Use these credentials to log in to the exam system on exam day.', style: TextStyle(fontSize: 12, color: colors.textSecondary))),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Number
              _CredentialField(
                label: 'Number (Login)',
                value: widget.number,
                isCopied: _copiedField == 'number',
                onCopy: () => _copy(widget.number, 'number'),
              ),
              const SizedBox(height: 12),

              // Key
              _CredentialField(
                label: 'Exam Key (Password)',
                value: widget.examKey,
                isCopied: _copiedField == 'key',
                onCopy: () => _copy(widget.examKey, 'key'),
                bold: true,
              ),
              const SizedBox(height: 16),

              GlassButton(
                text: _copiedField == 'all' ? 'Copied!' : 'Copy All Credentials',
                icon: _copiedField == 'all' ? Icons.check : Icons.copy_all_rounded,
                onPressed: () => _copy('Number: ${widget.number}\nKey: ${widget.examKey}', 'all'),
                width: double.infinity,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Close', style: TextStyle(fontSize: 14, color: colors.textMuted, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CredentialField extends StatelessWidget {
  final String label;
  final String value;
  final bool isCopied;
  final VoidCallback onCopy;
  final bool bold;

  const _CredentialField({
    required this.label,
    required this.value,
    required this.isCopied,
    required this.onCopy,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textMuted)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.bgTertiary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border.withValues(alpha: 0.3)),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                    color: colors.textPrimary,
                    letterSpacing: bold ? 1 : 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCopied ? colors.successBg : colors.bgTertiary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isCopied ? colors.successBorder : colors.border.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  isCopied ? Icons.check : Icons.copy,
                  size: 20,
                  color: isCopied ? AppColors.success : colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
