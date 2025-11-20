import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'secure_storage_config.dart';
import 'package:flutter/material.dart';

class TokenDebug {
  static final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  /// Token'ın mevcut durumunu kontrol et
  static Future<void> debugTokenStatus() async {
    debugPrint('=== TOKEN DEBUG START ===');

    // Token'ı oku
    final token = await _storage.read(key: SecureStorageConfig.tokenKey);
    final rememberMe = GetStorage().read('rememberMe');

    debugPrint('[TOKEN DEBUG] Token: ${token?.substring(0, 20)}...');
    debugPrint('[TOKEN DEBUG] Token length: ${token?.length}');
    debugPrint('[TOKEN DEBUG] Token is null: ${token == null}');
    debugPrint('[TOKEN DEBUG] Token is empty: ${token?.isEmpty}');
    debugPrint('[TOKEN DEBUG] RememberMe: $rememberMe');

    // Tüm key'leri listele
    final allKeys = await _storage.readAll();
    debugPrint('[TOKEN DEBUG] All stored keys: ${allKeys.keys.toList()}');

    debugPrint('=== TOKEN DEBUG END ===');
  }

  /// Token'ı test et
  static Future<void> testTokenStorage(String testToken) async {
    debugPrint('=== TOKEN STORAGE TEST START ===');

    // Test token'ı kaydet
    await _storage.write(key: SecureStorageConfig.tokenKey, value: testToken);
    debugPrint(
        '[TOKEN TEST] Test token saved: ${testToken.substring(0, 20)}...');

    // Hemen oku
    final savedToken = await _storage.read(key: SecureStorageConfig.tokenKey);
    debugPrint(
        '[TOKEN TEST] Immediately read: ${savedToken?.substring(0, 20)}...');
    debugPrint('[TOKEN TEST] Matches: ${savedToken == testToken}');

    // Kısa bir bekleme sonra tekrar oku
    await Future.delayed(const Duration(milliseconds: 100));
    final delayedToken = await _storage.read(key: SecureStorageConfig.tokenKey);
    debugPrint(
        '[TOKEN TEST] After delay: ${delayedToken?.substring(0, 20)}...');
    debugPrint('[TOKEN TEST] Still matches: ${delayedToken == testToken}');

    debugPrint('=== TOKEN STORAGE TEST END ===');
  }
}
