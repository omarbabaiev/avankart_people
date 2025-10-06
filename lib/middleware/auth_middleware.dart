import 'package:avankart_people/controllers/security_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Güvenlik ekranları ve authentication gerektirmeyen sayfalar
    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.otp,
      AppRoutes.otpScreen,
      AppRoutes.forgotPassword,
      AppRoutes.newPassword,
      AppRoutes.terms,
      AppRoutes.intro,
      AppRoutes.notFound,
      AppRoutes.setPinCode,
      AppRoutes.enterPinCode,
    ];

    // Eğer route public ise direkt geç
    if (publicRoutes.contains(route)) {
      return null;
    }

    // Security controller'ı kontrol et
    if (Get.isRegistered<SecurityController>()) {
      final securityController = Get.find<SecurityController>();

      // PIN veya biyometrik authentication aktifse kontrol et
      if (securityController.isPinEnabled.value ||
          securityController.isBiometricEnabled.value) {
        // Eğer zaten authenticate olmuşsa geç
        if (securityController.isAuthenticated.value) {
          return null;
        }

        // Authentication gerekiyor, PIN giriş ekranına yönlendir
        return RouteSettings(name: AppRoutes.enterPinCode);
      }
    }

    return null;
  }
}
