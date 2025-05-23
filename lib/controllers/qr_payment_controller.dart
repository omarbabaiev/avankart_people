import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QrPaymentController extends GetxController {
  final RxDouble balance = 148.50.obs;
  final RxString cardName = 'Yemək Kartı'.obs;
  final RxBool isFlashOn = false.obs;

  // QR kodu açıp kapamak için
  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
  }

  // Manuel giriş sayfasına gitmek için
  void navigateToManualEntry() {
    // Get.to(() => ManualPaymentScreen());
    Get.back(); // Geçici çözüm - sadece geri git
  }

  // QR ödeme işlemini tamamla
  void processQrPayment(String qrData) {
    // QR kodundan ödeme işlemi yapılacak
    // Gerçek uygulamada burada API çağrısı yapılır
    Get.snackbar(
      'Ödəniş edildi',
      'QR kodu ilə ödəniş uğurla tamamlandı',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.back();
  }

  // Geri tuşuna basınca
  void onClose() {
    Get.back();
  }
}
