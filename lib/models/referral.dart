class ReferralReward {
  final String code;
  final String discount;
  final String? validUntil;
  final bool isUsed;
  final String referredUser;

  ReferralReward({
    required this.code,
    required this.discount,
    this.validUntil,
    required this.isUsed,
    required this.referredUser,
  });

  factory ReferralReward.fromJson(Map<String, dynamic> json) {
    return ReferralReward(
      code: json['code'] as String? ?? '',
      discount: json['discount'] as String? ?? '',
      validUntil: json['valid_until'] as String?,
      isUsed: json['is_used'] as bool? ?? false,
      referredUser: json['referred_user'] as String? ?? '',
    );
  }
}

class ReferralStats {
  final String? referralCode;
  final String referralLink;
  final int totalReferrals;
  final int paidReferrals;
  final List<ReferralReward> rewards;

  ReferralStats({
    this.referralCode,
    required this.referralLink,
    required this.totalReferrals,
    required this.paidReferrals,
    required this.rewards,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      referralCode: json['referral_code'] as String?,
      referralLink: json['referral_link'] as String? ?? '',
      totalReferrals: json['total_referrals'] as int? ?? 0,
      paidReferrals: json['paid_referrals'] as int? ?? 0,
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => ReferralReward.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
