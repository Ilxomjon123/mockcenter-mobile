class User {
  final String id;
  final String name;
  final String? lastName;
  final String? patronymic;
  final String? email;
  final String? phone;
  final String? pinfl;
  final List<dynamic>? phones;
  final String? telegramId;
  final String? telegramUsername;
  final String? telegramFirstName;
  final String? telegramPhotoUrl;
  final String? googleId;
  final String? googleName;
  final String? googleEmail;
  final String? googleAvatar;
  final String? referralCode;

  User({
    required this.id,
    required this.name,
    this.lastName,
    this.patronymic,
    this.email,
    this.phone,
    this.pinfl,
    this.phones,
    this.telegramId,
    this.telegramUsername,
    this.telegramFirstName,
    this.telegramPhotoUrl,
    this.googleId,
    this.googleName,
    this.googleEmail,
    this.googleAvatar,
    this.referralCode,
  });

  String get fullName => lastName != null && lastName!.isNotEmpty ? '$name $lastName' : name;

  bool get isTelegramLinked => telegramId != null;
  bool get isGoogleLinked => googleId != null;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      lastName: json['last_name'] as String?,
      patronymic: json['patronymic'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      pinfl: json['pinfl'] as String?,
      phones: json['phones'] as List<dynamic>?,
      telegramId: json['telegram_id']?.toString(),
      telegramUsername: json['telegram_username'] as String?,
      telegramFirstName: json['telegram_first_name'] as String?,
      telegramPhotoUrl: json['telegram_photo_url'] as String?,
      googleId: json['google_id']?.toString(),
      googleName: json['google_name'] as String?,
      googleEmail: json['google_email'] as String?,
      googleAvatar: json['google_avatar'] as String?,
      referralCode: json['referral_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'last_name': lastName,
    'patronymic': patronymic,
    'email': email,
    'phone': phone,
    'pinfl': pinfl,
    'phones': phones,
    'telegram_id': telegramId,
    'telegram_username': telegramUsername,
    'telegram_first_name': telegramFirstName,
    'telegram_photo_url': telegramPhotoUrl,
    'google_id': googleId,
    'google_name': googleName,
    'google_email': googleEmail,
    'google_avatar': googleAvatar,
    'referral_code': referralCode,
  };
}
