import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../models/result.dart';
import '../services/api_service.dart';

class ExamProvider extends ChangeNotifier {
  final ApiService _api;

  List<Exam> _upcomingExams = [];
  List<ExamResult> _results = [];
  Exam? _nextPaidExam;
  String? _averageScore;
  int _completedExamsCount = 0;
  int _pendingPaymentCount = 0;
  bool _isLoading = false;
  bool _isLoadingResults = false;
  String? _error;

  ExamProvider(this._api);

  List<Exam> get upcomingExams => _upcomingExams;
  List<ExamResult> get results => _results;
  Exam? get nextPaidExam => _nextPaidExam;
  String? get averageScore => _averageScore;
  int get completedExamsCount => _completedExamsCount;
  int get pendingPaymentCount => _pendingPaymentCount;
  bool get isLoading => _isLoading;
  bool get isLoadingResults => _isLoadingResults;
  String? get error => _error;

  Future<void> fetchUpcomingExams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/app/exams/upcoming', auth: true);
      final data = response['data'] as List<dynamic>? ?? response as List<dynamic>? ?? [];
      _upcomingExams = data
          .map((e) => Exam.fromJson(e as Map<String, dynamic>))
          .toList();

      _nextPaidExam = _upcomingExams.where((e) =>
          e.examUser != null && e.examUser!.isPaid).isNotEmpty
          ? _upcomingExams.firstWhere((e) =>
              e.examUser != null && e.examUser!.isPaid)
          : null;

      _pendingPaymentCount = _upcomingExams.where((e) =>
          e.examUser != null && e.examUser!.needsPayment).length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchResults() async {
    _isLoadingResults = true;
    notifyListeners();
    try {
      final response = await _api.get('/app/exams/history', auth: true);
      final data = response['data'] as List<dynamic>? ?? response as List<dynamic>? ?? [];
      _results = data
          .map((e) => ExamResult.fromJson(e as Map<String, dynamic>))
          .toList();

      if (_results.isNotEmpty) {
        final scores = _results
            .map((r) => double.tryParse(r.overall) ?? 0)
            .where((s) => s > 0)
            .toList();
        if (scores.isNotEmpty) {
          final avg = scores.reduce((a, b) => a + b) / scores.length;
          _averageScore = avg.toStringAsFixed(1);
        }
      }
      _completedExamsCount = _results.length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingResults = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboardData() async {
    await Future.wait([fetchUpcomingExams(), fetchResults()]);
  }

  Future<Map<String, dynamic>> registerForExam(int examId, {String? promoCode}) async {
    final body = <String, dynamic>{'exam_id': examId};
    if (promoCode != null) body['promo_code'] = promoCode;
    final response = await _api.post('/app/exams/register', body: body, auth: true);
    await fetchUpcomingExams();
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> validatePromoCode(String code, int examId) async {
    final response = await _api.get(
      '/app/exams/promo-codes/validate?code=$code&exam_id=$examId',
      auth: true,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> applyPromoCode(String examUserId, String promoCode) async {
    final response = await _api.post('/app/exams/register/$examUserId/apply-promo', body: {
      'promo_code': promoCode,
    }, auth: true);
    await fetchUpcomingExams();
    return response as Map<String, dynamic>;
  }

  Future<String> getPaymentUrl(String examUserId, String provider) async {
    final response = await _api.post('/app/exams/register/$examUserId/pay', body: {
      'provider': provider,
    }, auth: true);
    return response['redirect_url'] as String? ?? '';
  }

  Future<List<SpeakingSlot>> getSpeakingSlots(int examId) async {
    final response = await _api.get('/app/exams/$examId/speaking-slots', auth: true);
    final data = response['data'] as List<dynamic>? ?? response as List<dynamic>? ?? [];
    return data
        .map((e) => SpeakingSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> selectSpeakingSlot(String examUserId, String slotTime) async {
    await _api.post('/app/exams/speaking-slot', body: {
      'exam_user_id': examUserId,
      'slot_time': slotTime,
    }, auth: true);
    await fetchUpcomingExams();
  }

  String formatPrice(num price) {
    final intPrice = price.toInt();
    final formatted = intPrice.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$formatted UZS';
  }
}
