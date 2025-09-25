import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageConfig {
  static const FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'avankart_people_secure_prefs',
      preferencesKeyPrefix: 'avankart_people',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  // Token storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String rememberMeKey = 'remember_me';
  static const String userDataKey = 'user_data';
  static const String firebaseTokenKey = 'firebase_token';
  static const String pinCodeKey = 'pin_code';
  static const String biometricEnabledKey = 'biometric_enabled';
}
