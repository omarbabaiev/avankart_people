import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_config.dart';

class TokenDebug {
  static final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  /// Token'ın mevcut durumunu kontrol et
  static Future<void> debugTokenStatus() async {
    print('=== TOKEN DEBUG START ===');

    // Token'ı oku
    final token = await _storage.read(key: SecureStorageConfig.tokenKey);
    final rememberMe =
        await _storage.read(key: SecureStorageConfig.rememberMeKey);

    print('[TOKEN DEBUG] Token: ${token?.substring(0, 20)}...');
    print('[TOKEN DEBUG] Token length: ${token?.length}');
    print('[TOKEN DEBUG] Token is null: ${token == null}');
    print('[TOKEN DEBUG] Token is empty: ${token?.isEmpty}');
    print('[TOKEN DEBUG] RememberMe: $rememberMe');

    // Tüm key'leri listele
    final allKeys = await _storage.readAll();
    print('[TOKEN DEBUG] All stored keys: ${allKeys.keys.toList()}');

    print('=== TOKEN DEBUG END ===');
  }

  /// Token'ı test et
  static Future<void> testTokenStorage(String testToken) async {
    print('=== TOKEN STORAGE TEST START ===');

    // Test token'ı kaydet
    await _storage.write(key: SecureStorageConfig.tokenKey, value: testToken);
    print('[TOKEN TEST] Test token saved: ${testToken.substring(0, 20)}...');

    // Hemen oku
    final savedToken = await _storage.read(key: SecureStorageConfig.tokenKey);
    print('[TOKEN TEST] Immediately read: ${savedToken?.substring(0, 20)}...');
    print('[TOKEN TEST] Matches: ${savedToken == testToken}');

    // Kısa bir bekleme sonra tekrar oku
    await Future.delayed(const Duration(milliseconds: 100));
    final delayedToken = await _storage.read(key: SecureStorageConfig.tokenKey);
    print('[TOKEN TEST] After delay: ${delayedToken?.substring(0, 20)}...');
    print('[TOKEN TEST] Still matches: ${delayedToken == testToken}');

    print('=== TOKEN STORAGE TEST END ===');
  }
}
