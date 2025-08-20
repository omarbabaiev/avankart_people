import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';
import '../../controllers/profile_controller.dart';
import 'verification_bottom_sheet.dart';

class BirthDateChangeBottomSheet {
  static void show(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: Get.height * 0.5,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Text(
                'birth_date_change'.tr,
                style: TextStyle(fontFamily: "Poppins", 
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 100,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime(2004, 1, 1),
                    maximumDate: DateTime.now(),
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Spacer(),
              GetBuilder<ProfileController>(
                builder: (controller) {
                  return Obx(() => SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isOtpSending.value
                              ? null
                              : () async {
                                  Get.back();

                                  String formattedDate =
                                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

                                  final success =
                                      await controller.sendUpdateOTP(
                                    'birth_date',
                                    formattedDate,
                                  );

                                  if (success) {
                                    _showVerificationSheet(context, controller);
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
                                  style: TextStyle(fontFamily: "Poppins", 
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
                  'Ləğv et',
                  style: TextStyle(fontFamily: "Poppins", 
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
            ],
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
          title: 'Doğum tarixi doğrulaması',
          subtitle:
              'Yeni doğum tarixinizi təsdiqləmək üçün göndərilən kodu daxil edin',
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
      title: 'Doğum tarixi doğrulaması',
      subtitle:
          'Yeni doğum tarixinizi təsdiqləmək üçün göndərilən kodu daxil edin',
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
