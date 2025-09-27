import 'package:avankart_people/utils/secure_storage_config.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/register_response.dart';
import '../utils/snackbar_utils.dart';
import '../utils/api_response_parser.dart';
import '../routes/app_routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegisterController extends GetxController {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final RxBool isLoading = false.obs;
  final RxBool isFormValid = false.obs;

  // Form controllers
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString email = ''.obs;
  final RxString birthDate = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxString phoneSuffix = '994'.obs;
  final RxBool agreeToTerms = false.obs;

  void updateFirstName(String value) {
    firstName.value = value;
    _checkFormValidity();
  }

  void updateLastName(String value) {
    lastName.value = value;
    _checkFormValidity();
  }

  void updateEmail(String value) {
    email.value = value;
    _checkFormValidity();
  }

  void updateBirthDate(String value) {
    birthDate.value = value;
    _checkFormValidity();
  }

  void updatePhoneNumber(String value) {
    phoneNumber.value = value;
    _checkFormValidity();
  }

  void updatePassword(String value) {
    password.value = value;
    _checkFormValidity();
  }

  void updateConfirmPassword(String value) {
    confirmPassword.value = value;
    _checkFormValidity();
  }

  void updateSelectedGender(String value) {
    selectedGender.value = value;
    _checkFormValidity();
  }

  void updatePhoneSuffix(String value) {
    phoneSuffix.value = value;
    print('[REGISTER CONTROLLER] Phone suffix updated to: $value');
  }

  void updateAgreeToTerms(bool value) {
    agreeToTerms.value = value;
    _checkFormValidity();
  }

  void _checkFormValidity() {
    isFormValid.value = firstName.value.isNotEmpty &&
        lastName.value.isNotEmpty &&
        email.value.isNotEmpty &&
        birthDate.value.isNotEmpty &&
        phoneNumber.value.isNotEmpty &&
        password.value.isNotEmpty &&
        confirmPassword.value.isNotEmpty &&
        selectedGender.value.isNotEmpty &&
        agreeToTerms.value;
  }

  Future<void> register() async {
    if (!isFormValid.value) {
      SnackbarUtils.showErrorSnackbar('please_fill_all_fields'.tr);
      return;
    }

    if (password.value != confirmPassword.value) {
      SnackbarUtils.showErrorSnackbar('passwords_not_match'.tr);
      return;
    }

    if (!agreeToTerms.value) {
      SnackbarUtils.showErrorSnackbar('please_accept_terms_conditions'.tr);
      return;
    }

    isLoading.value = true;

    try {
      // Username oluştur (email'den @ öncesi kısmı al)
      final username = email.value.split('@')[0];

      // Phone number'dan boşlukları kaldır
      final cleanPhoneNumber = phoneNumber.value.replaceAll(' ', '');

      final response = await _authService.register(
        name: firstName.value,
        surname: lastName.value,
        username: username,
        birthDate: birthDate.value,
        email: email.value,
        phoneSuffix: phoneSuffix.value,
        phoneNumber: cleanPhoneNumber,
        gender: selectedGender.value,
        password: password.value,
        passwordAgain: confirmPassword.value,
        terms: agreeToTerms.value,
      );

      if (response.token != null && response.token!.isNotEmpty) {
        // Token'ı kaydet
        await _storage.write(
            key: SecureStorageConfig.tokenKey, value: response.token);
        print('[REGISTER SUCCESS] Token saved: ${response.token}');

        // OTP ekranına yönlendir (register'dan geldiğini belirt)
        print('[REGISTER SUCCESS] Navigating to OTP');
        Get.toNamed(AppRoutes.otp, arguments: {
          'email': email.value,
          'token': response.token,
          'isRegister': true,
        });
      } else {
        SnackbarUtils.showErrorSnackbar(
            'registration_successful_but_no_token'.tr);
      }
    } catch (e) {
      print('[REGISTER ERROR] $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    firstName.value = '';
    lastName.value = '';
    email.value = '';
    birthDate.value = '';
    phoneNumber.value = '';
    password.value = '';
    confirmPassword.value = '';
    selectedGender.value = '';
    phoneSuffix.value = '994';
    agreeToTerms.value = false;
    _checkFormValidity();
  }
}
