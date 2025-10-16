import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:avankart_people/utils/vibration_util.dart';

class ToastUtils {
  static void showToast(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    ToastGravity? gravity,
    int? timeInSecForIosWeb,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: timeInSecForIosWeb ?? 1,
      backgroundColor: backgroundColor ?? Get.theme.colorScheme.inverseSurface,
      textColor: textColor ?? Get.theme.colorScheme.onInverseSurface,
      fontSize: 14.0,
    );
  }

  static void showSuccessToast(String message) {
    // Başarı toast'ı - haptic feedback
    VibrationUtil.selectionVibrate();

    showToast(
      message,
      backgroundColor: Theme.of(Get.context!).colorScheme.onBackground,
      textColor: Theme.of(Get.context!).scaffoldBackgroundColor,
    );
  }

  static void showErrorToast(String message) {
    // Hata toast'ı - haptic feedback
    VibrationUtil.heavyVibrate();

    showToast(
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static void showCopyToast() {
    // Kopyalama toast'ı - haptic feedback
    VibrationUtil.lightVibrate();
    showSuccessToast('copied'.tr);
  }
}
