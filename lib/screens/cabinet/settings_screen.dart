import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/glass_button.dart';
import '../auth/login_screen.dart';
import 'referral_screen.dart';
import 'notifications_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Profile
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isUpdatingProfile = false;
  String? _profileSuccess;
  String? _profileError;

  // Password
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isUpdatingPassword = false;
  String? _passwordSuccess;
  String? _passwordError;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Telegram
  String? _telegramLinkCode;
  String? _telegramBotUrl;
  bool _isLinkingTelegram = false;
  String? _telegramSuccess;
  String? _telegramError;
  String _telegramStatus = 'idle'; // idle, waiting, ready
  Timer? _telegramPollTimer;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _lastNameController.text = user.lastName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telegramPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() { _isUpdatingProfile = true; _profileSuccess = null; _profileError = null; });
    try {
      await context.read<AuthProvider>().updateProfile(
        _nameController.text.trim(),
        _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
      );
      setState(() { _profileSuccess = 'Profile updated successfully'; _isUpdatingProfile = false; });
    } catch (e) {
      setState(() { _profileError = e.toString(); _isUpdatingProfile = false; });
    }
  }

  Future<void> _changePassword() async {
    setState(() { _isUpdatingPassword = true; _passwordSuccess = null; _passwordError = null; });
    try {
      await context.read<AuthProvider>().changePassword(
        _currentPasswordController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );
      setState(() {
        _passwordSuccess = 'Password changed successfully';
        _isUpdatingPassword = false;
        _currentPasswordController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      setState(() { _passwordError = e.toString(); _isUpdatingPassword = false; });
    }
  }

  Future<void> _initTelegramLink() async {
    setState(() { _isLinkingTelegram = true; _telegramSuccess = null; _telegramError = null; _telegramStatus = 'waiting'; });
    try {
      final storage = StorageService();
      final authService = AuthService(ApiService(storage), storage);
      final data = await authService.initiateTelegramLink();
      setState(() {
        _telegramLinkCode = data['code'] as String?;
        _telegramBotUrl = data['bot_url'] as String?;
        _isLinkingTelegram = false;
      });
      _startTelegramPolling();
    } catch (e) {
      setState(() { _telegramError = e.toString(); _isLinkingTelegram = false; _telegramStatus = 'idle'; });
    }
  }

  void _startTelegramPolling() {
    _telegramPollTimer?.cancel();
    _telegramPollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_telegramLinkCode == null) { _telegramPollTimer?.cancel(); return; }
      try {
        final storage = StorageService();
        final authService = AuthService(ApiService(storage), storage);
        final ready = await authService.checkTelegramLinkStatus(_telegramLinkCode!);
        if (ready) {
          setState(() => _telegramStatus = 'ready');
          _telegramPollTimer?.cancel();
          await _verifyTelegramLink();
        }
      } catch (_) {}
    });
  }

  Future<void> _verifyTelegramLink() async {
    if (_telegramLinkCode == null) return;
    try {
      final storage = StorageService();
      final authService = AuthService(ApiService(storage), storage);
      await authService.verifyTelegramLink(_telegramLinkCode!);
      await context.read<AuthProvider>().refreshUser();
      setState(() {
        _telegramSuccess = 'Telegram account linked successfully';
        _telegramLinkCode = null;
        _telegramBotUrl = null;
        _telegramStatus = 'idle';
      });
    } catch (e) {
      setState(() => _telegramError = e.toString());
    }
  }

  void _cancelTelegramLink() {
    _telegramPollTimer?.cancel();
    setState(() {
      _telegramLinkCode = null;
      _telegramBotUrl = null;
      _telegramStatus = 'idle';
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 8),
              Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This action cannot be undone. All your data will be permanently deleted.'),
              const SizedBox(height: 16),
              const Text('Type DELETE to confirm:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                onChanged: (_) => setDialogState(() {}),
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: controller.text == 'DELETE' ? () => Navigator.pop(ctx, true) : null,
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().deleteAccount();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colors = context.colors;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary700, AppColors.primary800],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(top: -20, right: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle))),
                Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.settings_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Manage your profile and password', style: TextStyle(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Appearance
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.palette_outlined, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text('Appearance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ThemeOption(
                      icon: Icons.light_mode_rounded,
                      label: 'Light',
                      isSelected: themeProvider.isLight,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(width: 8),
                    _ThemeOption(
                      icon: Icons.dark_mode_rounded,
                      label: 'Dark',
                      isSelected: themeProvider.isDark,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                    const SizedBox(width: 8),
                    _ThemeOption(
                      icon: Icons.settings_suggest_rounded,
                      label: 'System',
                      isSelected: themeProvider.isSystem,
                      onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick links
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 16,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralScreen())),
                  child: Column(
                    children: [
                      const Icon(Icons.people_rounded, size: 24, color: AppColors.primary),
                      const SizedBox(height: 6),
                      Text('Referral', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 16,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  child: Column(
                    children: [
                      const Icon(Icons.notifications_rounded, size: 24, color: AppColors.primary),
                      const SizedBox(height: 6),
                      Text('Notifications', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profile Settings
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person_outline, size: 18, color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Text('Profile information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_profileSuccess != null) ...[
                  _SuccessBanner(message: _profileSuccess!, onDismiss: () => setState(() => _profileSuccess = null)),
                  const SizedBox(height: 12),
                ],
                if (_profileError != null) ...[
                  _ErrorBanner(message: _profileError!, onDismiss: () => setState(() => _profileError = null)),
                  const SizedBox(height: 12),
                ],
                GlassInput(controller: _nameController, labelText: 'First name *', hintText: 'Enter your first name'),
                const SizedBox(height: 12),
                GlassInput(controller: _lastNameController, labelText: 'Last name', hintText: 'Enter your last name'),
                const SizedBox(height: 16),
                GlassButton(text: 'Save', onPressed: _updateProfile, isLoading: _isUpdatingProfile, width: double.infinity),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Password
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.lock_outline, size: 18, color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Text('Change password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_passwordSuccess != null) ...[
                  _SuccessBanner(message: _passwordSuccess!, onDismiss: () => setState(() => _passwordSuccess = null)),
                  const SizedBox(height: 12),
                ],
                if (_passwordError != null) ...[
                  _ErrorBanner(message: _passwordError!, onDismiss: () => setState(() => _passwordError = null)),
                  const SizedBox(height: 12),
                ],
                GlassInput(
                  controller: _currentPasswordController, labelText: 'Current password *',
                  hintText: 'Enter current password', obscureText: _obscureCurrent,
                  suffixIcon: IconButton(icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent)),
                ),
                const SizedBox(height: 12),
                GlassInput(
                  controller: _passwordController, labelText: 'New password *',
                  hintText: 'At least 8 characters', obscureText: _obscureNew,
                  suffixIcon: IconButton(icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscureNew = !_obscureNew)),
                ),
                const SizedBox(height: 12),
                GlassInput(
                  controller: _confirmPasswordController, labelText: 'Confirm new password *',
                  hintText: 'Re-enter password', obscureText: _obscureConfirm,
                  suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                ),
                const SizedBox(height: 16),
                GlassButton(text: 'Change password', onPressed: _changePassword, isLoading: _isUpdatingPassword, width: double.infinity),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Telegram
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.telegram.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.send_rounded, size: 18, color: AppColors.telegram)),
                    const SizedBox(width: 10),
                    Text('Telegram Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_telegramSuccess != null) ...[
                  _SuccessBanner(message: _telegramSuccess!, onDismiss: () => setState(() => _telegramSuccess = null)),
                  const SizedBox(height: 12),
                ],
                if (_telegramError != null) ...[
                  _ErrorBanner(message: _telegramError!, onDismiss: () => setState(() => _telegramError = null)),
                  const SizedBox(height: 12),
                ],
                if (auth.user?.isTelegramLinked == true) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.telegram.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.telegram.withValues(alpha: 0.2))),
                    child: Row(
                      children: [
                        Container(width: 44, height: 44, decoration: const BoxDecoration(color: AppColors.telegram, shape: BoxShape.circle), child: const Icon(Icons.send_rounded, size: 20, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.user?.telegramFirstName ?? 'Telegram', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                              if (auth.user?.telegramUsername != null) Text('@${auth.user!.telegramUsername}', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, size: 22, color: AppColors.success),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Your Telegram account is linked.', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                ] else if (_telegramLinkCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.telegram.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.telegram.withValues(alpha: 0.2))),
                    child: Column(
                      children: [
                        Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.telegram, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.send_rounded, size: 28, color: Colors.white)),
                        const SizedBox(height: 12),
                        Text(
                          _telegramStatus == 'ready' ? 'Ready to Link!' : 'Open Telegram Bot',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        if (_telegramStatus == 'waiting')
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.amber600))),
                              SizedBox(width: 8),
                              Text('Waiting for confirmation...', style: TextStyle(fontSize: 12, color: AppColors.amber600)),
                            ],
                          ),
                        if (_telegramStatus == 'ready')
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 16, color: AppColors.success),
                              SizedBox(width: 6),
                              Text('Confirmed! Linking...', style: TextStyle(fontSize: 12, color: AppColors.success)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassButton(
                    text: 'Open Telegram Bot',
                    icon: Icons.send_rounded,
                    backgroundColor: AppColors.telegram,
                    onPressed: () async {
                      if (_telegramBotUrl != null) {
                        await launchUrl(Uri.parse(_telegramBotUrl!), mode: LaunchMode.externalApplication);
                      }
                    },
                    width: double.infinity,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: _cancelTelegramLink,
                      child: Text('Cancel', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                    ),
                  ),
                ] else ...[
                  Text('Link your Telegram account to receive notifications and use quick login.', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                  const SizedBox(height: 12),
                  const _FeatureRow(icon: Icons.notifications_outlined, text: 'Receive exam notifications'),
                  const SizedBox(height: 6),
                  const _FeatureRow(icon: Icons.credit_card_rounded, text: 'Get payment reminders'),
                  const SizedBox(height: 6),
                  const _FeatureRow(icon: Icons.bolt_rounded, text: 'Quick login via Telegram'),
                  const SizedBox(height: 14),
                  GlassButton(
                    text: 'Link Telegram Account',
                    icon: Icons.send_rounded,
                    backgroundColor: AppColors.telegram,
                    onPressed: _initTelegramLink,
                    isLoading: _isLinkingTelegram,
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign out
          GlassButton(
            text: 'Sign Out',
            icon: Icons.logout_rounded,
            onPressed: _logout,
            isOutlined: true,
            width: double.infinity,
          ),
          const SizedBox(height: 12),

          // Delete account
          Center(
            child: GestureDetector(
              onTap: _deleteAccount,
              child: const Text('Delete Account', style: TextStyle(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : colors.bgTertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : colors.border.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.primary : colors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _SuccessBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.successBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.successBorder)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(fontSize: 12, color: colors.successText))),
          GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, size: 16, color: AppColors.success)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: colors.errorBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: colors.errorBorder)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(fontSize: 12, color: colors.errorText))),
          GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, size: 16, color: AppColors.error)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: context.colors.textMuted)),
      ],
    );
  }
}
