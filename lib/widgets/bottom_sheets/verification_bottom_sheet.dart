import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_utils.dart';
import '../../utils/bottom_sheet_extension.dart';
import '../../utils/snackbar_utils.dart';
import '../../controllers/profile_controller.dart';

class VerificationBottomSheet {
  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Future<bool> Function(String) onVerify,
    String? buttonText,
    bool showTimer = false,
    VoidCallback? onResend,
    String? successMessage,
    bool shouldLogoutOnSuccess = false,
  }) {
    final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
    final List<TextEditingController> textControllers =
        List.generate(6, (index) => TextEditingController());
    final TextEditingController otpController = TextEditingController();

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isCodeComplete = _checkCodeComplete(textControllers);

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    context.buildBottomSheetHandle(),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                        color: Theme.of(context).unselectedWidgetColor,
                      ),
                    ),
                    if (showTimer) ...[
                      const SizedBox(height: 16),
                      GetBuilder<ProfileController>(
                        builder: (controller) {
                          return Obx(() => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  controller.formattedOtpTime,
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              ));
                        },
                      ),
                      const SizedBox(height: 8),
                      if (onResend != null)
                        GetBuilder<ProfileController>(
                          builder: (controller) {
                            return Obx(() => TextButton(
                                  onPressed:
                                      controller.otpRemainingTime.value <= 180
                                          ? onResend
                                          : null,
                                  child: Text(
                                    'resend'.tr,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          controller.otpRemainingTime.value <= 180
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.grey[400],
                                    ),
                                  ),
                                ));
                          },
                        ),
                    ],
                    const SizedBox(height: 24),
                    // OTP Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          6,
                          (index) => _buildOtpField(
                                context,
                                index,
                                focusNodes,
                                textControllers,
                                otpController,
                                onVerify,
                                setState,
                              )),
                    ),
                    const SizedBox(height: 32),
                    GetBuilder<ProfileController>(
                      builder: (controller) {
                        return Obx(() => SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (controller.isOtpVerifying.value ||
                                        !isCodeComplete)
                                    ? null
                                    : () async {
                                        // Önce işlemi yap, başarılı olursa bottom sheet'i kapat
                                        final success = await onVerify(otpController.text);
                                        if (success) {
                                          // Önce bottom sheet'i kapat
                                          if (bottomSheetContext.mounted) {
                                            Navigator.of(bottomSheetContext).pop();
                                          } else {
                                        Get.back();
                                          }
                                          
                                          // Bottom sheet kapandıktan sonra işlemleri yap
                                          await Future.delayed(const Duration(milliseconds: 300));
                                          
                                          // Şifre değişikliği için logout yapılacaksa önce snackbar göster, sonra logout
                                          if (shouldLogoutOnSuccess) {
                                            // Önce snackbar göster
                                            SnackbarUtils.showSuccessSnackbar('profile_updated_redirect_login'.tr);
                                            // Snackbar'ın görünmesi için kısa bir bekleme
                                            await Future.delayed(const Duration(milliseconds: 1500));
                                            // Sonra logout işlemi (login ekranına yönlendirecek)
                                            await AuthUtils.logout();
                                          } else {
                                            // Diğer işlemler için snackbar göster
                                            if (successMessage != null && successMessage.isNotEmpty) {
                                              SnackbarUtils.showSuccessSnackbar(successMessage);
                                            }
                                          }
                                        }
                                      },
                                style: AppTheme.primaryButtonStyle().copyWith(
                                  backgroundColor: WidgetStateProperty.all(
                                    (controller.isOtpVerifying.value ||
                                            !isCodeComplete)
                                        ? Colors.grey[400]
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                child: controller.isOtpVerifying.value
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Platform.isIOS
                                            ? CupertinoActivityIndicator(
                                                radius: 10,
                                                color: Colors.white,
                                              )
                                            : CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        buttonText ?? 'verify'.tr,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ));
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildOtpField(
    BuildContext context,
    int index,
    List<FocusNode> focusNodes,
    List<TextEditingController> textControllers,
    TextEditingController otpController,
    Function(String) onVerify,
    StateSetter setState,
  ) {
    return Container(
      width: 45,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: focusNodes[index].hasFocus
                ? Theme.of(context).dividerColor
                : Theme.of(context).shadowColor,
            width: focusNodes[index].hasFocus ? 2 : 1,
          ),
        ),
      ),
      child: TextField(
        style: TextStyle(
          fontFamily: "Poppins",
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        controller: textControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          // Paste durumu kontrolü (6 haneli kod yapıştırıldıysa)
          if (value.length == 6 && index == 0) {
            _fillAllFields(
                value, textControllers, focusNodes, otpController, context);
            setState(() {}); // UI'ı güncelle
            return;
          }

          // Sadece son karakteri al (paste durumu için)
          if (value.length > 1) {
            value = value.substring(value.length - 1);
            textControllers[index].text = value;
            textControllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: value.length),
            );
          }

          _onCodeChanged(value, index, textControllers, focusNodes,
              otpController, context);
          setState(() {}); // UI'ı güncelle
        },
        onTap: () {
          // Android'de cursor position fix
          textControllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: textControllers[index].text.length),
          );
        },
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          counter: const SizedBox.shrink(),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).shadowColor,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  static void _onCodeChanged(
    String value,
    int index,
    List<TextEditingController> textControllers,
    List<FocusNode> focusNodes,
    TextEditingController otpController,
    BuildContext context,
  ) {
    // Eğer bir karakter girildi ve son field değilse, sonrakine geç
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    // Son field'a girildi və kod tamamlandıysa, klavyeyi kapat
    if (value.length == 1 && index == 5) {
      // OTP kodu tamamlandı - klavyeyi kapat
      Future.delayed(Duration(milliseconds: 300), () {
        FocusScope.of(context).unfocus();
        for (var focusNode in focusNodes) {
          focusNode.unfocus();
        }
      });
    }
    // Eğer karakter silindi ve ilk field değilse, öncekine geç
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Tüm field'lardan OTP kodunu oluştur
    _updateOtpFromFields(textControllers, otpController);
  }

  static void _updateOtpFromFields(
    List<TextEditingController> textControllers,
    TextEditingController otpController,
  ) {
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += textControllers[i].text;
    }
    otpController.text = otp;
  }

  static void _fillAllFields(
    String code,
    List<TextEditingController> textControllers,
    List<FocusNode> focusNodes,
    TextEditingController otpController,
    BuildContext context,
  ) {
    // 6 haneli kodu tüm field'lara dağıt
    for (int i = 0; i < 6 && i < code.length; i++) {
      textControllers[i].text = code[i];
    }
    // Son field'a focus ver
    if (code.length == 6) {
      focusNodes[5].requestFocus();
      // OTP kodu tamamlandı - klavyeyi kapat
      Future.delayed(Duration(milliseconds: 300), () {
        FocusScope.of(context).unfocus();
        for (var focusNode in focusNodes) {
          focusNode.unfocus();
        }
      });
    }
    _updateOtpFromFields(textControllers, otpController);
  }

  static bool _checkCodeComplete(List<TextEditingController> textControllers) {
    String fullCode = '';
    for (int i = 0; i < 6; i++) {
      fullCode += textControllers[i].text;
    }
    return fullCode.length == 6;
  }
}
