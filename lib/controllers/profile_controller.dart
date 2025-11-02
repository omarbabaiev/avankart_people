import 'package:avankart_people/utils/auth_utils.dart';

import '../utils/snackbar_utils.dart';
import '../utils/api_response_parser.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../routes/app_routes.dart';
import 'home_controller.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  final profile = Rxn<UserModel>();
  final isLoading = false.obs;
  final isDeletingAccount = false.obs;

  // Email değiştirme için text controller'lar
  final currentEmailController = TextEditingController();
  final newEmailController = TextEditingController();

  // Email validation error messages
  final currentEmailError = RxnString();
  final newEmailError = RxnString();

  // Retry functionality
  final RxBool showRetryButton = false.obs;
  final RxString retryMessage = ''.obs;

  // Hesap silme durumları
  final isPasswordVerified = false.obs;
  final isOtpVerified = false.obs;

  // Profil güncelleme OTP durumları
  final isVerificationRequired = false.obs;
  final isOtpSending = false.obs;
  final isOtpVerifying = false.obs;
  final otpRemainingTime = 0.obs;
  Timer? _otpTimer;
  DateTime? _otpEndTime; // OTP-nin bitmə vaxtı (wall-clock)

  // Güncellenecek veri
  String _pendingUpdateField = '';
  String _pendingUpdateValue = '';

  @override
  void onInit() {
    super.onInit();
    // getProfile() çağrısını kaldırdık - sadece manuel olarak çağrılacak
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      showRetryButton.value = false;
      retryMessage.value = '';

      final response = await _profileService.getProfile();

      // Eğer null döndüyse (internet yok veya unauthorized), sessizce handle et
      if (response == null) {
        return; // Mevcut profile data'yı koru
      }

      // Check if logout is required (status 2)
      // Check if logout is required (status 2) - UserModel'den status kontrol et
      if (response != null && response.status == 2) {
        await AuthUtils.forceLogout();
        return;
      }

      profile.value = response;
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);

      // Global retry dialog'u göster
      final homeController = Get.find<HomeController>();
      // homeController.showGlobalRetryDialog(
      //   errorMessage,
      //   getProfile,
      // );
    } finally {
      isLoading.value = false;
    }
  }

  // Profil bilgilerini güncelle
  void updateProfile(UserModel newProfile) {
    profile.value = newProfile;
  }

  /// Hesap silme işlemini başlat - Şifre doğrulama
  Future<bool> initiateAccountDeletion(String password) async {
    try {
      isDeletingAccount.value = true;

      final response = await _profileService.initiateAccountDeletion(
        password: password,
      );

      isPasswordVerified.value = true;
      SnackbarUtils.showSuccessSnackbar('delete_account_otp_sent'.tr);
      return true;
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isDeletingAccount.value = false;
    }
  }

  /// OTP kodunu doğrula
  Future<bool> verifyDeleteOTP(String otp) async {
    try {
      isDeletingAccount.value = true;

      await _profileService.submitDeleteOTP(otp: otp);

      isOtpVerified.value = true;
      SnackbarUtils.showSuccessSnackbar(
        'delete_account_otp_verified'.tr,
      );
      return true;
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(e.toString());
      return false;
    } finally {
      isDeletingAccount.value = false;
    }
  }

  /// Hesap silme işlemini tamamla
  Future<bool> confirmAccountDeletion() async {
    if (!isPasswordVerified.value || !isOtpVerified.value) {
      SnackbarUtils.showErrorSnackbar(
          'Zəhmət olmasa əvvəlcə şifrə və OTP doğrulamasını tamamlayın');
      return false;
    }

    try {
      isDeletingAccount.value = true;

      await _profileService.confirmAccountDeletion();

      // Hesap silindi, login ekranına yönlendir
      Get.offAllNamed(AppRoutes.login);

      return true;
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(e.toString());
      return false;
    } finally {
      isDeletingAccount.value = false;
    }
  }

  /// Hesap silme işlemini iptal et
  void cancelAccountDeletion() {
    isPasswordVerified.value = false;
    isOtpVerified.value = false;
    isDeletingAccount.value = false;
  }

  /// Retry butonuna basıldığında çağrılır
  Future<void> retryProfile() async {
    if (isLoading.value) return; // Çift tıklamayı önle

    showRetryButton.value = false;
    retryMessage.value = '';

    await getProfile();
  }

  /// Hatanın retry edilebilir olup olmadığını kontrol et
  bool _isRetryableError(String errorMessage) {
    return errorMessage.contains('network_error') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('Bağlantı') ||
        errorMessage.contains('internet') ||
        errorMessage.contains('Network') ||
        errorMessage.contains('Connection');
  }

  /// Hata mesajını çıkar
  String _extractErrorMessage(String errorMessage) {
    if (errorMessage.contains('network_error')) {
      return 'network_error_retry'.tr;
    } else if (errorMessage.contains('connection') ||
        errorMessage.contains('timeout')) {
      return 'network_error_retry'.tr;
    }

    return errorMessage;
  }

  /// Profil güncelleme için OTP gönder
  Future<bool> sendUpdateOTP(String field, String newValue) async {
    try {
      isOtpSending.value = true;
      _pendingUpdateField = field;
      _pendingUpdateValue = newValue;

      final response = await _profileService.sendUpdateOTP(
        field: field,
        newValue: newValue,
      );

      // OTP timer'ı başlat
      _startOtpTimer();
      isVerificationRequired.value = true;

      SnackbarUtils.showSuccessSnackbar('update_otp_sent'.tr);
      return true;
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(e.toString());
      return false;
    } finally {
      isOtpSending.value = false;
    }
  }

  /// Profil güncelleme OTP'sini doğrula ve güncellemeyi gerçekleştir
  Future<bool> verifyUpdateOTP(String otp) async {
    try {
      isOtpVerifying.value = true;

      final response = await _profileService.verifyUpdateOTP(
        field: _pendingUpdateField,
        newValue: _pendingUpdateValue,
        otp: otp,
      );

      // Profili yeniden yükle
      await getProfile();

      _stopOtpTimer();
      isVerificationRequired.value = false;
      _clearPendingUpdate();

      SnackbarUtils.showSuccessSnackbar('Profil uğurla yeniləndi');
      return true;
    } catch (e) {
      SnackbarUtils.showErrorSnackbar(e.toString());
      return false;
    } finally {
      isOtpVerifying.value = false;
    }
  }

  /// OTP timer'ını başlat (4 dakika 59 saniye) - Wall-clock time əsasında
  void _startOtpTimer() {
    _stopOtpTimer(); // Mevcut timer'ı durdur

    // Wall-clock time əsasında bitmə vaxtını təyin et
    _otpEndTime = DateTime.now().add(const Duration(seconds: 299));
    otpRemainingTime.value = 299; // 4:59

    // Hər 100ms-də bir yoxla (daha dəqiq və background-dan qayıdışda düzgün işləyir)
    _otpTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateOtpRemainingTime();
      if (otpRemainingTime.value <= 0) {
        _stopOtpTimer();
        isVerificationRequired.value = false;
        _clearPendingUpdate();
      }
    });
  }

  /// OTP timer'ını durdur
  void _stopOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
    _otpEndTime = null;
  }

  /// OTP qalan vaxtını yenilə (wall-clock time əsasında)
  void _updateOtpRemainingTime() {
    if (_otpEndTime == null) return;

    final now = DateTime.now();
    final difference = _otpEndTime!.difference(now);

    otpRemainingTime.value = difference.inSeconds.clamp(0, 299);
  }

  /// Bekleyen güncelleme verilerini temizle
  void _clearPendingUpdate() {
    _pendingUpdateField = '';
    _pendingUpdateValue = '';
  }

  /// OTP süresini formatla (M:SS)
  String get formattedOtpTime {
    int minutes = otpRemainingTime.value ~/ 60;
    int seconds = otpRemainingTime.value % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// OTP tekrar gönder
  Future<bool> resendOTP() async {
    if (_pendingUpdateField.isEmpty || _pendingUpdateValue.isEmpty) {
      return false;
    }
    return await sendUpdateOTP(_pendingUpdateField, _pendingUpdateValue);
  }

  /// Profil güncelleme işlemini iptal et
  void cancelUpdateVerification() {
    _stopOtpTimer();
    isVerificationRequired.value = false;
    _clearPendingUpdate();
  }

  /// Şifre değiştirme için OTP gönder
  Future<bool> sendPasswordChangeOTP(String currentPassword, String newPassword,
      String confirmNewPassword) async {
    try {
      isOtpSending.value = true;

      String passwordData = '$currentPassword|$newPassword|$confirmNewPassword';

      final response = await _profileService.sendUpdateOTP(
        field: 'password',
        newValue: passwordData,
      );

      // OTP timer'ı başlat
      _startOtpTimer();
      isVerificationRequired.value = true;
      _pendingUpdateField = 'password';
      _pendingUpdateValue = passwordData;

      SnackbarUtils.showSuccessSnackbar('password_change_otp_sent'.tr);
      return true;
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isOtpSending.value = false;
    }
  }

  /// Şifre değiştirme OTP'sini doğrula
  Future<bool> verifyPasswordChangeOTP(String otp) async {
    try {
      isOtpVerifying.value = true;

      await _profileService.verifyUpdateOTP(
        field: 'password',
        newValue: _pendingUpdateValue,
        otp: otp,
      );

      _stopOtpTimer();
      isVerificationRequired.value = false;
      _clearPendingUpdate();

      SnackbarUtils.showSuccessSnackbar('password_changed_successfully'.tr);
      return true;
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isOtpVerifying.value = false;
    }
  }

  /// Profil silme için OTP gönder
  Future<bool> requestDeleteProfile() async {
    try {
      isOtpSending.value = true;
      _pendingUpdateField = 'deleteProfile';
      _pendingUpdateValue = '';

      final response = await _profileService.requestDeleteProfile();

      // OTP timer'ı başlat
      _startOtpTimer();
      isVerificationRequired.value = true;

      SnackbarUtils.showSuccessSnackbar('delete_account_otp_sent'.tr);
      return true;
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isOtpSending.value = false;
    }
  }

  /// Profil silme OTP'sini doğrula ve hesabı sil
  Future<bool> submitDeleteProfileOTP(String otp) async {
    try {
      isOtpVerifying.value = true;

      final response = await _profileService.submitDeleteProfileOTP(otp: otp);

      // Başarılı olursa force logout yap (hesap silme işlemi)
      await AuthUtils.forceLogout();

      SnackbarUtils.showSuccessSnackbar('delete_account_success'.tr);
      return true;
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isOtpVerifying.value = false;
    }
  }

  @override
  void onClose() {
    _stopOtpTimer();
    currentEmailController.dispose();
    newEmailController.dispose();
    super.onClose();
  }

  // E-posta değiştirme isteği gönder
  Future<bool> requestEmailChange() async {
    try {
      isOtpSending.value = true;
      _pendingUpdateField = 'email';
      _pendingUpdateValue = newEmailController.text;

      final response = await _profileService.sendUpdateOTP(
        field: 'email',
        newValue: newEmailController.text,
      );

      // OTP timer'ı başlat
      _startOtpTimer();
      isVerificationRequired.value = true;

      SnackbarUtils.showSuccessSnackbar('email_change_otp_sent'.tr);
      return true;
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isOtpSending.value = false;
    }
  }

  // E-posta değiştirme OTP'sini doğrula
  Future<bool> submitEmailChangeOTP(String otp) async {
    try {
      isOtpVerifying.value = true;

      await _profileService.verifyUpdateOTP(
        field: 'email',
        newValue: _pendingUpdateValue,
        otp: otp,
      );

      _stopOtpTimer();
      isVerificationRequired.value = false;
      _clearPendingUpdate();

      SnackbarUtils.showSuccessSnackbar('email_change_success'.tr);
      return true;
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isOtpVerifying.value = false;
    }
  }
}
