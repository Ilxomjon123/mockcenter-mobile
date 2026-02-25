import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_button.dart';
import '../cabinet/cabinet_shell.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CabinetShell()),
        (route) => false,
      );
    }
  }

  Future<void> _handleTelegramAuth() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.initiateTelegramAuth();
    if (success && auth.telegramBotUrl != null && mounted) {
      await launchUrl(
        Uri.parse(auth.telegramBotUrl!),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _handleGoogleAuth() async {
    final auth = context.read<AuthProvider>();
    final url = await auth.getGoogleRedirectUrl();
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/logo.png', width: 72, height: 72),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colors.textPrimary, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to continue to MockCenter',
                    style: TextStyle(fontSize: 14, color: colors.textMuted),
                  ),
                  const SizedBox(height: 32),

                  // Login form
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final colors = context.colors;

                        return Form(
                          key: _formKey,
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

                              // Phone number
                              GlassInput(
                                controller: _phoneController,
                                labelText: 'Phone Number',
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
                              const SizedBox(height: 16),

                              // Password
                              GlassInput(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password is required';
                                  return null;
                                },
                                onSubmitted: (_) => _handleLogin(),
                              ),

                              // Forgot password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Sign in button
                              GlassButton(
                                text: 'Sign In',
                                onPressed: _handleLogin,
                                isLoading: auth.isLoading,
                                icon: Icons.arrow_forward_rounded,
                                width: double.infinity,
                              ),

                              // Divider - "Or continue with"
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: Container(height: 1, color: colors.border.withValues(alpha: 0.5))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('Or continue with', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                                  ),
                                  Expanded(child: Container(height: 1, color: colors.border.withValues(alpha: 0.5))),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Social login buttons
                              Row(
                                children: [
                                  // Telegram
                                  Expanded(
                                    child: _SocialButton(
                                      label: 'Telegram',
                                      color: const Color(0xFF0088CC),
                                      icon: Icons.send_rounded,
                                      onTap: _handleTelegramAuth,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Google
                                  Expanded(
                                    child: _SocialButton(
                                      label: 'Google',
                                      color: colors.bgPrimary,
                                      textColor: colors.textPrimary,
                                      icon: Icons.g_mobiledata_rounded,
                                      iconSize: 28,
                                      bordered: true,
                                      borderColor: colors.border,
                                      onTap: _handleGoogleAuth,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Divider - "New to MockCenter?"
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: colors.border.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('New to MockCenter?', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                      ),
                      Expanded(child: Container(height: 1, color: colors.border.withValues(alpha: 0.3))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Register button
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: colors.glassBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                          ),
                          child: Center(
                            child: Text(
                              'Create an account',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final IconData icon;
  final double iconSize;
  final bool bordered;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    required this.color,
    this.textColor,
    required this.icon,
    this.iconSize = 20,
    this.bordered = false,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: bordered ? Border.all(color: (borderColor ?? colors.border).withValues(alpha: 0.5)) : null,
            boxShadow: !bordered
                ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: textColor ?? Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
