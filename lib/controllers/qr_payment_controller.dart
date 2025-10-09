import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/services/qr_service.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:avankart_people/widgets/bottom_sheets/manual_qr_input_bottom_sheet.dart';
import 'package:avankart_people/widgets/bottom_sheets/payment_confirmation_bottom_sheet.dart';
import 'package:avankart_people/models/qr_check_response_model.dart';

class QrPaymentController extends GetxController {
  final QrService _qrService = QrService();

  // State variables
  final RxDouble balance = 148.50.obs;
  final RxString cardName = 'food_card'.tr.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString currentQrCode = ''.obs;
  final RxString currentQrCodeId = ''.obs;
  final RxString currentCardId = ''.obs;
  final RxString qrStatus = 'pending'.obs;
  final Rx<QrCheckData?> qrCheckData = Rx<QrCheckData?>(null);

  @override
  void onInit() {
    super.onInit();
    // Seçili kartın ID'sini al
    _getSelectedCardId();
  }

  // Seçili kartın ID'sini al
  void _getSelectedCardId() {
    try {
      if (Get.isRegistered<CardController>()) {
        final cardController = Get.find<CardController>();
        print(
            '[QR PAYMENT CONTROLLER] Cards count: ${cardController.cards.length}');
        print(
            '[QR PAYMENT CONTROLLER] Selected payment index: ${cardController.selectedPaymentIndex.value}');

        if (cardController.cards.isNotEmpty &&
            cardController.selectedPaymentIndex.value >= 0 &&
            cardController.selectedPaymentIndex.value <
                cardController.cards.length) {
          final selectedCard =
              cardController.cards[cardController.selectedPaymentIndex.value];
          currentCardId.value = selectedCard['cardId'] ?? '';
          cardName.value = selectedCard['title'] ?? 'card'.tr;
          balance.value = (selectedCard['balance'] ?? 0.0).toDouble();

          print(
              '[QR PAYMENT CONTROLLER] Selected card: ${selectedCard['title']}');
          print('[QR PAYMENT CONTROLLER] Card ID: ${selectedCard['cardId']}');
          print('[QR PAYMENT CONTROLLER] Balance: ${selectedCard['balance']}');
        } else {
          print('[QR PAYMENT CONTROLLER] No valid card selected');
        }
      }
    } catch (e) {
      print('[QR PAYMENT CONTROLLER] Error getting selected card: $e');
      // Error mesajını gösterme, sadece log'la
    }
  }

  // QR kodu açıp kapamak için
  void toggleFlash() {
    isFlashOn.value = !isFlashOn.value;
    print('[QR PAYMENT CONTROLLER] Flash toggled: ${isFlashOn.value}');
  }

  // QR kod scanner'ını aç - Artık screen içinde
  void showQrScanner() {
    print('[QR PAYMENT CONTROLLER] QR Scanner artık screen içinde aktif');
    // QR scanner artık screen içinde çalışıyor, sadece manuel giriş seçeneği sun
    showManualQrInput();
  }

  // Manuel QR kod girişi bottom sheet'ini aç
  void showManualQrInput() {
    print('[QR PAYMENT CONTROLLER] ===== SHOW MANUAL QR INPUT =====');
    print('[QR PAYMENT CONTROLLER] Opening manual QR input bottom sheet...');

    Get.bottomSheet(
      ManualQrInputBottomSheet(
        onQrCodeEntered: (qrCode) {
          print('[QR PAYMENT CONTROLLER] QR Code entered: $qrCode');
          print('[QR PAYMENT CONTROLLER] Calling checkQrCode directly...');
          // QR kod girildi, direkt olarak checkQrCode API'sini çağır
          checkQrCode(qrCode.toUpperCase());
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    print('[QR PAYMENT CONTROLLER] ===================================');
  }

  // Ödeme onayı bottom sheet'ini aç
  void _showPaymentConfirmation(QrCheckData qrData) {
    print('[QR PAYMENT CONTROLLER] ===== SHOW PAYMENT CONFIRMATION =====');
    print('[QR PAYMENT CONTROLLER] QR Data: ${qrData.toJson()}');

    // API'den gelen verilerle ödeme verilerini hazırla
    final paymentData = {
      'amount': qrData.amount,
      'transaction_id': qrData.transactionId,
      'card_type': qrData.cardName ?? cardName.value,
      'payment_date': _formatTimestamp(qrData.timestamp),
      'receiving_institution': qrData.muessiseName ?? 'Müəssisə',
      'paying_company': qrData.sirketName ?? 'Şirkət',
      'payer_id': qrData.userSirketId,
      'qr_code_id': qrData.qrCodeId,
      'expire_time': _formatTimestamp(qrData.expireTime),
    };

    print('[QR PAYMENT CONTROLLER] Payment Data: $paymentData');
    print(
        '[QR PAYMENT CONTROLLER] Opening payment confirmation bottom sheet...');

    Get.bottomSheet(
      PaymentConfirmationBottomSheet(
        paymentData: paymentData,
        onConfirm: () {
          print(
              '[QR PAYMENT CONTROLLER] Payment confirmed, calling checkQrStatus...');
          // Ödeme onaylandı, checkQrStatus API'sini çağır
          _checkQrStatus(qrData.qrCodeId);
        },
        onCancel: () {
          print('[QR PAYMENT CONTROLLER] Payment cancelled...');
          // Ödeme iptal edildi
          SnackbarUtils.showSuccessSnackbar(
            'payment_cancelled'.tr,
            textColor: Colors.white,
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    print('[QR PAYMENT CONTROLLER] =====================================');
  }

  // ISO timestamp'i formatla
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.tryParse(timestamp);
      if (dateTime == null) return '';
      return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  // QR kodunu kontrol et
  Future<void> checkQrCode(String qrData) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      currentQrCode.value = qrData;
      qrStatus.value = 'checking';

      print('[QR PAYMENT CONTROLLER] ===== CHECK QR CODE =====');
      print('[QR PAYMENT CONTROLLER] QR Data: $qrData');
      print('[QR PAYMENT CONTROLLER] Card ID: ${currentCardId.value}');
      print('[QR PAYMENT CONTROLLER] =========================');

      final response = await _qrService.checkQrCode(
        qrCode: qrData,
        cardId: currentCardId.value,
      );

      if (response != null && response.success) {
        print('[QR PAYMENT CONTROLLER] QR Check successful');
        print('[QR PAYMENT CONTROLLER] Response: ${response.message}');

        // QR verilerini sakla
        if (response.data != null) {
          qrCheckData.value = response.data!;
          currentQrCodeId.value = response.data!.qrCodeId;
          print('[QR PAYMENT CONTROLLER] QR Data: ${response.data!.toJson()}');
        }

        // Başarılı mesaj göster
        SnackbarUtils.showSuccessSnackbar(
          response.message,
          textColor: Colors.white,
        );

        // Success true ise preview göster
        print(
            '[QR PAYMENT CONTROLLER] Success true, showing payment preview...');
        if (response.data != null) {
          _showPaymentConfirmation(response.data!);
        }
      } else {
        throw Exception(response?.message ?? 'QR kod kontrol edilemedi');
      }
    } catch (e) {
      print('[QR PAYMENT CONTROLLER] QR Check error: $e');
      qrStatus.value = 'error';

      // Sadece parser'dan çıkarılmış error mesajını göster
      String errorMessage = 'QR kod kontrol edilemedi';
      if (e is QrException) {
        errorMessage = e.message;
      }

      SnackbarUtils.showErrorSnackbar(
        errorMessage,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // QR durumunu kontrol et
  Future<void> _checkQrStatus(String qrCodeId) async {
    if (qrCodeId.isEmpty) return;

    try {
      print('[QR PAYMENT CONTROLLER] ===== CHECK QR STATUS =====');
      print('[QR PAYMENT CONTROLLER] QR Code ID: $qrCodeId');
      print('[QR PAYMENT CONTROLLER] Card ID: ${currentCardId.value}');
      print('[QR PAYMENT CONTROLLER] ===========================');

      final response = await _qrService.checkQrStatus(
        qrCodeId: qrCodeId,
        cardId: currentCardId.value,
      );

      if (response != null && response.success) {
        print('[QR PAYMENT CONTROLLER] QR Status check successful');
        print('[QR PAYMENT CONTROLLER] Status: ${response.status}');
        print('[QR PAYMENT CONTROLLER] Message: ${response.message}');

        qrStatus.value = response.status ?? 'completed';

        if (response.status == 'completed' || response.status == 'success') {
          // Ödeme başarılı
          SnackbarUtils.showSuccessSnackbar(
            response.message,
            textColor: Colors.white,
          );

          // Kart bakiyesini güncelle
          _updateCardBalance();

          // Ekranı kapat
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        } else if (response.status == 'failed' || response.status == 'error') {
          // Ödeme başarısız
          SnackbarUtils.showErrorSnackbar(
            response.message,
            textColor: Colors.white,
          );
          qrStatus.value = 'error';
        } else {
          // Hala işleniyor, tekrar kontrol et
          Future.delayed(const Duration(seconds: 2), () {
            _checkQrStatus(qrCodeId);
          });
        }
      } else {
        throw Exception(response?.message ?? 'QR durumu kontrol edilemedi');
      }
    } catch (e) {
      print('[QR PAYMENT CONTROLLER] QR Status check error: $e');
      qrStatus.value = 'error';

      // Sadece parser'dan çıkarılmış error mesajını göster
      String errorMessage = 'QR durumu kontrol edilemedi';
      if (e is QrException) {
        errorMessage = e.message;
      }

      SnackbarUtils.showErrorSnackbar(
        errorMessage,
        textColor: Colors.white,
      );
    }
  }

  // Kart bakiyesini güncelle
  void _updateCardBalance() {
    try {
      if (Get.isRegistered<CardController>()) {
        final cardController = Get.find<CardController>();
        // Kart controller'ı yenile
        cardController.loadMyCards();
      }
    } catch (e) {
      print('[QR PAYMENT CONTROLLER] Error updating card balance: $e');
      // Error mesajını gösterme, sadece log'la
    }
  }

  // QR ödeme işlemini iptal et
  void cancelQrPayment() {
    currentQrCode.value = '';
    currentQrCodeId.value = '';
    qrStatus.value = 'pending';
    isLoading.value = false;
  }

  // QR taramayı yeniden başlat
  void restartScanning() {
    qrStatus.value = 'pending';
    isLoading.value = false;
    currentQrCode.value = '';
    print('[QR PAYMENT CONTROLLER] Scanning restarted');
  }

  // Geri tuşuna basınca
  void onClose() {
    cancelQrPayment();
    Get.back();
  }
}
