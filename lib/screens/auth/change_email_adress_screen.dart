import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/widgets/bottom_sheets/verification_bottom_sheet.dart';
import 'package:avankart_people/controllers/profile_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChangeEmailAdressScreen extends StatefulWidget {
  const ChangeEmailAdressScreen({super.key});

  @override
  State<ChangeEmailAdressScreen> createState() =>
      _ChangeEmailAdressScreenState();
}

class _ChangeEmailAdressScreenState extends State<ChangeEmailAdressScreen> {
  final ProfileController _controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    // İlk yüklemede e-posta validasyonunu yap
    validateEmail(_controller.newEmailController.text);
  }

  @override
  void dispose() {
    _controller.newEmailController.clear();
    super.dispose();
  }

  void validateEmail(String value) {
    if (value.isEmpty) {
      _controller.newEmailError.value = 'fill_all_fields'.tr;
    } else if (!GetUtils.isEmail(value)) {
      _controller.newEmailError.value = 'invalid_email'.tr;
    } else if (value == _controller.profile.value?.email) {
      _controller.newEmailError.value = 'same_email'.tr;
    } else {
      _controller.newEmailError.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'change_email_address'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: GetBuilder<ProfileController>(
        init: ProfileController()..getProfile(),
        builder: (controller) {
          return Skeletonizer(
              enabled: controller.isLoading.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'email_address'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(() => TextFormField(
                                controller: TextEditingController(
                                  text: controller.profile.value?.email ?? '',
                                ),
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: 'enter_email_address'.tr,
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .unselectedWidgetColor
                                        .withOpacity(.5),
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  errorText: controller.currentEmailError.value,
                                  errorStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              )),
                          const SizedBox(height: 30),
                          Text(
                            'new_email_address'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(() => TextFormField(
                                controller: controller.newEmailController,
                                onChanged: validateEmail,
                                decoration: InputDecoration(
                                  hintText: 'enter_new_email_address'.tr,
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .unselectedWidgetColor
                                        .withOpacity(.5),
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  errorText: controller.newEmailError.value,
                                  errorStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              )),
                          const SizedBox(height: 50),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: () async {
                                  // Validation kontrolü
                                  if (controller
                                          .newEmailController.text.isEmpty ||
                                      controller.newEmailError.value != null) {
                                    return; // Hata varsa request atma
                                  }

                                  final success =
                                      await controller.requestEmailChange();
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
                                        'confirm_change'.tr,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )),
                ],
              ));
        },
      ),
    );
  }

  void _showVerificationSheet(
      BuildContext context, ProfileController controller) {
    VerificationBottomSheet.show(
      context,
      title: 'otp'.tr,
      subtitle:
          '${controller.profile.value?.email} email adresinə göndərilən 6 rəqəmli şifrəni daxil edin',
      showTimer: true,
      onVerify: (otp) async {
        final success = await controller.submitEmailChangeOTP(otp);
        if (success) {
          await Future.delayed(const Duration(
              milliseconds:
                  100)); // Snackbar'ın gösterilmesi için kısa bir bekleme
          Get.close(
              2); // Hem verification sheet'i hem de email değiştirme ekranını kapat
        }
      },
      onResend: () async {
        await controller.requestEmailChange();
      },
    );
  }
}
