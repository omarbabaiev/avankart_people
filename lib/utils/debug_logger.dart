import 'package:flutter/foundation.dart';

enum LogLevel {
  error,
  warning,
  info,
  debug,
}

enum LogCategory {
  api,
  auth,
  controller,
  firebase,
  navigation,
  storage,
  ui,
  url,
  qr,
  notifications,
  profile,
  general,
}

class DebugLogger {
  // Debug modunu kontrol eden basit değişken
  // Release modunda otomatik olarak false olur
  static bool _isDebugEnabled =
      kDebugMode && !const bool.fromEnvironment('dart.vm.product');

  // Manuel olarak debug'ı açıp kapatmak için (sadece debug modunda çalışır)
  static bool _manualDebugEnabled = true;

  // Tüm log seviyeleri ve kategorileri varsayılan olarak açık
  static Set<LogLevel> _enabledLevels = {
    LogLevel.error,
    LogLevel.warning,
    LogLevel.info,
    LogLevel.debug,
  };
  static Set<LogCategory> _enabledCategories = LogCategory.values.toSet();

  // Debug modunu açıp kapatma (sadece debug modunda çalışır)
  static void setDebugEnabled(bool enabled) {
    // Release modunda debug'ı açmaya izin verme
    if (const bool.fromEnvironment('dart.vm.product')) {
      return;
    }
    _manualDebugEnabled = enabled;
  }

  // Belirli log seviyelerini açıp kapatma
  static void setLogLevels(Set<LogLevel> levels) {
    _enabledLevels = levels;
  }

  // Belirli kategorileri açıp kapatma
  static void setLogCategories(Set<LogCategory> categories) {
    _enabledCategories = categories;
  }

  // Tüm kategorileri açma
  static void enableAllCategories() {
    _enabledCategories = LogCategory.values.toSet();
  }

  // Tüm kategorileri kapatma
  static void disableAllCategories() {
    _enabledCategories.clear();
  }

  // Belirli kategoriyi açma
  static void enableCategory(LogCategory category) {
    _enabledCategories.add(category);
  }

  // Belirli kategoriyi kapatma
  static void disableCategory(LogCategory category) {
    _enabledCategories.remove(category);
  }

  // Ana log metodu
  static void log(
    LogLevel level,
    LogCategory category,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Release modunda hiçbir log gösterme
    if (const bool.fromEnvironment('dart.vm.product')) {
      return;
    }

    // Debug modu kapalıysa log gösterme
    if (!_isDebugEnabled || !_manualDebugEnabled) {
      return;
    }

    if (!_enabledLevels.contains(level) ||
        !_enabledCategories.contains(category)) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelEmoji = _getLevelEmoji(level);
    final categoryName = category.name.toUpperCase();

    String logMessage = '[$timestamp] $levelEmoji [$categoryName] $message';

    if (error != null) {
      logMessage += '\nError: $error';
    }

    if (stackTrace != null) {
      logMessage += '\nStackTrace: $stackTrace';
    }

    debugPrint(logMessage);
  }

  // Kolay kullanım metodları
  static void error(LogCategory category, String message,
      {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.error, category, message,
        error: error, stackTrace: stackTrace);
  }

  static void warning(LogCategory category, String message,
      {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.warning, category, message,
        error: error, stackTrace: stackTrace);
  }

  static void info(LogCategory category, String message,
      {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.info, category, message, error: error, stackTrace: stackTrace);
  }

  static void debug(LogCategory category, String message,
      {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.debug, category, message,
        error: error, stackTrace: stackTrace);
  }

  // API özel metodları
  static void apiRequest(String endpoint, Map<String, dynamic>? data) {
    DebugLogger.debug(LogCategory.api, 'REQUEST: $endpoint\nData: $data');
  }

  static void apiResponse(String endpoint, dynamic response) {
    DebugLogger.debug(LogCategory.api, 'RESPONSE: $endpoint\nData: $response');
  }

  static void apiError(String endpoint, Object error) {
    DebugLogger.error(LogCategory.api, 'ERROR: $endpoint', error: error);
  }

  // Controller özel metodları
  static void controllerAction(String controller, String action,
      {Map<String, dynamic>? data}) {
    DebugLogger.debug(
        LogCategory.controller, '$controller.$action()\nData: $data');
  }

  static void controllerError(String controller, String action, Object error) {
    DebugLogger.error(LogCategory.controller, '$controller.$action() failed',
        error: error);
  }

  // Navigation özel metodları
  static void navigation(String from, String to,
      {Map<String, dynamic>? arguments}) {
    DebugLogger.info(
        LogCategory.navigation, '$from → $to\nArguments: $arguments');
  }

  // Firebase özel metodları
  static void firebase(String action, {Object? data, Object? error}) {
    if (error != null) {
      DebugLogger.error(LogCategory.firebase, 'Firebase $action failed',
          error: error);
    } else {
      DebugLogger.info(
          LogCategory.firebase, 'Firebase $action successful\nData: $data');
    }
  }

  // QR özel metodları
  static void qr(String action, {Object? data, Object? error}) {
    if (error != null) {
      DebugLogger.error(LogCategory.qr, 'QR $action failed', error: error);
    } else {
      DebugLogger.info(LogCategory.qr, 'QR $action successful\nData: $data');
    }
  }

  // URL/Launcher özel metodları
  static void urlLaunch(String url, String type, {Object? error}) {
    if (error != null) {
      DebugLogger.error(LogCategory.url, 'Failed to launch $type: $url',
          error: error);
    } else {
      DebugLogger.debug(LogCategory.url, 'Launched $type: $url');
    }
  }

  // Helper metodları
  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return '❌';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.debug:
        return '🔍';
    }
  }

  // Debug durumunu kontrol etme
  static bool get isDebugEnabled =>
      _isDebugEnabled &&
      _manualDebugEnabled &&
      !const bool.fromEnvironment('dart.vm.product');

  static Set<LogLevel> get enabledLevels => Set.from(_enabledLevels);

  static Set<LogCategory> get enabledCategories => Set.from(_enabledCategories);
}
