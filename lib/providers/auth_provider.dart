import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  // Registration flow state
  String? _registrationToken;
  String? _registrationPhone;

  // Forgot password flow state
  String? _resetToken;
  String? _resetPhone;
  int _forgotPasswordStep = 1; // 1=phone, 2=code, 3=password, 4=success

  // Telegram auth state
  String? _telegramAuthCode;
  String? _telegramBotUrl;
  bool _telegramConfirmed = false;

  AuthProvider(this._authService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  String? get registrationToken => _registrationToken;
  String? get registrationPhone => _registrationPhone;

  String? get resetToken => _resetToken;
  String? get resetPhone => _resetPhone;
  int get forgotPasswordStep => _forgotPasswordStep;

  String? get telegramAuthCode => _telegramAuthCode;
  String? get telegramBotUrl => _telegramBotUrl;
  bool get telegramConfirmed => _telegramConfirmed;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      final loggedIn = await _authService.isLoggedIn();
      if (loggedIn) {
        _user = await _authService.fetchUser();
      }
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Login with phone + password
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.login(phone, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register step 1: submit form
  Future<bool> register({
    required String firstName,
    String? lastName,
    required String phone,
    String? referralCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _registrationToken = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        referralCode: referralCode,
      );
      _registrationPhone = phone;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register step 2: verify code
  Future<bool> verifyRegistration(String code) async {
    if (_registrationToken == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.verify(_registrationToken!, code);
      _registrationToken = null;
      _registrationPhone = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetRegistration() {
    _registrationToken = null;
    _registrationPhone = null;
    _error = null;
    notifyListeners();
  }

  // Forgot password step 1
  Future<bool> forgotPasswordSendCode(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _resetToken = await _authService.forgotPassword(phone);
      _resetPhone = phone;
      _forgotPasswordStep = 2;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Forgot password step 2
  Future<bool> forgotPasswordVerifyCode(String code) async {
    if (_resetToken == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _resetToken = await _authService.verifyResetCode(_resetToken!, code);
      _forgotPasswordStep = 3;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Forgot password step 3
  Future<bool> forgotPasswordReset(String password, String confirmation) async {
    if (_resetToken == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.resetPassword(_resetToken!, password, confirmation);
      _forgotPasswordStep = 4;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetForgotPassword() {
    _resetToken = null;
    _resetPhone = null;
    _forgotPasswordStep = 1;
    _error = null;
    notifyListeners();
  }

  // Telegram auth
  Future<bool> initiateTelegramAuth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _authService.initiateTelegramAuth();
      _telegramAuthCode = data['code'] as String?;
      _telegramBotUrl = data['bot_url'] as String?;
      _telegramConfirmed = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkTelegramAuthStatus() async {
    if (_telegramAuthCode == null) return false;
    try {
      _telegramConfirmed = await _authService.checkTelegramAuthStatus(_telegramAuthCode!);
      notifyListeners();
      return _telegramConfirmed;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyTelegramAuth(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.verifyTelegramAuth(code);
      _telegramAuthCode = null;
      _telegramBotUrl = null;
      _telegramConfirmed = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google auth redirect
  Future<String?> getGoogleRedirectUrl() async {
    try {
      return await _authService.getGoogleRedirectUrl();
    } catch (_) {
      return null;
    }
  }

  Future<void> refreshUser() async {
    try {
      _user = await _authService.fetchUser();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateProfile(String name, String? lastName) async {
    await _authService.updateProfile(name, lastName);
    await refreshUser();
  }

  Future<void> changePassword(String currentPassword, String password, String passwordConfirmation) async {
    await _authService.changePassword(currentPassword, password, passwordConfirmation);
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
