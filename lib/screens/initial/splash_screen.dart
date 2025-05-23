import '../../../controllers/splash_controller.dart';
import '../../assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = 49.0;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: controller.slideAnimation,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 12,
                          left:
                              (screenWidth / 2 - logoWidth / 2) +
                              (screenWidth *
                                  0.2 *
                                  controller.slideLogoAnimation.value) -
                              18,
                          child: Image.asset(ImageAssets.png_logo, height: 47),
                        ),
                        Positioned(
                          left:
                              -screenWidth *
                              (1 - controller.slideAnimation.value),
                          child: FadeTransition(
                            opacity: controller.fadeAnimation,
                            child: Image.asset(
                              ImageAssets.brendingLogo,
                              height: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              children: [
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Color(0xC0FFFFFF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
