import '../../routes/app_routes.dart';
import '../support/terms_of_use_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../main/main_screen.dart';
import '../../controllers/login_controller.dart';
import '../../utils/secure_storage_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final LoginController controller;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final FlutterSecureStorage _storage = SecureStorageConfig.storage;

  @override
  void initState() {
    super.initState();
    // Controller'ı güvenli şekilde initialize et - eğer yoksa oluştur
    if (Get.isRegistered<LoginController>()) {
      controller = Get.find<LoginController>();
    } else {
      controller = Get.put(LoginController());
    }

    // Login ekranı açıldığında tüm storage'ı temizle (Flutter Secure Storage bug'ı için)
    _storage.deleteAll();
    print('[LOGIN SCREEN] All storage cleared');

    // Password field'ını da temizle (güvenlik için)
    controller.passwordController.clear();
  }

  @override
  void dispose() {
    // Controller dispose'ını GetX'e bırak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    '👋',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'welcome'.tr,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'login_subtitle'.tr,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'email'.tr,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    controller: controller.emailController,
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
                  const SizedBox(height: 20),
                  Text(
                    'password'.tr,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    controller: controller.passwordController,
                    obscureText: _obscurePassword,
                    decoration: AppTheme.registerInputDecoration(
                            "enter_password".tr, context)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          AppTheme.adaptiveVisibilityIcon(!_obscurePassword),
                          color: Theme.of(context).hintColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'password_empty'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Obx(() => AppTheme.adaptiveCheckbox(
                            value: controller.rememberMe.value,
                            onChanged: (value) {
                              controller.rememberMe.value = value ?? false;
                            },
                          )),
                      const SizedBox(width: 8),
                      Text(
                        'remember_me'.tr,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 15,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.login();
                                }
                              },
                        style: AppTheme.primaryButtonStyle(),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('login'.tr, style: AppTheme.buttonTextStyle),
                      )),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Get.to(() => const ForgotPasswordScreen()),
                      child: Text(
                        'forgot_password'.tr,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider(thickness: 0.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or'.tr,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(thickness: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      runSpacing: .01,
                      spacing: 4,
                      children: [
                        Text(
                          'no_account'.tr,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.register),
                          child: Text(
                            'create_account'.tr,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => TermsOfUseScreen());
                      },
                      child: Text(
                        'terms_and_conditions'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Theme.of(context).unselectedWidgetColor,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                    ),
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
