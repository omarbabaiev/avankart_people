import 'package:flutter/services.dart';

class VibrationUtil {
  // Hafif titreşim efekti
  static Future<void> lightVibrate() async {
    await HapticFeedback.lightImpact();
  }

  // Orta titreşim efekti
  static Future<void> mediumVibrate() async {
    await HapticFeedback.mediumImpact();
  }

  // Güçlü titreşim efekti
  static Future<void> heavyVibrate() async {
    await HapticFeedback.heavyImpact();
  }

  // Seçim titreşim efekti
  static Future<void> selectionVibrate() async {
    await HapticFeedback.selectionClick();
  }
}
