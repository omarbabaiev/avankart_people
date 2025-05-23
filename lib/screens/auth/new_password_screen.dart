import 'package:avankart_people/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_theme.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement password reset logic
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    var _w = MediaQuery.of(context).size.width;
    var _h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('enter_new_password'.tr, style: AppTheme.headingStyle),
                const SizedBox(height: 8),
                Text(
                  'reset_password_subtitle'.tr,
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 32),
                Text(
                  'new_password'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: AppTheme.inputDecoration(
                    'enter_new_password'.tr,
                    Get.isDarkMode,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        AppTheme.adaptiveVisibilityIcon(!_obscurePassword),
                        color: AppTheme.hintColor,
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
                Text(
                  'confirm_password'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: AppTheme.inputDecoration(
                    'enter_confirm_password'.tr,
                    Get.isDarkMode,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        AppTheme.adaptiveVisibilityIcon(
                          !_obscureConfirmPassword,
                        ),
                        color: AppTheme.hintColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'confirm_password_empty'.tr;
                    }
                    if (value != _passwordController.text) {
                      return 'passwords_dont_match'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'minimum_chars'.tr,
                  style: TextStyle(fontSize: 13, color: AppTheme.hintColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'minimum_special_char'.tr,
                  style: TextStyle(fontSize: 13, color: AppTheme.hintColor),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _resetPassword,
                  style: AppTheme.primaryButtonStyle(),
                  child: Text(
                    'reset_password_button'.tr,
                    style: AppTheme.buttonTextStyle,
                  ),
                ),
                SizedBox(height: _h / 4),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.terms);
                    },
                    child: Text(
                      'terms_and_conditions'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(158, 29, 34, 43),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
