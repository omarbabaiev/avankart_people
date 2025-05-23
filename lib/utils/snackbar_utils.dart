import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_theme.dart';

/// Basit ve tutarlı snackbar gösterimi için yardımcı sınıf.
/// Sabit boyutlu (343x50) ve borderRadius 12 olan snackbar tasarımı.
///
/// Örnek kullanım:
/// ```dart
/// // Başarı mesajı gösterme
/// SnackbarUtils.showSnackbar("İşlem başarıyla tamamlandı");
///
/// // Farklı renkle mesaj gösterme
/// SnackbarUtils.showSnackbar(
///   "Bir hata oluştu",
///   backgroundColor: AppTheme.snackbarErrorColor,
/// );
/// ```
class SnackbarUtils {
  /// Sabit boyutlu, tek satırlık snackbar gösterir.
  ///
  /// [message] gösterilecek mesaj
  /// [backgroundColor] arka plan rengi (varsayılan: AppTheme.snackbarSuccessColor)
  /// [textColor] yazı rengi (varsayılan: Colors.white)
  /// [duration] gösterim süresi (varsayılan: 3 saniye)
  /// [position] pozisyon (varsayılan: SnackPosition.TOP)
  static void showSnackbar(
    String message, {
    Color backgroundColor = AppTheme.snackBarSuccesColor,
    Color textColor = Colors.white,
    Duration? duration,
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    final screenWidth = Get.width;
    final snackbarWidth = 343.0; // Sabit 343px genişlik

    Get.snackbar(
      '', // Başlık yok
      '',
      backgroundColor: backgroundColor,
      colorText: textColor,
      borderRadius: 12,
      margin: EdgeInsets.symmetric(
        horizontal: (screenWidth - snackbarWidth) / 2,
        vertical: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      messageText: Container(
        height: 50, // Sabit 50px yükseklik
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      titleText: const SizedBox.shrink(), // Başlık olmayacak
      snackPosition: position,
      duration: duration ?? const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  /// Aktif snackbar'ı kapatır
  static void dismiss() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }
}
