import 'package:avankart_people/assets/image_assets.dart';

import '../../utils/conts_texts.dart';
import '../../controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/retry_dialog_widget.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.put(SplashController());

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Center(
            child: Obx(() => Lottie.asset(
                  addRepaintBoundary: true,
                  frameRate: FrameRate.max,
                  ImageAssets.splashLottie,
                  width: size.width * 1.3,
                  fit: BoxFit.contain,
                  // Animasyon tamamlandıysa durdur
                  repeat: !controller.isAnimationCompleted.value,
                  animate: true,
                )),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Column(
              children: [
                Text(
                  '${'version'.tr} ${ConstTexts.version}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Color(0xC0FFFFFF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Merkezi retry overlay
          Obx(() => RetryDialogWidget(
                showDialog: controller.showRetryButton.value,
                customMessage: controller.retryMessage.value,
                isLoading: controller.isRetrying.value,
                onRetry: controller.retryAuth,
              )),
        ],
      ),
    );
  }
}
