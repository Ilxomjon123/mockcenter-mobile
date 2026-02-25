import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Timer? _resendTimer;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _handleSendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !RegExp(r'^\+?998\d{9}$').hasMatch(phone.replaceAll(' ', ''))) {
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPasswordSendCode(phone);
    if (success) _startResendCooldown();
  }

  Future<void> _handleVerifyCode() async {
    if (_codeController.text.length != 6) return;
    await context.read<AuthProvider>().forgotPasswordVerifyCode(_codeController.text);
  }

  Future<void> _handleResetPassword() async {
    if (_passwordController.text.length < 8) return;
    if (_passwordController.text != _confirmPasswordController.text) return;
    await context.read<AuthProvider>().forgotPasswordReset(
      _passwordController.text,
      _confirmPasswordController.text,
    );
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

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Step icon
                            _buildStepIcon(auth.forgotPasswordStep, colors),
                            const SizedBox(height: 16),
                            // Step title
                            Text(
                              _stepTitle(auth.forgotPasswordStep),
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: colors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _stepSubtitle(auth),
                              style: TextStyle(fontSize: 14, color: colors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                            if (auth.forgotPasswordStep == 2 && auth.resetPhone != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _maskPhone(auth.resetPhone!),
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
                              ),
                            ],
                            const SizedBox(height: 28),

                            // Step content
                            if (auth.forgotPasswordStep == 4) ...[
                              // SUCCESS
                              _buildSuccessStep(colors),
                            ] else ...[
                              GlassCard(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Error
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
                                            Expanded(child: Text(auth.error!, style: TextStyle(fontSize: 13, color: colors.errorText))),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Step 1: Phone
                                    if (auth.forgotPasswordStep == 1) ...[
                                      GlassInput(
                                        controller: _phoneController,
                                        labelText: 'Phone Number',
                                        hintText: '+998XXXXXXXXX',
                                        keyboardType: TextInputType.phone,
                                        maxLength: 13,
                                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                        onSubmitted: (_) => _handleSendCode(),
                                      ),
                                      const SizedBox(height: 20),
                                      GlassButton(
                                        text: auth.isLoading ? 'Sending...' : 'Send Reset Code',
                                        onPressed: _handleSendCode,
                                        isLoading: auth.isLoading,
                                        backgroundColor: const Color(0xFFF59E0B),
                                        width: double.infinity,
                                      ),
                                    ],

                                    // Step 2: Verify code
                                    if (auth.forgotPasswordStep == 2) ...[
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
                                          setState(() {});
                                          if (v.length == 6) _handleVerifyCode();
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      GlassButton(
                                        text: auth.isLoading ? 'Verifying...' : 'Verify Code',
                                        onPressed: _codeController.text.length == 6 ? _handleVerifyCode : null,
                                        isLoading: auth.isLoading,
                                        backgroundColor: const Color(0xFFF59E0B),
                                        width: double.infinity,
                                      ),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: Column(
                                          children: [
                                            Text("Didn't receive the code?", style: TextStyle(fontSize: 13, color: colors.textMuted)),
                                            const SizedBox(height: 6),
                                            TextButton(
                                              onPressed: _resendCooldown <= 0 ? () async {
                                                auth.resetForgotPassword();
                                                final success = await auth.forgotPasswordSendCode(_phoneController.text.trim());
                                                if (success) _startResendCooldown();
                                              } : null,
                                              child: Text(
                                                _resendCooldown > 0 ? 'Resend in ${_resendCooldown}s' : 'Resend code',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _resendCooldown > 0 ? colors.textMuted : const Color(0xFFF59E0B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    // Step 3: New password
                                    if (auth.forgotPasswordStep == 3) ...[
                                      GlassInput(
                                        controller: _passwordController,
                                        labelText: 'New Password',
                                        hintText: 'At least 8 characters',
                                        obscureText: _obscurePassword,
                                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      GlassInput(
                                        controller: _confirmPasswordController,
                                        labelText: 'Confirm Password',
                                        hintText: 'Re-enter your password',
                                        obscureText: _obscureConfirm,
                                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                        ),
                                        onSubmitted: (_) => _handleResetPassword(),
                                      ),
                                      const SizedBox(height: 20),
                                      GlassButton(
                                        text: auth.isLoading ? 'Resetting...' : 'Reset Password',
                                        onPressed: _handleResetPassword,
                                        isLoading: auth.isLoading,
                                        backgroundColor: AppColors.success,
                                        width: double.infinity,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            // Back to sign in
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                auth.forgotPasswordStep == 4 ? 'Go to Sign In' : 'Back to Sign In',
                                style: TextStyle(fontSize: 14, color: colors.textMuted, fontWeight: FontWeight.w500),
                              ),
                            ),
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

  Widget _buildStepIcon(int step, AppColorsExtension colors) {
    Color bgColor;
    Color iconColor;
    IconData iconData;

    switch (step) {
      case 1:
        bgColor = colors.amber100;
        iconColor = const Color(0xFFF59E0B);
        iconData = Icons.key_rounded;
        break;
      case 2:
        bgColor = colors.amber100;
        iconColor = const Color(0xFFF59E0B);
        iconData = Icons.mark_email_read_rounded;
        break;
      case 3:
        bgColor = colors.secondary100;
        iconColor = AppColors.success;
        iconData = Icons.lock_rounded;
        break;
      case 4:
        bgColor = colors.secondary100;
        iconColor = AppColors.success;
        iconData = Icons.check_circle_rounded;
        break;
      default:
        bgColor = colors.amber100;
        iconColor = const Color(0xFFF59E0B);
        iconData = Icons.key_rounded;
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(iconData, size: 32, color: iconColor),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 1: return 'Forgot Password?';
      case 2: return 'Check your inbox';
      case 3: return 'Create new password';
      case 4: return 'Password Reset Successful!';
      default: return '';
    }
  }

  String _stepSubtitle(AuthProvider auth) {
    switch (auth.forgotPasswordStep) {
      case 1: return 'Enter your phone number and we\'ll send you a reset code';
      case 2: return 'We sent a 6-digit verification code to:';
      case 3: return 'Your new password must be at least 8 characters';
      case 4: return 'Your password has been successfully reset. You can now sign in with your new password.';
      default: return '';
    }
  }

  Widget _buildSuccessStep(AppColorsExtension colors) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.secondary100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.check_circle_rounded, size: 44, color: AppColors.success),
          ),
          const SizedBox(height: 20),
          Text(
            'You can now sign in with your new password',
            style: TextStyle(fontSize: 14, color: colors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GlassButton(
            text: 'Sign In',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.arrow_forward_rounded,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
