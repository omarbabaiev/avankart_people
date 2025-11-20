import 'package:avankart_people/utils/api_response_parser.dart';
import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'firebase_service.dart';
import 'package:flutter/material.dart';


class ProfileService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl,
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

  /// PIN kodunu backend ile doğrula
  Future<bool> checkPinCode({required String pinCode}) async {
    try {
      debugPrint('[CHECK PIN REQUEST] pin: ****');
      final response = await _dio.post(
        '/people/profile/pin/check',
        data: {
          'pin_code': pinCode,
        },
      );
      debugPrint('[CHECK PIN RESPONSE] ${response.data}');
      // Başarılı sayılması için success == true beklenir
      return response.data is Map &&
          (response.data['success'] == true ||
              response.data['message']?.toString().toLowerCase() == 'ok');
    } on DioException catch (e) {
      debugPrint('[CHECK PIN ERROR] ${e.response?.data}');
      // Backend yanlış pin'de 4xx dönebilir; false dönelim
      if (e.response != null) {
        return false;
      }
      throw ProfileException(ApiResponseParser.parseDioError(e));
    }
  }

  ProfileService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: SecureStorageConfig.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// Kullanıcı bilgilerini getir (raw response ile)
  Future<Map<String, dynamic>?> getProfileRaw() async {
    try {
      debugPrint('[GET PROFILE RAW REQUEST]');

      // Firebase token al
      String? firebaseToken = await _firebaseServiceInstance.getStoredToken();
      debugPrint(
          '[GET PROFILE RAW REQUEST] Firebase Token: ${firebaseToken?.substring(0, 20)}...');

      final response = await _dio.post(
        '/people/home',
        data: {
          'firebase_token': firebaseToken ?? 'token',
        },
      );
      debugPrint('[GET PROFILE RAW RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      // Sessiz error'ları handle et
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.response?.statusCode == 401) {
        debugPrint(
            '[GET PROFILE RAW SILENT ERROR] İnternet bağlantısı yok veya unauthorized: ${e.message}');
        return null; // Sessizce null döndür
      }

      debugPrint('[GET PROFILE RAW ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Kullanıcı bilgilerini getir
  Future<UserModel?> getProfile() async {
    try {
      debugPrint('[GET PROFILE REQUEST]');
      final response = await _dio.post('/people/home');
      debugPrint('[GET PROFILE RESPONSE] ${response.data}');

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
        debugPrint(
            '[GET PROFILE SILENT ERROR] İnternet bağlantısı yok veya unauthorized: ${e.message}');
        return null; // Sessizce null döndür
      }

      debugPrint('[GET PROFILE ERROR] ${e.response?.data}');
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
    String? gender,
  }) async {
    try {
      debugPrint('[REQUEST CHANGE] duty: $duty');
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
        if (gender != null) 'gender': gender,
      };
      debugPrint('[REQUEST CHANGE REQUEST] $data');

      final response = await _dio.post(
        '/people/profile/request-change',
        data: data,
      );
      debugPrint('[REQUEST CHANGE RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[REQUEST CHANGE ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// OTP kodunu doğrula
  Future<Map<String, dynamic>> submitOTP({required String otp}) async {
    try {
      debugPrint('[SUBMIT OTP REQUEST] otp: $otp');
      final response = await _dio.post(
        '/people/profile/otp-submit',
        data: {'otp': otp},
      );
      debugPrint('[SUBMIT OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[SUBMIT OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// OTP kodunu yeniden gönder
  Future<Map<String, dynamic>> resendOTP() async {
    try {
      debugPrint('[RESEND OTP REQUEST]');
      final response = await _dio.post('/people/profile/otp-resend');
      debugPrint('[RESEND OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[RESEND OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// OTP işlemini iptal et
  Future<Map<String, dynamic>> cancelOTP() async {
    try {
      debugPrint('[CANCEL OTP REQUEST]');
      final response = await _dio.post('/people/profile/otp-cancel');
      debugPrint('[CANCEL OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[CANCEL OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Hesap silme isteği başlat (Şifre doğrulama)
  Future<Map<String, dynamic>> initiateAccountDeletion({
    required String password,
  }) async {
    try {
      debugPrint('[INITIATE DELETE ACCOUNT REQUEST]');
      final response = await _dio.post(
        '/people/auth/delete-account',
        data: {
          'delete': true,
          'password': password,
        },
      );
      debugPrint('[INITIATE DELETE ACCOUNT RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[INITIATE DELETE ACCOUNT ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Hesap silme OTP doğrulama
  Future<Map<String, dynamic>> submitDeleteOTP({
    required String otp,
  }) async {
    try {
      debugPrint('[SUBMIT DELETE OTP REQUEST] otp: $otp');
      final response = await _dio.post(
        '/people/profile/delete-otp-submit',
        data: {'otp': otp},
      );
      debugPrint('[SUBMIT DELETE OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[SUBMIT DELETE OTP ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Hesap silme işlemini onayla
  Future<Map<String, dynamic>> confirmAccountDeletion() async {
    try {
      debugPrint('[CONFIRM DELETE ACCOUNT REQUEST]');
      final response = await _dio.post(
        '/people/auth/delete-account',
        data: {'delete': true, 'confirm': true},
      );
      debugPrint('[CONFIRM DELETE ACCOUNT RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[CONFIRM DELETE ACCOUNT ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Profil silme için OTP gönder
  Future<Map<String, dynamic>> requestDeleteProfile() async {
    try {
      debugPrint('[REQUEST DELETE PROFILE]');
      final response = await _dio.post(
        '/people/profile/request-change',
        data: {
          'duty': 'deleteProfile',
        },
      );
      debugPrint('[REQUEST DELETE PROFILE RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[REQUEST DELETE PROFILE ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Profil silme OTP doğrulama
  Future<Map<String, dynamic>> submitDeleteProfileOTP({
    required String otp,
  }) async {
    try {
      debugPrint('[SUBMIT DELETE PROFILE OTP REQUEST] otp: $otp');
      final response = await _dio.post(
        '/people/profile/delete-otp-submit',
        data: {'otp': otp},
      );
      debugPrint('[SUBMIT DELETE PROFILE OTP RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[SUBMIT DELETE PROFILE OTP ERROR] ${e.response?.data}');
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
      case 'gender':
        duty = 'updateGender';
        data['gender'] = newValue; // 'male' or 'female'
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
      gender: data['gender'],
    );
  }

  /// Profil değişikliğini uygula (apply-change endpoint)
  Future<Map<String, dynamic>> applyChange({
    required String otp,
  }) async {
    try {
      debugPrint('[APPLY CHANGE REQUEST] otp: $otp');
      final response = await _dio.post(
        '/people/profile/apply-change',
        data: {'otp': otp},
      );
      debugPrint('[APPLY CHANGE RESPONSE] ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[APPLY CHANGE ERROR] ${e.response?.data}');
      throw ProfileException(ApiResponseParser.parseApiError(e.response?.data));
    }
  }

  /// Profil güncelleme OTP doğrulama (applyChange wrapper)
  Future<Map<String, dynamic>> verifyUpdateOTP({
    required String field,
    required String newValue,
    required String otp,
  }) async {
    return await applyChange(otp: otp);
  }
}

class ProfileException implements Exception {
  final String message;
  ProfileException(this.message);
  @override
  String toString() => message;
}
