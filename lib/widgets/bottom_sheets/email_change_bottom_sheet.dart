import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';
import '../../controllers/profile_controller.dart';
import 'verification_bottom_sheet.dart';

class EmailChangeBottomSheet {
  static void show(BuildContext context) {
    final emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                context.buildBottomSheetHandle(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Text(
                          'E-poçt dəyişdir',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'E-poçt adresi daxil edin';
                            }
                            if (!GetUtils.isEmail(value.trim())) {
                              return 'Düzgün e-poçt adresi daxil edin';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.transparent,
                            hintText: 'Yeni e-poçt adresini daxil edin',
                            hintStyle: TextStyle(
                              fontFamily: "Poppins",
                              color: Theme.of(context).hintColor,
                              fontSize: 15,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GetBuilder<ProfileController>(
                          builder: (controller) {
                            return Obx(() => SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: controller.isOtpSending.value
                                        ? null
                                        : () async {
                                            if (formKey.currentState!
                                                .validate()) {
                                              Get.back();

                                              final success = await controller
                                                  .sendUpdateOTP(
                                                'email',
                                                emailController.text.trim(),
                                              );

                                              if (success) {
                                                _showVerificationSheet(
                                                    context, controller);
                                              }
                                            }
                                          },
                                    style: AppTheme.primaryButtonStyle(),
                                    child: controller.isOtpSending.value
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Dəyiş',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.white,
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
                            'Ləğv et',
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showVerificationSheet(
      BuildContext context, ProfileController controller) {
    // Context'in geçerli olup olmadığını kontrol et
    if (!context.mounted) {
      print('[VERIFICATION SHEET] Context is not mounted, using Get.context');
      // Eğer context geçerli değilse Get.context kullan
      final currentContext = Get.context;
      if (currentContext != null) {
        VerificationBottomSheet.show(
          currentContext,
          title: 'E-poçt doğrulaması',
          subtitle:
              'Yeni e-poçt adrəsinizi təsdiqləmək üçün göndərilən kodu daxil edin',
          showTimer: true,
          onVerify: (otp) async {
            await controller.verifyUpdateOTP(otp);
          },
          onResend: () async {
            await controller.resendOTP();
          },
        );
      } else {
        print('[VERIFICATION SHEET] Get.context is also null');
      }
      return;
    }

    // Context geçerliyse normal şekilde devam et
    VerificationBottomSheet.show(
      context,
      title: 'E-poçt doğrulaması',
      subtitle:
          'Yeni e-poçt adrəsinizi təsdiqləmək üçün göndərilən kodu daxil edin',
      showTimer: true,
      onVerify: (otp) async {
        await controller.verifyUpdateOTP(otp);
      },
      onResend: () async {
        await controller.resendOTP();
      },
    );
  }
}
