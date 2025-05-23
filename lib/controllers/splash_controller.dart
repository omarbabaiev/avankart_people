import 'package:avankart_people/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> slideAnimation;
  late Animation<double> slideLogoAnimation;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();

    controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    slideAnimation = Tween<double>(
      begin: -0.23,
      end: 1.15,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    slideLogoAnimation = Tween<double>(
      begin: -0.23,
      end: 1.15,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    controller.forward();
    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed(AppRoutes.intro);
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
