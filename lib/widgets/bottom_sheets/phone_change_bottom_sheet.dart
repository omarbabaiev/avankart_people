import 'package:avankart_people/assets/image_assets.dart';

import '../../utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';
import '../../utils/masked_text_formatter.dart';
import '../../controllers/profile_controller.dart';
import 'country_picker_bottom_sheet.dart';
import 'verification_bottom_sheet.dart';

class PhoneChangeBottomSheet {
  static void show(BuildContext context, Country selectedCountry,
      Function(Country) onCountryChanged) {
    final phoneController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final RxString errorMessage = ''.obs;

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
                const SizedBox(height: 20),
                context.buildBottomSheetHandle(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Text(
                          'phone_number_change'.tr,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            MaskedTextInputFormatter(
                              mask: 'xx xxx xx xx',
                              separator: ' ',
                            ),
                          ],
                          onChanged: (value) {
                            // Error mesajını temizle
                            if (errorMessage.value.isNotEmpty) {
                              errorMessage.value = '';
                            }
                          },
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              fontFamily: "Poppins",
                              color: Theme.of(context).hintColor,
                              fontSize: 15,
                            ),
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            errorStyle: TextStyle(
                              fontFamily: "Poppins",
                              color: Theme.of(context).colorScheme.error,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).shadowColor,
                                width: 1,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1,
                              ),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                                width: 1,
                              ),
                            ),
                            hintText: 'XX XXX XX XX',
                            prefixIcon: InkWell(
                              onTap: () => CountryPickerBottomSheet.show(
                                  context, selectedCountry, onCountryChanged),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "+${selectedCountry.phoneCode}",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Image.asset(
                                      ImageAssets.careddown,
                                      height: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'phone_number_empty'.tr;
                            }
                            String cleanedValue = value.replaceAll(' ', '');
                            if (cleanedValue.length < 9) {
                              return 'phone_number_incomplete'.tr;
                            }
                            if (cleanedValue.length > 9) {
                              return 'phone_number_too_long'.tr;
                            }
                            // Sadece rakam kontrolü
                            if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
                              return 'phone_number_invalid'.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
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
                                              String fullPhone =
                                                  selectedCountry.phoneCode +
                                                      phoneController.text
                                                          .replaceAll(' ', '');

                                              Get.back();

                                              final success = await controller
                                                  .sendUpdateOTP(
                                                'phone',
                                                fullPhone,
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
                                            'change'.tr,
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ));
                          },
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 20),
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
          title: 'otp'.tr,
          subtitle:
              '${controller.profile.value?.email} email adresinə göndərilən 6 rəqəmli şifrəni daxil edin',
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
      title: 'otp'.tr,
      subtitle:
          '${controller.profile.value?.email} email adresinə göndərilən 6 rəqəmli şifrəni daxil edin',
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
