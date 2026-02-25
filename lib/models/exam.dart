class ExamLocation {
  final int id;
  final String name;
  final String? address;
  final String? locationUrl;

  ExamLocation({
    required this.id,
    required this.name,
    this.address,
    this.locationUrl,
  });

  factory ExamLocation.fromJson(Map<String, dynamic> json) {
    return ExamLocation(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      locationUrl: json['location_url'] as String?,
    );
  }
}

class ExamUser {
  final String id;
  final String paymentStatus;
  final bool isAdminRegistered;
  final bool isAdminApproved;
  final String? speakingSlotTime;
  final bool needsSpeakingSlot;
  final String? promoCode;
  final num? discountAmount;
  final num? originalAmount;
  final num? finalAmount;

  ExamUser({
    required this.id,
    required this.paymentStatus,
    this.isAdminRegistered = false,
    this.isAdminApproved = false,
    this.speakingSlotTime,
    this.needsSpeakingSlot = false,
    this.promoCode,
    this.discountAmount,
    this.originalAmount,
    this.finalAmount,
  });

  bool get isPaid =>
      paymentStatus == 'paid' ||
      paymentStatus == 'not_required' ||
      isAdminApproved;

  bool get needsPayment =>
      !isAdminRegistered &&
      !isAdminApproved &&
      paymentStatus != 'paid' &&
      paymentStatus != 'not_required';

  factory ExamUser.fromJson(Map<String, dynamic> json) {
    return ExamUser(
      id: json['id'].toString(),
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      isAdminRegistered: json['is_admin_registered'] as bool? ?? false,
      isAdminApproved: json['is_admin_approved'] as bool? ?? false,
      speakingSlotTime: json['speaking_slot_time'] as String?,
      needsSpeakingSlot: json['needs_speaking_slot'] as bool? ?? false,
      promoCode: json['promo_code'] as String?,
      discountAmount: json['discount_amount'] as num?,
      originalAmount: json['original_amount'] as num?,
      finalAmount: json['final_amount'] as num?,
    );
  }
}

class Exam {
  final int id;
  final String type;
  final String datetime;
  final String? speakingDatetime;
  final num price;
  final int? maxParticipants;
  final int currentParticipants;
  final ExamLocation? location;
  final ExamUser? examUser;

  Exam({
    required this.id,
    required this.type,
    required this.datetime,
    this.speakingDatetime,
    required this.price,
    this.maxParticipants,
    this.currentParticipants = 0,
    this.location,
    this.examUser,
  });

  bool get isFull =>
      maxParticipants != null && currentParticipants >= maxParticipants!;

  int get seatsLeft =>
      maxParticipants != null ? maxParticipants! - currentParticipants : 999;

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'ielts',
      datetime: json['datetime'] as String? ?? '',
      speakingDatetime: json['speaking_datetime'] as String?,
      price: json['price'] as num? ?? 0,
      maxParticipants: json['max_participants'] as int?,
      currentParticipants: json['current_participants'] as int? ?? 0,
      location: json['location'] != null
          ? ExamLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      examUser: json['exam_user'] != null
          ? ExamUser.fromJson(json['exam_user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpeakingSlot {
  final String start;
  final String startTime;
  final int available;

  SpeakingSlot({
    required this.start,
    required this.startTime,
    required this.available,
  });

  factory SpeakingSlot.fromJson(Map<String, dynamic> json) {
    return SpeakingSlot(
      start: json['start'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      available: json['available'] as int? ?? 0,
    );
  }
}
