import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_colors_extension.dart';
import '../../models/referral.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_indicator.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  ReferralStats? _stats;
  bool _isLoading = true;
  String? _error;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = ApiService(StorageService());
      final response = await api.get('/app/referral', auth: true);
      setState(() {
        _stats = ReferralStats.fromJson(response as Map<String, dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load referral data'; _isLoading = false; });
    }
  }

  void _copyLink() async {
    if (_stats?.referralLink == null) return;
    await Clipboard.setData(ClipboardData(text: _stats!.referralLink));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _copyCode() async {
    if (_stats?.referralCode == null) return;
    await Clipboard.setData(ClipboardData(text: _stats!.referralCode!));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _shareLink() {
    if (_stats?.referralLink == null) return;
    Share.share('Join MockCenter and prepare for your IELTS exam!\n${_stats!.referralLink}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Referral Program', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _fetchStats,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              children: [
            Text('Invite friends and earn 10% discount promo codes when they pay for an exam', style: TextStyle(fontSize: 13, color: colors.textMuted)),
            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: LoadingIndicator())
            else if (_error != null)
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderColor: colors.errorBorder,
                backgroundColor: colors.errorBg,
                child: Column(
                  children: [
                    Text(_error!, style: TextStyle(fontSize: 13, color: colors.errorText)),
                    const SizedBox(height: 8),
                    GestureDetector(onTap: _fetchStats, child: const Text('Try again', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary))),
                  ],
                ),
              )
            else if (_stats != null) ...[
              // How it works
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How it works', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    const SizedBox(height: 14),
                    ...List.generate(3, (i) {
                      final steps = [
                        ['Share your link', 'Send your referral link to friends'],
                        ['Friend registers & pays', 'They sign up and pay for a mock test'],
                        ['You get 10% off', 'Receive a promo code for your next exam'],
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: colors.primary100, borderRadius: BorderRadius.circular(12)),
                              alignment: Alignment.center,
                              child: Text('${i + 1}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(steps[i][0], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
                                  Text(steps[i][1], style: TextStyle(fontSize: 11, color: colors.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Referral link card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primary700]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.link_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text('Your Referral Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Code
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Referral Code', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                                const SizedBox(height: 2),
                                Text(_stats!.referralCode ?? '-', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _copyCode,
                            child: Icon(_copied ? Icons.check : Icons.copy, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Link
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Share this link', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                          const SizedBox(height: 2),
                          Text(_stats!.referralLink, style: const TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _copyLink,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_copied ? Icons.check : Icons.copy, size: 18, color: AppColors.primary700),
                                  const SizedBox(width: 6),
                                  Text(_copied ? 'Copied!' : 'Copy Link', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: _shareLink,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.share_rounded, size: 18, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text('Share', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: colors.infoBg, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.person_add_rounded, size: 18, color: AppColors.info),
                          ),
                          const SizedBox(height: 10),
                          Text('${_stats!.totalReferrals}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                          Text('Friends Invited', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: colors.successBg, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.confirmation_number_rounded, size: 18, color: AppColors.success),
                          ),
                          const SizedBox(height: 10),
                          Text('${_stats!.rewards.length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                          Text('Rewards Earned', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rewards list
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Reward Codes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                          Text('Use these promo codes when registering for an exam', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                        ],
                      ),
                    ),
                    if (_stats!.rewards.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          children: [
                            Icon(Icons.card_giftcard_rounded, size: 40, color: colors.textMuted.withValues(alpha: 0.4)),
                            const SizedBox(height: 8),
                            Text('No rewards yet. Invite friends to earn promo codes!', style: TextStyle(fontSize: 12, color: colors.textMuted), textAlign: TextAlign.center),
                          ],
                        ),
                      )
                    else
                      ..._stats!.rewards.map((reward) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: colors.border.withValues(alpha: 0.3))),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: reward.isUsed ? colors.bgTertiary : colors.primary100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.confirmation_number_rounded,
                                size: 18,
                                color: reward.isUsed ? colors.textMuted : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        reward.code,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: reward.isUsed ? colors.textMuted : colors.textPrimary,
                                          decoration: reward.isUsed ? TextDecoration.lineThrough : null,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: reward.isUsed ? colors.bgTertiary : colors.successBg,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          reward.isUsed ? 'Used' : '${reward.discount} off',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: reward.isUsed ? colors.textMuted : colors.successText),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'From ${reward.referredUser}',
                                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
      ),
    );
  }
}
