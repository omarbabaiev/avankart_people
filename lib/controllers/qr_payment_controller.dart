import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/services/qr_service.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:avankart_people/utils/vibration_util.dart';
import 'package:avankart_people/widgets/bottom_sheets/manual_qr_input_bottom_sheet.dart';
import 'package:avankart_people/widgets/bottom_sheets/payment_confirmation_bottom_sheet.dart';
import 'package:avankart_people/models/qr_check_response_model.dart';

class QrPaymentController extends GetxController {
  final QrService _qrService = QrService();

  // State variables
  final RxDouble balance = 0.0.obs;
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

    // Card controller'dan balance güncellemelerini dinle
    _listenToCardUpdates();
  }

  // Seçili kartın ID'sini al
  void _getSelectedCardId() {
    try {
      if (Get.isRegistered<CardController>()) {
        final cardController = Get.find<CardController>();
        debugPrint(
            '[QR PAYMENT CONTROLLER] Cards count: ${cardController.cards.length}');
        debugPrint(
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

          debugPrint(
              '[QR PAYMENT CONTROLLER] Selected card: ${selectedCard['title']}');
          debugPrint(
              '[QR PAYMENT CONTROLLER] Card ID: ${selectedCard['cardId']}');
          debugPrint(
              '[QR PAYMENT CONTROLLER] Balance: ${selectedCard['balance']}');
        } else {
          debugPrint('[QR PAYMENT CONTROLLER] No valid card selected');
        }
      }
    } catch (e) {
      debugPrint('[QR PAYMENT CONTROLLER] Error getting selected card: $e');
      // Error mesajını gösterme, sadece log'la
    }
  }

  // Card controller'dan balance güncellemelerini dinle
  void _listenToCardUpdates() {
    try {
      if (Get.isRegistered<CardController>()) {
        final cardController = Get.find<CardController>();

        // Cards listesini dinle
        ever(cardController.cards, (List<Map<String, dynamic>> cards) {
          _updateBalanceFromCards(cards);
        });

        // Selected payment index'i dinle
        ever(cardController.selectedPaymentIndex, (int index) {
          _updateBalanceFromCards(cardController.cards);
        });
      }
    } catch (e) {
      debugPrint('[QR PAYMENT CONTROLLER] Error listening to card updates: $e');
    }
  }

  // Cards listesinden balance'ı güncelle
  void _updateBalanceFromCards(List<Map<String, dynamic>> cards) {
    try {
      if (Get.isRegistered<CardController>()) {
        final cardController = Get.find<CardController>();
        final selectedIndex = cardController.selectedPaymentIndex.value;

        if (cards.isNotEmpty &&
            selectedIndex >= 0 &&
            selectedIndex < cards.length) {
          final selectedCard = cards[selectedIndex];
          currentCardId.value = selectedCard['cardId'] ?? '';
          cardName.value = selectedCard['title'] ?? 'card'.tr;
          balance.value = (selectedCard['balance'] ?? 0.0).toDouble();

          debugPrint(
              '[QR PAYMENT CONTROLLER] Balance updated: ${balance.value}');
        }
      }
    } catch (e) {
      debugPrint(
          '[QR PAYMENT CONTROLLER] Error updating balance from cards: $e');
    }
  }

  // QR kodu açıp kapamak için
  void toggleFlash() {
    // Flash toggle - haptic feedback
    VibrationUtil.lightVibrate();

    isFlashOn.value = !isFlashOn.value;
    debugPrint('[QR PAYMENT CONTROLLER] Flash toggled: ${isFlashOn.value}');
  }

  // QR kod scanner'ını aç - Artık screen içinde
  void showQrScanner() {
    debugPrint('[QR PAYMENT CONTROLLER] QR Scanner artık screen içinde aktif');
    // QR scanner artık screen içinde çalışıyor, sadece manuel giriş seçeneği sun
    showManualQrInput();
  }

  // Manuel QR kod girişi bottom sheet'ini aç
  void showManualQrInput() {
    // Manuel QR girişi açma - haptic feedback
    VibrationUtil.lightVibrate();

    debugPrint('[QR PAYMENT CONTROLLER] ===== SHOW MANUAL QR INPUT =====');
    debugPrint(
        '[QR PAYMENT CONTROLLER] Opening manual QR input bottom sheet...');

    Get.bottomSheet(
      ManualQrInputBottomSheet(
        onQrCodeEntered: (qrCode) {
          debugPrint('[QR PAYMENT CONTROLLER] QR Code entered: $qrCode');
          debugPrint('[QR PAYMENT CONTROLLER] Calling checkQrCode directly...');
          // QR kod girildi, direkt olarak checkQrCode API'sini çağır
          checkQrCode(qrCode.toUpperCase());
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    debugPrint('[QR PAYMENT CONTROLLER] ===================================');
  }

  // Ödeme onayı bottom sheet'ini aç
  void _showPaymentConfirmation(QrCheckData qrData) {
    debugPrint('[QR PAYMENT CONTROLLER] ===== SHOW PAYMENT CONFIRMATION =====');
    debugPrint('[QR PAYMENT CONTROLLER] QR Data: ${qrData.toJson()}');

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

    debugPrint('[QR PAYMENT CONTROLLER] Payment Data: $paymentData');
    debugPrint(
        '[QR PAYMENT CONTROLLER] Opening payment confirmation bottom sheet...');

    Get.bottomSheet(
      PaymentConfirmationBottomSheet(
        paymentData: paymentData,
        onConfirm: () async {
          // Ödeme onayı - haptic feedback
          VibrationUtil.mediumVibrate();

          debugPrint(
              '[QR PAYMENT CONTROLLER] Payment confirmed, calling checkQrStatus...');
          // Önce card balance'ı güncelle (yeni bakiye için request at)
          await _updateCardBalance();
          // Ödeme onaylandı, checkQrStatus API'sini çağır
          _checkQrStatus(qrData.qrCodeId);
        },
        onCancel: () {
          // Ödeme iptali - haptic feedback
          VibrationUtil.lightVibrate();

          debugPrint('[QR PAYMENT CONTROLLER] Payment cancelled...');
          // Ödeme iptal edildi, scanner'ı yeniden başlat
          restartScanning();
          
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

    debugPrint('[QR PAYMENT CONTROLLER] =====================================');
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
      // QR kod kontrolü başlatma - haptic feedback
      VibrationUtil.lightVibrate();

      isLoading.value = true;
      currentQrCode.value = qrData;
      qrStatus.value = 'checking';

      debugPrint('[QR PAYMENT CONTROLLER] ===== CHECK QR CODE =====');
      debugPrint('[QR PAYMENT CONTROLLER] QR Data: $qrData');
      debugPrint('[QR PAYMENT CONTROLLER] Card ID: ${currentCardId.value}');
      debugPrint('[QR PAYMENT CONTROLLER] =========================');

      final response = await _qrService.checkQrCode(
        qrCode: qrData,
        cardId: currentCardId.value,
      );

      if (response != null && response.success) {
        // QR kod kontrolü başarılı - haptic feedback
        VibrationUtil.mediumVibrate();

        debugPrint('[QR PAYMENT CONTROLLER] QR Check successful');
        debugPrint('[QR PAYMENT CONTROLLER] Response: ${response.message}');

        // QR verilerini sakla
        if (response.data != null) {
          qrCheckData.value = response.data!;
          currentQrCodeId.value = response.data!.qrCodeId;
          debugPrint(
              '[QR PAYMENT CONTROLLER] QR Data: ${response.data!.toJson()}');
        }

        // Başarılı mesaj göster
        SnackbarUtils.showSuccessSnackbar(
          response.message,
          textColor: Colors.white,
        );

        // Success true ise preview göster
        debugPrint(
            '[QR PAYMENT CONTROLLER] Success true, showing payment preview...');
        if (response.data != null) {
          _showPaymentConfirmation(response.data!);
        }
      } else {
        throw Exception(response?.message ?? 'QR kod kontrol edilemedi');
      }
    } catch (e) {
      // QR kod kontrolü hatası - haptic feedback
      VibrationUtil.heavyVibrate();

      debugPrint('[QR PAYMENT CONTROLLER] QR Check error: $e');
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
      debugPrint('[QR PAYMENT CONTROLLER] ===== CHECK QR STATUS =====');
      debugPrint('[QR PAYMENT CONTROLLER] QR Code ID: $qrCodeId');
      debugPrint('[QR PAYMENT CONTROLLER] Card ID: ${currentCardId.value}');
      debugPrint('[QR PAYMENT CONTROLLER] ===========================');

      final response = await _qrService.checkQrStatus(
        qrCodeId: qrCodeId,
        cardId: currentCardId.value,
      );

      if (response != null && response.success) {
        debugPrint('[QR PAYMENT CONTROLLER] QR Status check successful');
        debugPrint('[QR PAYMENT CONTROLLER] Status: ${response.status}');
        debugPrint('[QR PAYMENT CONTROLLER] Message: ${response.message}');

        qrStatus.value = response.status ?? 'completed';

        if (response.status == 'completed' || response.status == 'success') {
          // Ödeme başarılı - haptic feedback
          VibrationUtil.mediumVibrate();

          // Kart bakiyesini güncelle
          _updateCardBalance();

          // Ödeme başarılı ekranını göster
          _showPaymentResultScreen(true, response.message);
        } else if (response.status == 'failed' || response.status == 'error') {
          // Ödeme başarısız - haptic feedback
          VibrationUtil.heavyVibrate();

          // Ödeme başarısız ekranını göster
          _showPaymentResultScreen(false, response.message);
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
      // QR durum kontrolü hatası - haptic feedback
      VibrationUtil.heavyVibrate();

      debugPrint('[QR PAYMENT CONTROLLER] QR Status check error: $e');
      qrStatus.value = 'error';

      // Sadece parser'dan çıkarılmış error mesajını göster
      String errorMessage = 'QR durumu kontrol edilemedi';
      if (e is QrException) {
        errorMessage = e.message;

        // Eğer "QR code already used" hatası ise, bu aslında ödeme başarılı demektir
        if (errorMessage.toLowerCase().contains('already used') ||
            errorMessage.toLowerCase().contains('zaten kullanılmış') ||
            errorMessage.toLowerCase().contains('artıq istifadə edilib') ||
            errorMessage.toLowerCase().contains('уже использован')) {
          debugPrint(
              '[QR PAYMENT CONTROLLER] QR code already used - payment was successful');

          // Ödeme başarılı olarak işle
          VibrationUtil.mediumVibrate();

          // Kart bakiyesini güncelle
          _updateCardBalance();

          // Ödeme başarılı ekranını göster
          _showPaymentResultScreen(true, 'qr_payment_successful'.tr);
          return;
        }
      }

      SnackbarUtils.showErrorSnackbar(
        errorMessage,
        textColor: Colors.white,
      );
    }
  }

  // Kart bakiyesini güncelle
  Future<void> _updateCardBalance() async {
    try {
      if (Get.isRegistered<CardController>()) {
        final cardController = Get.find<CardController>();
        debugPrint('[QR PAYMENT CONTROLLER] Updating card balance and transactions...');
        
        // Önce kartları yenile
        await cardController.loadMyCards();
        
        // Kartlar yüklendikten sonra transaction'ları da yenile
        // Seçili kartın transaction'larını refresh et
        if (cardController.cards.isNotEmpty) {
          final selectedIndex = cardController.selectedPaymentIndex.value.clamp(
            0, 
            cardController.cards.length - 1
          );
          final selectedCard = cardController.cards[selectedIndex];
          final cardId = selectedCard['cardId'] as String?;
          
          if (cardId != null && cardId.isNotEmpty) {
            debugPrint('[QR PAYMENT CONTROLLER] Refreshing transactions for card: $cardId');
            await cardController.loadCardTransactions(
              cardId: cardId,
              refresh: true, // Force refresh to show updated balance
            );
          }
        }
        
        debugPrint('[QR PAYMENT CONTROLLER] Card balance and transactions updated successfully');
      }
    } catch (e) {
      debugPrint('[QR PAYMENT CONTROLLER] Error updating card balance: $e');
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
  final RxBool shouldRestartScanning = false.obs;
  
  void restartScanning() {
    qrStatus.value = 'pending';
    isLoading.value = false;
    currentQrCode.value = '';
    shouldRestartScanning.value = !shouldRestartScanning.value; // Toggle to trigger rebuild
    debugPrint('[QR PAYMENT CONTROLLER] Scanning restarted');
  }

  // Geri tuşuna basınca
  void onClose() {
    cancelQrPayment();
    Get.back();
  }

  // Ödeme sonuç ekranını göster
  void _showPaymentResultScreen(bool isSuccess, String message) {
    debugPrint(
        '[QR PAYMENT CONTROLLER] ===== SHOW PAYMENT RESULT SCREEN =====');
    debugPrint(
        '[QR PAYMENT CONTROLLER] Success: $isSuccess, Message: $message');

    // Ödeme verilerini hazırla
    final paymentData = {
      'amount': qrCheckData.value?.amount ?? '0.00',
      'transaction_id':
          qrCheckData.value?.transactionId ?? 'TRX-XXXXXXXXXXXXXX',
      'card_type': qrCheckData.value?.cardName ?? cardName.value,
      'payment_date': qrCheckData.value != null
          ? _formatTimestamp(qrCheckData.value!.timestamp)
          : '31.12.2024, 13:22:16',
      'receiving_institution':
          qrCheckData.value?.muessiseName ?? 'Özsüt Restoran',
      'paying_company': qrCheckData.value?.sirketName ?? 'Şirkət',
      'payer_id': qrCheckData.value?.userSirketId ?? 'RO-321',
    };

    debugPrint('[QR PAYMENT CONTROLLER] Payment Data: $paymentData');

    // Mevcut ekranları kapat ve yeni ekranı göster
    Get.toNamed('/payment-result', arguments: {
      'isSuccess': isSuccess,
      'paymentData': paymentData,
      'errorMessage': message,
    });

    debugPrint('[QR PAYMENT CONTROLLER] =====================================');
  }
}
