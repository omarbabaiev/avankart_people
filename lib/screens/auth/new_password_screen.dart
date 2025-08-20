import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../../controllers/login_controller.dart';

class NewPasswordScreen extends GetView<LoginController> {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Arguments'ı al ve controller'ı initialize et
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      controller.initializeNewPassword(
        args['email'] ?? '',
        args['token'] ?? '',
      );
    }

    final formKey = GlobalKey<FormState>();
    final isFormValid = false.obs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            onChanged: () {
              // Form değiştiğinde validasyon kontrolü yap
              final newPassword = controller.newPasswordController.text;
              final confirmPassword = controller.confirmPasswordController.text;

              final isNewPasswordValid = newPassword.isNotEmpty &&
                  newPassword.length >= 8 &&
                  RegExp(r'[!@\-_$?]').hasMatch(newPassword);

              final isConfirmPasswordValid =
                  confirmPassword.isNotEmpty && confirmPassword == newPassword;

              isFormValid.value = isNewPasswordValid && isConfirmPasswordValid;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  'Yeni şifrə',
                  style: TextStyle(fontFamily: "Poppins", 
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),

                // Açıklama
                Text(
                  'Yeni şifrənizi təyin edin',
                  style: TextStyle(fontFamily: "Poppins", 
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
                const SizedBox(height: 40),

                // Yeni şifre
                _PasswordFieldWidget(
                  controller: controller.newPasswordController,
                  label: 'Yeni şifrə',
                  hint: 'Şifrənizi təyin edin',
                  onChanged: () {
                    // Form onChanged çağrısını tetikle
                    formKey.currentState?.validate();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifrə boş ola bilməz';
                    }
                    if (value.length < 8) {
                      return 'Şifrə ən azı 8 simvol olmalıdır';
                    }
                    if (!RegExp(r'[!@\-_$?]').hasMatch(value)) {
                      return 'Minimum 1 qeyri əlifba simvolu (!, @, -, _, \$, ?) olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Şifre təsdiqi
                _PasswordFieldWidget(
                  controller: controller.confirmPasswordController,
                  label: 'Şifrə təsdiqi',
                  hint: 'Şifrənizi təsdiqləyin',
                  onChanged: () {
                    // Form onChanged çağrısını tetikle
                    formKey.currentState?.validate();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifrə təsdiqi boş ola bilməz';
                    }
                    if (value != controller.newPasswordController.text) {
                      return 'Şifrələr uyğun gəlmir';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                // Şifre gereksinimleri
                Text(
                  'Minimum 8 simvol',
                  style: TextStyle(fontFamily: "Poppins", 
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Minimum 1 qeyri əlifba simvolu (!, @, -, _, \$, ?)',
                  style: TextStyle(fontFamily: "Poppins", 
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 40),

                // Təsdiqlə butonu
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : (isFormValid.value
                                ? () => controller.submitNewPassword()
                                : null),
                        style: AppTheme.primaryButtonStyle(),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Təsdiqlə',
                                style: TextStyle(fontFamily: "Poppins", 
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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

class _PasswordFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;

  const _PasswordFieldWidget({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.onChanged,
  });

  @override
  State<_PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<_PasswordFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontFamily: "Poppins", 
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!();
            }
          },
          style: TextStyle(fontFamily: "Poppins", 
            fontSize: 15,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          decoration: InputDecoration(
            fillColor: Colors.transparent,
            hintText: widget.hint,
            hintStyle: TextStyle(fontFamily: "Poppins", 
              fontSize: 15,
              color: Theme.of(context).hintColor,
            ),
            contentPadding: const EdgeInsets.only(left: 15),
            suffixIcon: IconButton(
              icon: Icon(
                AppTheme.adaptiveVisibilityIcon(!_obscureText),
                color: Theme.of(context).colorScheme.onBackground,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
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
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1),
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
