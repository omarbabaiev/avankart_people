import 'package:avankart_people/utils/conts_texts.dart';
import 'package:avankart_people/utils/api_response_parser.dart';
import 'package:avankart_people/utils/debug_logger.dart';
import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/login_response.dart';
import '../models/register_response.dart';
import '../models/forgot_password_response.dart';
import '../models/home_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'firebase_service.dart';

class AuthService {
  // Base URL'i static olarak tanımla
  static String baseUrl = ConstTexts.baseUrl;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;
  FirebaseService? _firebaseService;

  FirebaseService get _firebaseServiceInstance {
    _firebaseService ??= FirebaseService();
    return _firebaseService!;
  }

  AuthService() {
    // Debug için environment bilgisini yazdır
    DebugLogger.info(LogCategory.auth, 'Environment: Production');
    DebugLogger.info(LogCategory.auth, 'Base URL: ${ConstTexts.baseUrl}');
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Sadece login ve register endpointleri hariç
        if (!(options.path.contains('/auth/login') ||
            options.path.contains('/auth/register'))) {
          final token = await _storage.read(key: SecureStorageConfig.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
    ));
  }

  Future<LoginResponse> login(
      {required String email, required String password}) async {
    try {
      // Firebase token al
      String? firebaseToken = await _firebaseServiceInstance.getAndSaveToken();

      DebugLogger.apiRequest('/people/auth/login', {
        'email': email,
        'password': '*' * password.length,
        'firebase_token': firebaseToken ?? 'null',
      });

      final response = await _dio.post(
        '/people/auth/login',
        data: {
          'email': email,
          'password': password,
          'firebase_token': firebaseToken ?? 'token',
        },
      );
      DebugLogger.apiResponse('/people/auth/login', response.data);
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        DebugLogger.apiError('/people/auth/login', e.response!.data);
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        DebugLogger.apiError('/people/auth/login', e);
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// OTP Submit
  Future<Map<String, dynamic>> submitOtp(
      {required String email,
      required String otp,
      required String token}) async {
    try {
      DebugLogger.apiRequest('/people/auth/submit-otp', {
        'email': email,
        'otp': otp,
        'token': token.substring(0, 20) + '...',
      });
      final response = await _dio.post(
        '/people/auth/submit-otp',
        data: {
          'email': email,
          'otp': otp,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      DebugLogger.apiResponse('/people/auth/submit-otp', response.data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final msg = e.response?.data['message'];
        if (msg == 'OTP already verified') {
          DebugLogger.info(LogCategory.auth,
              'OTP already verified, token: ${e.response?.data['token']}, used token: $token, otp: $otp');
        } else {
          DebugLogger.apiError('/people/auth/submit-otp', e.response!.data);
        }
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        DebugLogger.apiError('/people/auth/submit-otp', e);
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// OTP Again (Retry)
  Future<Map<String, dynamic>> retryOtp(
      {required String email, required String token}) async {
    try {
      DebugLogger.apiRequest('/people/auth/retry-otp', {'email': email});
      final response = await _dio.post(
        '/people/auth/retry-otp',
        data: {
          'email': email,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      DebugLogger.apiResponse('/people/auth/retry-otp', response.data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        DebugLogger.apiError('/people/auth/retry-otp', e.response!.data);
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        DebugLogger.apiError('/people/auth/retry-otp', e);
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// OTP Cancel
  Future<Map<String, dynamic>> cancelOtp(
      {required String email, required String token}) async {
    try {
      DebugLogger.apiRequest('/people/auth/cancel-otp', {'email': email});
      final response = await _dio.post(
        '/people/auth/cancel-otp',
        data: {
          'email': email,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      DebugLogger.apiResponse('/people/auth/cancel-otp', response.data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        DebugLogger.apiError('/people/auth/cancel-otp', e.response!.data);
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        DebugLogger.apiError('/people/auth/cancel-otp', e);
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Logout
  Future<Map<String, dynamic>?> logout() async {
    try {
      DebugLogger.info(LogCategory.auth, 'Logout requested');

      // Firebase token'ı temizle
      await _firebaseServiceInstance.clearToken();

      final response = await _dio.post(
        '/people/auth/logout',
        data: {},
      );
      debugPrint('[LOGOUT RESPONSE] ' + response.data.toString());
      return response.data;
    } on DioException catch (e) {
      // Sessiz error'ları handle et
      if (_isSilentError(e)) {
        debugPrint(
            '[LOGOUT SILENT ERROR] İnternet bağlantısı yok veya unauthorized: ${e.message}');
        return null; // Sessizce null döndür
      }

      if (e.response != null && e.response?.data != null) {
        debugPrint('[LOGOUT ERROR RESPONSE] ' + e.response!.data.toString());
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        debugPrint('[LOGOUT ERROR] Ağ hatası: ' + e.toString());
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Forgot Password
  Future<ForgotPasswordResponse> forgotPassword({required String email}) async {
    try {
      debugPrint('[FORGOT PASSWORD REQUEST] email: ' + email);
      final response = await _dio.post(
        '/people/auth/forgot-password',
        data: {
          'email': email,
        },
      );
      debugPrint('[FORGOT PASSWORD RESPONSE] ' + response.data.toString());
      return ForgotPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        debugPrint(
            '[FORGOT PASSWORD ERROR RESPONSE] ' + e.response!.data.toString());
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        debugPrint('[FORGOT PASSWORD ERROR] Ağ hatası: ' + e.toString());
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Register
  Future<RegisterResponse> register({
    required String name,
    required String surname,
    required String username,
    required String birthDate,
    required String email,
    required String phoneSuffix,
    required String phoneNumber,
    required String gender,
    required String password,
    required String passwordAgain,
    required bool terms,
  }) async {
    try {
      debugPrint(
          '[REGISTER REQUEST] name: $name, surname: $surname, email: $email, phone: +$phoneSuffix $phoneNumber');
      final response = await _dio.post(
        '/people/auth/register',
        data: {
          'name': name,
          'surname': surname,
          'username': username,
          'birth_date': birthDate,
          'email': email,
          'phone_suffix': phoneSuffix,
          'phone_number': phoneNumber,
          'gender': gender,
          'password': password,
          'password_again': passwordAgain,
          'terms': terms,
        },
      );
      debugPrint('[REGISTER RESPONSE] ' + response.data.toString());
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        debugPrint('[REGISTER ERROR RESPONSE] ' + e.response!.data.toString());
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        debugPrint('[REGISTER ERROR] Ağ hatası: ' + e.toString());
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Home
  Future<HomeResponse?> home() async {
    try {
      // Token'ı storage'dan oku
      final tokenToUse = await _storage.read(key: SecureStorageConfig.tokenKey);
      debugPrint('[HOME REQUEST] Token: ${tokenToUse?.substring(0, 20)}...');
      debugPrint('[DEBUG] Full token: $tokenToUse');
      debugPrint('[DEBUG] Token length: ${tokenToUse?.length}');

      // Firebase token al
      String? firebaseToken = await _firebaseServiceInstance.getStoredToken();
      debugPrint(
          '[HOME REQUEST] Firebase Token: ${firebaseToken?.substring(0, 20)}...');

      final response = await _dio.post(
        '/people/home',
        data: {
          'firebase_token': firebaseToken ?? 'token',
        },
      );
      debugPrint('[HOME RESPONSE] ' + response.data.toString());
      return HomeResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Hata kategorilerini belirle
      if (_isTokenInvalidError(e)) {
        debugPrint('[HOME TOKEN INVALID] Token geçersiz, logout gerekli');
        // Token geçersiz - logout yap
        await _handleTokenInvalid();
        return null;
      } else if (_isLogoutRequiredError(e)) {
        debugPrint('[HOME LOGOUT REQUIRED] Status 2 veya logout gerekli');
        // Status 2 veya logout gerekli - logout yap
        await _handleLogoutRequired();
        return null;
      } else if (_isNetworkError(e)) {
        debugPrint(
            '[HOME NETWORK ERROR] Ağ hatası, retry gerekli: ${e.message}');
        // Ağ hatası - retry butonu göster
        throw AuthException('network_error_retry'.tr);
      } else {
        debugPrint('[HOME OTHER ERROR] Diğer hata: ${e.message}');
        // Diğer hatalar - retry butonu göster
        if (e.response != null && e.response?.data != null) {
          final errorMessage =
              ApiResponseParser.parseApiError(e.response?.data);
          throw AuthException('$errorMessage (retry_available)');
        } else {
          throw AuthException('network_error_retry'.tr);
        }
      }
    }
  }

  /// Submit New Password (Forgot Password akışı için)
  Future<Map<String, dynamic>> submitNewPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      debugPrint('[SUBMIT NEW PASSWORD REQUEST]');
      final response = await _dio.post(
        '/people/auth/submit-forgotten-password',
        data: {
          'new_password': newPassword,
          'password_again': confirmPassword,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      debugPrint('[SUBMIT NEW PASSWORD RESPONSE] ' + response.data.toString());
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        debugPrint(
            '[SUBMIT NEW PASSWORD ERROR] ' + e.response!.data.toString());
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        debugPrint('[SUBMIT NEW PASSWORD ERROR] Ağ hatası: ' + e.toString());
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// OTP'yi yeniden gönder (JSON-da /auth/retry-otp endpoint-i)
  Future<Map<String, dynamic>> resendOtp({
    required String email,
    required String token,
  }) async {
    try {
      DebugLogger.apiRequest('/people/auth/retry-otp', {
        'email': email,
      });
      debugPrint(
          '[RESEND OTP REQUEST] email: $email, token: ${token.substring(0, 20)}...');
      final response = await _dio.post(
        '/people/auth/retry-otp', // JSON-da /auth/retry-otp endpoint-i istifadə olunur
        data: {
          'email': email,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      DebugLogger.apiResponse('/people/auth/retry-otp', response.data);
      debugPrint('[RESEND OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[RESEND OTP ERROR] ${e.response?.data}');
      if (e.response != null && e.response?.data != null) {
        DebugLogger.apiError('/people/auth/retry-otp', e.response!.data);
        throw AuthException(ApiResponseParser.parseApiError(e.response?.data));
      } else {
        DebugLogger.apiError('/people/auth/retry-otp', e);
        debugPrint('[RESEND OTP ERROR] Ağ hatası: ${e.toString()}');
        throw AuthException('network_error'.tr + ': ${e.message}');
      }
    }
  }

  /// Token'ı kaydet
  Future<void> saveToken(String token) async {
    await _storage.write(key: SecureStorageConfig.tokenKey, value: token);
    debugPrint('[TOKEN SAVED] $token');
  }

  /// İnternet bağlantısı kontrolü
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Token geçersiz hatalarını kontrol et (401, token expired, etc.)
  bool _isTokenInvalidError(DioException e) {
    return e.response?.statusCode == 401 ||
        (e.response?.data != null &&
            e.response?.data['message']
                    ?.toString()
                    .toLowerCase()
                    .contains('token') ==
                true) ||
        (e.response?.data != null &&
            e.response?.data['error']
                    ?.toString()
                    .toLowerCase()
                    .contains('token') ==
                true);
  }

  /// Logout gerekli hatalarını kontrol et (status 2)
  bool _isLogoutRequiredError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      return data['status'] == 2 ||
          data['status'] == '2' ||
          (data['message']?.toString().toLowerCase().contains('logout') ==
              true);
    }
    return false;
  }

  /// Ağ hatalarını kontrol et (timeout, connection error)
  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.unknown;
  }

  /// Token geçersiz durumunda logout yap
  Future<void> _handleTokenInvalid() async {
    await _storage.delete(key: SecureStorageConfig.tokenKey);
    debugPrint('[AUTH SERVICE] Token invalid, cleared storage');
  }

  /// Logout gerekli durumunda logout yap
  Future<void> _handleLogoutRequired() async {
    await _storage.delete(key: SecureStorageConfig.tokenKey);
    debugPrint('[AUTH SERVICE] Logout required, cleared storage');
  }

  /// Unauthorized error'ı sessizce handle et (eski metod - geriye uyumluluk için)
  bool _isSilentError(DioException e) {
    // İnternet bağlantısı yoksa veya unauthorized ise sessizce handle et
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.response?.statusCode == 401;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
