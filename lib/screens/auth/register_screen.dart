import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../cabinet/cabinet_shell.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  // Resend cooldown
  Timer? _resendTimer;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isNotEmpty ? _lastNameController.text.trim() : null,
      phone: _phoneController.text.trim(),
    );
    if (success) _startResendCooldown();
  }

  Future<void> _handleVerify() async {
    if (_codeController.text.length != 6) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyRegistration(_codeController.text);
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CabinetShell()),
        (route) => false,
      );
    }
  }

  Future<void> _handleResendCode() async {
    if (_resendCooldown > 0) return;
    final auth = context.read<AuthProvider>();
    auth.resetRegistration();
    final success = await auth.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isNotEmpty ? _lastNameController.text.trim() : null,
      phone: _phoneController.text.trim(),
    );
    if (success) _startResendCooldown();
  }

  String _maskPhone(String phone) {
    if (phone.length < 5) return phone;
    return '${phone.substring(0, 4)}${'*' * (phone.length - 6)}${phone.substring(phone.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final colors = context.colors;
                        final isVerifyStep = auth.registrationToken != null;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary700],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isVerifyStep ? Icons.mark_email_read_rounded : Icons.person_add_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isVerifyStep ? 'Verify your account' : 'Create account',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isVerifyStep
                                  ? 'We sent a 6-digit code to:'
                                  : 'Join thousands of successful IELTS candidates',
                              style: TextStyle(fontSize: 14, color: colors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                            if (isVerifyStep && auth.registrationPhone != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _maskPhone(auth.registrationPhone!),
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
                              ),
                            ],
                            const SizedBox(height: 28),

                            GlassCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Error alert
                                  if (auth.error != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colors.errorBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: colors.errorBorder),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline, size: 20, color: AppColors.error),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(auth.error!, style: TextStyle(fontSize: 13, color: colors.errorText)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  if (!isVerifyStep) ...[
                                    // STEP 1: Registration form
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // First Name (required)
                                          GlassInput(
                                            controller: _firstNameController,
                                            labelText: 'First Name *',
                                            hintText: 'First name',
                                            textCapitalization: TextCapitalization.words,
                                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                                            validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null,
                                          ),
                                          const SizedBox(height: 14),

                                          // Last Name (optional)
                                          GlassInput(
                                            controller: _lastNameController,
                                            labelText: 'Last Name',
                                            hintText: 'Last name',
                                            textCapitalization: TextCapitalization.words,
                                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                                          ),
                                          const SizedBox(height: 14),

                                          // Phone Number (required)
                                          GlassInput(
                                            controller: _phoneController,
                                            labelText: 'Phone Number *',
                                            hintText: '+998XXXXXXXXX',
                                            keyboardType: TextInputType.phone,
                                            maxLength: 13,
                                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                            validator: (v) {
                                              if (v == null || v.isEmpty) return 'Phone number is required';
                                              final phone = v.replaceAll(' ', '');
                                              if (!RegExp(r'^\+?998\d{9}$').hasMatch(phone)) {
                                                return 'Invalid phone format (e.g. +998XXXXXXXXX)';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),

                                          // Submit button
                                          GlassButton(
                                            text: auth.isLoading ? 'Sending code...' : 'Continue',
                                            onPressed: _handleSubmit,
                                            isLoading: auth.isLoading,
                                            icon: Icons.arrow_forward_rounded,
                                            width: double.infinity,
                                          ),
                                        ],
                                      ),
                                    ),

                                  ] else ...[
                                    // STEP 2: Verification
                                    // Code input
                                    GlassInput(
                                      controller: _codeController,
                                      hintText: '000000',
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      autofocus: true,
                                      textAlign: TextAlign.center,
                                      letterSpacing: 12,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      onChanged: (v) {
                                        if (v.length == 6) _handleVerify();
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // Verify button
                                    GlassButton(
                                      text: auth.isLoading ? 'Verifying...' : 'Verify',
                                      onPressed: _codeController.text.length == 6 ? _handleVerify : null,
                                      isLoading: auth.isLoading,
                                      icon: Icons.check_rounded,
                                      width: double.infinity,
                                    ),
                                    const SizedBox(height: 20),

                                    // Resend section
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            "Didn't receive the code?",
                                            style: TextStyle(fontSize: 13, color: colors.textMuted),
                                          ),
                                          const SizedBox(height: 6),
                                          TextButton(
                                            onPressed: _resendCooldown <= 0 ? _handleResendCode : null,
                                            child: Text(
                                              _resendCooldown > 0
                                                  ? 'Resend in ${_resendCooldown}s'
                                                  : 'Resend code',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: _resendCooldown > 0 ? colors.textMuted : AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Back to form
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          auth.resetRegistration();
                                          _codeController.clear();
                                        },
                                        child: Text(
                                          'Back to registration',
                                          style: TextStyle(fontSize: 13, color: colors.textMuted),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Login link
                            if (!isVerifyStep) ...[
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(color: colors.textMuted, fontSize: 14),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

