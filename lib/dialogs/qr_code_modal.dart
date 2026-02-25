import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/exam_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';
import '../widgets/glass_button.dart';

class QrCodeModal extends StatefulWidget {
  final String provider;
  final String examUserId;

  const QrCodeModal({
    super.key,
    required this.provider,
    required this.examUserId,
  });

  static Future<void> show(BuildContext context, {
    required String provider,
    required String examUserId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrCodeModal(
        provider: provider,
        examUserId: examUserId,
      ),
    );
  }

  @override
  State<QrCodeModal> createState() => _QrCodeModalState();
}

class _QrCodeModalState extends State<QrCodeModal> {
  String? _paymentUrl;
  bool _isLoading = true;
  String? _error;

  String get _providerName {
    switch (widget.provider) {
      case 'payme': return 'Payme';
      case 'click': return 'Click';
      case 'uzum': return 'Uzum';
      default: return widget.provider;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPaymentUrl();
  }

  Future<void> _fetchPaymentUrl() async {
    try {
      final url = await context.read<ExamProvider>().getPaymentUrl(
        widget.examUserId,
        widget.provider,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _paymentUrl = url.isNotEmpty ? url : null;
        if (url.isEmpty) _error = 'Payment URL not available';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _openInApp() async {
    if (_paymentUrl == null) return;
    final uri = Uri.parse(_paymentUrl!);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.qr_code_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$_providerName QR Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      Text('Scan to pay', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                      const SizedBox(height: 12),
                      Text('Generating QR code...', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ],
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline_rounded, size: 40, color: colors.errorText),
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(fontSize: 13, color: colors.errorText)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() { _isLoading = true; _error = null; });
                          _fetchPaymentUrl();
                        },
                        child: const Text('Try again', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    ],
                  ),
                )
              else if (_paymentUrl != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: colors.glassShadow, blurRadius: 10)]),
                  child: QrImageView(
                    data: _paymentUrl!,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF111827)),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF111827)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, size: 16, color: colors.textMuted),
                    const SizedBox(width: 6),
                    Text('Scan with $_providerName app', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                  ],
                ),
                const SizedBox(height: 16),
                GlassButton(text: 'Open in App', onPressed: _openInApp, width: double.infinity),
              ],

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
