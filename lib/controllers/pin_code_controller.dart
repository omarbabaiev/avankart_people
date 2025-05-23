import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinCodeController extends GetxController {
  final RxString pin = ''.obs;
  final RxBool isConfirmScreen = false.obs;
  final RxString firstPin = ''.obs;
  final RxBool shouldShake = false.obs;
  final int pinLength = 4;

  void addDigit(String digit) {
    if (pin.value.length < pinLength) {
      pin.value = pin.value + digit;

      // PIN kod tamamlandıysa
      if (pin.value.length == pinLength) {
        if (!isConfirmScreen.value) {
          // Birinci ekranda PIN kod tamamlandı, ikinci ekrana geç
          firstPin.value = pin.value;
          pin.value = '';
          isConfirmScreen.value = true;
        } else {
          // İkinci ekranda PIN kod tamamlandı, doğrula
          validatePin();
        }
      }
    }
  }

  void removeLastDigit() {
    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
    }
  }

  void validatePin() {
    if (pin.value == firstPin.value) {
      // PIN kodlar eşleşiyor
      savePin();
      Get.back(result: true);
    } else {
      // PIN kodlar eşleşmiyor, shake animasyonu başlat
      shouldShake.value = true;
      Future.delayed(Duration(milliseconds: 500), () {
        shouldShake.value = false;
      });

      // PIN kodları sıfırla ve ilk ekrana dön
      resetPin();
    }
  }

  void resetPin() {
    pin.value = '';
    firstPin.value = '';
    isConfirmScreen.value = false;
  }

  Future<void> savePin() async {
    // PIN kodunu güvenli bir şekilde kaydet
    // Gerçek uygulamada secure storage kullanılmalı
    print('PIN kod kaydedildi: $pin');
  }
}
