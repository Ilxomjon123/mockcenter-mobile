import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api;
  final StorageService _storage;

  AuthService(this._api, this._storage);

  // Login with phone + password
  Future<User> login(String phone, String password) async {
    final response = await _api.post('/app/auth/login', body: {
      'phone': phone,
      'password': password,
    });
    final accessToken = response['access_token'] as String;
    await _storage.setToken(accessToken);
    if (response['refresh_token'] != null) {
      await _storage.setRefreshToken(response['refresh_token'] as String);
    }
    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  // Register step 1: send name, phone → get registration_token
  Future<String> register({
    required String firstName,
    String? lastName,
    required String phone,
    String? referralCode,
    Map<String, String>? utmParams,
  }) async {
    final body = <String, dynamic>{
      'name': firstName,
      'phone': phone,
    };
    if (lastName != null && lastName.isNotEmpty) body['last_name'] = lastName;
    if (referralCode != null && referralCode.isNotEmpty) body['referral_code'] = referralCode;
    if (utmParams != null) body.addAll(utmParams);

    final response = await _api.post('/app/auth/register', body: body);
    return response['registration_token'] as String;
  }

  // Register step 2: verify SMS code
  Future<User> verify(String registrationToken, String code) async {
    final response = await _api.post('/app/auth/verify', body: {
      'registration_token': registrationToken,
      'code': code,
    });
    final accessToken = response['access_token'] as String;
    await _storage.setToken(accessToken);
    if (response['refresh_token'] != null) {
      await _storage.setRefreshToken(response['refresh_token'] as String);
    }
    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  // Forgot password step 1: send phone → get reset_token
  Future<String> forgotPassword(String phone) async {
    final response = await _api.post('/app/auth/forgot-password', body: {
      'phone': phone,
    });
    return response['reset_token'] as String;
  }

  // Forgot password step 2: verify code
  Future<String> verifyResetCode(String resetToken, String code) async {
    final response = await _api.post('/app/auth/verify-reset-code', body: {
      'reset_token': resetToken,
      'code': code,
    });
    return response['reset_token'] as String;
  }

  // Forgot password step 3: set new password
  Future<void> resetPassword(String resetToken, String password, String passwordConfirmation) async {
    await _api.post('/app/auth/reset-password', body: {
      'reset_token': resetToken,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  // Telegram auth: initiate
  Future<Map<String, dynamic>> initiateTelegramAuth() async {
    final response = await _api.post('/app/auth/telegram/initiate');
    return response;
  }

  // Telegram auth: check status
  Future<bool> checkTelegramAuthStatus(String code) async {
    final response = await _api.get('/app/auth/telegram/status/$code');
    return response['ready'] as bool? ?? false;
  }

  // Telegram auth: verify
  Future<User> verifyTelegramAuth(String code) async {
    final response = await _api.post('/app/auth/telegram/verify', body: {
      'code': code,
    });
    final accessToken = response['access_token'] as String;
    await _storage.setToken(accessToken);
    if (response['refresh_token'] != null) {
      await _storage.setRefreshToken(response['refresh_token'] as String);
    }
    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  // Google auth: get redirect URL
  Future<String> getGoogleRedirectUrl() async {
    final response = await _api.post('/app/auth/google/redirect');
    return response['url'] as String;
  }

  // Fetch current user
  Future<User> fetchUser() async {
    final response = await _api.get('/app/auth/me', auth: true);
    final data = response is Map && response.containsKey('data')
        ? response['data'] as Map<String, dynamic>
        : response as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await _api.post('/app/auth/logout', auth: true);
    } catch (_) {}
    await _storage.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }

  Future<void> updateProfile(String name, String? lastName) async {
    await _api.put('/app/profile', body: {
      'name': name,
      'last_name': lastName,
    }, auth: true);
  }

  Future<void> changePassword(String currentPassword, String password, String passwordConfirmation) async {
    await _api.put('/app/profile/password', body: {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    }, auth: true);
  }

  Future<Map<String, dynamic>> initiateTelegramLink() async {
    final response = await _api.post('/app/profile/telegram/link', auth: true);
    return response['data'] as Map<String, dynamic>;
  }

  Future<bool> checkTelegramLinkStatus(String code) async {
    final response = await _api.get('/app/profile/telegram/link/status/$code', auth: true);
    return response['ready'] as bool? ?? false;
  }

  Future<void> verifyTelegramLink(String code) async {
    await _api.post('/app/profile/telegram/link/verify', body: {
      'code': code,
    }, auth: true);
  }

  Future<void> deleteAccount() async {
    await _api.delete('/app/profile', body: {
      'confirmation': 'DELETE',
    }, auth: true);
    await _storage.clearTokens();
  }
}
