import 'package:avankart_people/assets/image_assets.dart';

import 'login_screen.dart';
import '../../utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import 'dart:async';
import '../../utils/bottom_sheet_extension.dart';
import '../../widgets/bottom_sheets/verification_bottom_sheet.dart';
import '../../controllers/profile_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _confirmationPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureConfirmationPassword = true;

  // OTP için controller ve focus node'ları
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _timer;
  final _remainingTimeNotifier = ValueNotifier<int>(299);

  @override
  void dispose() {
    _timer?.cancel();
    _remainingTimeNotifier.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _confirmationPasswordController.dispose();
    // OTP controller ve focus node'ları temizle
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _remainingTimeNotifier.value ~/ 60;
    int seconds = _remainingTimeNotifier.value % 60;
    return '$minutes : ${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingTimeNotifier.value = 299;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeNotifier.value > 0) {
        _remainingTimeNotifier.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await _profileController.sendPasswordChangeOTP(
        _currentPasswordController.text,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (success) {
        _showVerificationBottomSheet();
      }
    }
  }

  void _showVerificationBottomSheet() {
    VerificationBottomSheet.show(
      context,
      title: 'Şifre doğrulaması',
      subtitle:
          'Şifre değişikliğinizi təsdiqləmək üçün göndərilən kodu daxil edin',
      showTimer: true,
      onVerify: (otp) async {
        final success = await _profileController.verifyPasswordChangeOTP(otp);
        if (success) {
          Get.off(() => const LoginScreen());
        }
      },
      onResend: () async {
        await _profileController.resendOTP();
      },
    );
  }

  void _oldChangePassword() {
    if (_formKey.currentState!.validate()) {
      context.showPerformantBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    context.buildBottomSheetHandle(),
                    const SizedBox(height: 10),
                    Container(
                      width: 55,
                      height: 55,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        ImageAssets.envelope2,
                        height: 20,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'confirm_change'.tr,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'confirm_password_change'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).unselectedWidgetColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      obscureText: _obscureCurrentPassword,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        hintText: 'enter_confirm_password'.tr,
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).hintColor,
                        ),
                        contentPadding: const EdgeInsets.only(left: 15),
                        suffixIcon: IconButton(
                          icon: Icon(
                            AppTheme.adaptiveVisibilityIcon(
                              !_obscureCurrentPassword,
                            ),
                            color: Theme.of(context).colorScheme.onBackground,
                            size: 22,
                          ),
                          onPressed: () {
                            setModalState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).shadowColor,
                            width: 1,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          VerificationBottomSheet.show(
                            context,
                            title: 'otp'.tr,
                            subtitle:
                                '${'email_sent_to'.tr} omarbaba007@gmail.com\n${'enter_verification_code'.tr}',
                            onVerify: (code) {
                              // OTP doğrulama işlemi
                              if (code == "123456") {
                                // Örnek doğrulama
                                SnackbarUtils.showSuccessSnackbar(
                                    'Şifre başarıyla değiştirildi');
                                Get.off(() => LoginScreen());
                              } else {
                                SnackbarUtils.showErrorSnackbar(
                                    'Geçersiz doğrulama kodu');
                              }
                            },
                          );
                          // Şifre kontrolü
                          //   if (_confirmationPasswordController.text ==
                          //       _currentPasswordController.text) {
                          //     Get.back();
                          //     _showVerificationBottomSheet();
                          //   } else {
                          //     // Yanlış şifre mesajı
                          //     SnackbarUtils.showSnackbar(
                          //      'Daxil etdiyiniz şifrə doğru deyil'
                          //     );
                          //   }
                          // },
                        },
                        style: AppTheme.primaryButtonStyle(),
                        child: Text(
                          'Təsdiqlə',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Ləğv et',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  void _showSuccessScreen() {
    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              context.buildBottomSheetHandle(),
              const SizedBox(height: 30),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: AppTheme.successColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Uğurla dəyişdirildi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Şifrəniz uğurla dəyişdirildi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();

                    SnackbarUtils.showSuccessSnackbar(
                        'Şifrəniz uğurla dəyişdirildi');
                  },
                  style: AppTheme.primaryButtonStyle(),
                  child: const Text(
                    'Tamam',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required Function(bool) onVisibilityChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          decoration: InputDecoration(
            fillColor: Colors.transparent,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 15,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            contentPadding: const EdgeInsets.only(left: 15),
            suffixIcon: IconButton(
              icon: Icon(
                AppTheme.adaptiveVisibilityIcon(!obscureText),
                color: Theme.of(context).colorScheme.onBackground,
                size: 22,
              ),
              onPressed: () => onVisibilityChanged(!obscureText),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).shadowColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'password'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPasswordField(
                  label: 'current_password'.tr,
                  hint: 'enter_current_password'.tr,
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  onVisibilityChanged: (value) {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'current_password_empty'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildPasswordField(
                  label: 'new_password'.tr,
                  hint: 'enter_new_password'.tr,
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  onVisibilityChanged: (value) {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'password_empty'.tr;
                    }
                    if (value.length < 8) {
                      return 'password_min_length'.tr;
                    }
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'password_complexity'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildPasswordField(
                  label: 'confirm_password'.tr,
                  hint: 'enter_confirm_password'.tr,
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onVisibilityChanged: (value) {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'confirm_password_empty'.tr;
                    }
                    if (value != _newPasswordController.text) {
                      return 'passwords_dont_match'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'minimum_chars'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'minimum_special_char'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 32),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _profileController.isOtpSending.value
                            ? null
                            : _changePassword,
                        style: AppTheme.primaryButtonStyle(),
                        child: _profileController.isOtpSending.value
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'confirm_change'.tr,
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
