import 'email_verification_screen.dart';
import '../../../utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    'forgot_password_title'.tr,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 23,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Alt başlık
                  Text(
                    'forgot_password_subtitle'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email alanı
                  Text(
                    'email'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.registerInputDecoration(
                        "enter_email".tr, context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'email_empty'.tr;
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'invalid_email'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // İrəli butonu
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        SnackbarUtils.showSnackbar('reset_code_sent'.tr);

                        Get.to(
                          () => EmailVerificationForNewUserScreen(
                            email: _emailController.text,
                          ),
                          transition: Transition.cupertino,
                        );
                      }
                    },
                    style: AppTheme.primaryButtonStyle(),
                    child: Text('next'.tr, style: AppTheme.buttonTextStyle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
