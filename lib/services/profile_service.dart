import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../utils/api_response_parser.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'firebase_service.dart';

class ProfileService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  FirebaseService? _firebaseService;

  FirebaseService get _firebaseServiceInstance {
    _firebaseService ??= FirebaseService();
    return _firebaseService!;
  }

  ProfileService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // / Kullanıcı bilgilerini getir (raw response ile)
  Future<Map<String, dynamic>?> getProfileRaw() async {
    try {
      print('[GET PROFILE RAW REQUEST]');

      // Firebase token al
      String? firebaseToken = await _firebaseServiceInstance.getStoredToken();
      print(
          '[GET PROFILE RAW REQUEST] Firebase Token: ${firebaseToken?.substring(0, 20)}...');

      final response = await _dio.post(
        '/home',
        data: {
          'firebase_token': firebaseToken ?? 'token',
        },
      );
      print('[GET PROFILE RAW RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      // Sessiz error'ları handle et
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.response?.statusCode == 401) {
        print(
            '[GET PROFILE RAW SILENT ERROR] İnternet bağlantısı yok veya unauthorized: ${e.message}');
        return null; // Sessizce null döndür
      }

      print('[GET PROFILE RAW ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Kullanıcı bilgilerini getir
  Future<UserModel?> getProfile() async {
    try {
      print('[GET PROFILE REQUEST]');
      final response = await _dio.post('/home');
      print('[GET PROFILE RESPONSE] ${response.data}');

      if (response.data['user'] != null) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw ProfileException('user_data_not_found'.tr);
      }
    } on DioException catch (e) {
      // Sessiz error'ları handle et
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.response?.statusCode == 401) {
        print(
            '[GET PROFILE SILENT ERROR] İnternet bağlantısı yok veya unauthorized: ${e.message}');
        return null; // Sessizce null döndür
      }

      print('[GET PROFILE ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Profil değişikliği için OTP gönder
  Future<Map<String, dynamic>> requestChange({
    required String duty,
    String? phoneSuffix,
    String? phone,
    String? birthDate,
    String? email,
    String? nameSurname,
    String? oldPassword,
    String? newPassword,
    String? confirmNewPassword,
  }) async {
    try {
      print('[REQUEST CHANGE] duty: $duty');
      final data = {
        'duty': duty,
        if (phoneSuffix != null) 'phone_suffix': phoneSuffix,
        if (phone != null) 'phone': phone,
        if (birthDate != null) 'birth_date': birthDate,
        if (email != null) 'email': email,
        if (nameSurname != null) 'name_surname': nameSurname,
        if (oldPassword != null) 'old_password': oldPassword,
        if (newPassword != null) 'new_password': newPassword,
        if (confirmNewPassword != null)
          'confirm_new_password': confirmNewPassword,
      };
      print('[REQUEST CHANGE REQUEST] $data');

      final response = await _dio.post(
        '/profile/request-change',
        data: data,
      );
      print('[REQUEST CHANGE RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[REQUEST CHANGE ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// OTP kodunu doğrula
  Future<Map<String, dynamic>> submitOTP({required String otp}) async {
    try {
      print('[SUBMIT OTP REQUEST] otp: $otp');
      final response = await _dio.post(
        '/profile/otp-submit',
        data: {'otp': otp},
      );
      print('[SUBMIT OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[SUBMIT OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// OTP kodunu yeniden gönder
  Future<Map<String, dynamic>> resendOTP() async {
    try {
      print('[RESEND OTP REQUEST]');
      final response = await _dio.post('/profile/otp-resend');
      print('[RESEND OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[RESEND OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// OTP işlemini iptal et
  Future<Map<String, dynamic>> cancelOTP() async {
    try {
      print('[CANCEL OTP REQUEST]');
      final response = await _dio.post('/profile/otp-cancel');
      print('[CANCEL OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[CANCEL OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Hesap silme isteği başlat (Şifre doğrulama)
  Future<Map<String, dynamic>> initiateAccountDeletion({
    required String password,
  }) async {
    try {
      print('[INITIATE DELETE ACCOUNT REQUEST]');
      final response = await _dio.post(
        '/auth/delete-account',
        data: {
          'delete': true,
          'password': password,
        },
      );
      print('[INITIATE DELETE ACCOUNT RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[INITIATE DELETE ACCOUNT ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Hesap silme OTP doğrulama
  Future<Map<String, dynamic>> submitDeleteOTP({
    required String otp,
  }) async {
    try {
      print('[SUBMIT DELETE OTP REQUEST] otp: $otp');
      final response = await _dio.post(
        '/profile/delete-otp-submit',
        data: {'otp': otp},
      );
      print('[SUBMIT DELETE OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[SUBMIT DELETE OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Hesap silme işlemini onayla
  Future<Map<String, dynamic>> confirmAccountDeletion() async {
    try {
      print('[CONFIRM DELETE ACCOUNT REQUEST]');
      final response = await _dio.post(
        '/auth/delete-account',
        data: {'delete': true, 'confirm': true},
      );
      print('[CONFIRM DELETE ACCOUNT RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[CONFIRM DELETE ACCOUNT ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Profil silme için OTP gönder
  Future<Map<String, dynamic>> requestDeleteProfile() async {
    try {
      print('[REQUEST DELETE PROFILE]');
      final response = await _dio.post(
        '/profile/request-change',
        data: {
          'duty': 'deleteProfile',
        },
      );
      print('[REQUEST DELETE PROFILE RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[REQUEST DELETE PROFILE ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Profil silme OTP doğrulama
  Future<Map<String, dynamic>> submitDeleteProfileOTP({
    required String otp,
  }) async {
    try {
      print('[SUBMIT DELETE PROFILE OTP REQUEST] otp: $otp');
      final response = await _dio.post(
        '/profile/delete-otp-submit',
        data: {'otp': otp},
      );
      print('[SUBMIT DELETE PROFILE OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('[SUBMIT DELETE PROFILE OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Profil güncelleme için OTP gönder (requestChange wrapper)
  Future<Map<String, dynamic>> sendUpdateOTP({
    required String field,
    required String newValue,
  }) async {
    String duty = '';
    Map<String, dynamic> data = {};

    // Field tipine göre duty ve data hazırla
    switch (field) {
      case 'phone':
        duty = 'updateNumber';
        // Phone number format: +994501112233
        if (newValue.startsWith('+')) {
          String phoneCode = newValue.substring(1, 4); // 994
          String phoneNumber = newValue.substring(4); // 501112233
          data['phone_suffix'] = phoneCode;
          data['phone'] = phoneNumber;
        } else {
          // Fallback: assume 994 if no country code
          data['phone_suffix'] = '994';
          data['phone'] = newValue;
        }
        break;
      case 'email':
        duty = 'updateEmail';
        data['email'] = newValue;
        break;
      case 'name_surname':
        duty = 'updateName';
        data['name'] = newValue;
        break;
      case 'birth_date':
        duty = 'updateBirthDate';
        data['birth_date'] = newValue;
        break;
      case 'password':
        duty = 'updatePassword';
        // newValue should be "old_password|new_password|confirm_new_password"
        List<String> passwords = newValue.split('|');
        if (passwords.length == 3) {
          data['old_password'] = passwords[0];
          data['new_password'] = passwords[1];
          data['confirm_new_password'] = passwords[2];
        } else {
          throw ProfileException('invalid_password_format'.tr);
        }
        break;
      default:
        throw ProfileException('invalid_field'.tr + ': $field');
    }

    return await requestChange(
      duty: duty,
      phoneSuffix: data['phone_suffix'],
      phone: data['phone'],
      email: data['email'],
      nameSurname: data['name'],
      birthDate: data['birth_date'],
      oldPassword: data['old_password'],
      newPassword: data['new_password'],
      confirmNewPassword: data['confirm_new_password'],
    );
  }

  /// Profil güncelleme OTP doğrulama (submitOTP wrapper)
  Future<Map<String, dynamic>> verifyUpdateOTP({
    required String field,
    required String newValue,
    required String otp,
  }) async {
    return await submitOTP(otp: otp);
  }
}

class ProfileException implements Exception {
  final String message;
  ProfileException(this.message);
  @override
  String toString() => message;
}
