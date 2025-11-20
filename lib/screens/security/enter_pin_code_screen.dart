import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/pin_code_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:avankart_people/controllers/security_controller.dart';
import 'package:avankart_people/services/pin_service.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class EnterPinCodeScreen extends GetView<PinCodeController> {
  final bool allowBack;
  const EnterPinCodeScreen({super.key, this.allowBack = false});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    Get.put(PinCodeController());
    final securityController = Get.find<SecurityController>();

    // Args
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;
    final bool allowBackFromArgs = arguments?['allowBack'] ?? false;
    final bool verifyOnly = arguments?['verifyOnly'] ?? false;
    final bool forDisable = arguments?['forDisable'] ?? false;

    // PIN giriş modunu başlat
    controller.startEnterMode();
    // verifyOnly bilgisini controller tarafında da kullanılabilsin
    controller.setVerifyOnly(verifyOnly);
    // forDisable bilgisini controller tarafında da kullanılabilsin
    controller.setForDisable(forDisable);

    // Otomatik biometric authentication başlat (eğer aktifse)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoBiometricAuth(securityController, verifyOnly, forDisable);
    });

    return WillPopScope(
      onWillPop: () async =>
          (allowBack || allowBackFromArgs), // Geri gitme opsiyonel
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading:
              (allowBack || allowBackFromArgs), // Geri tuşu
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 100),

                // Face ID / FingerdebugPrint Icon

                const SizedBox(height: 20),

                // Title
                Text(
                  'enter_pin_code'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),

                // Forgot PIN button (show only if not from Settings)
                if (!verifyOnly)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextButton(
                      onPressed: () async {
                        // PIN reset akışı: forgot -> OTP -> change
                        controller.isLoading.value = true;
                        try {
                          final pinService = PinService();
                          final ok = await pinService.forgotPin();
                          if (ok) {
                            Get.toNamed(AppRoutes.otp, arguments: {
                              'isPinReset': true,
                            });
                          }
                        } finally {
                          controller.isLoading.value = false;
                        }
                      },
                      child: Text(
                        'forgot_password'
                            .tr, // Çeviri: Şifrəmi unutdum / Forgot password
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),

                // PIN dots
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => AnimatedContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: index < controller.pin.value.length
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 5,
                            ),
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .unselectedWidgetColor
                                .withOpacity(0.2),
                          ),
                          duration: Duration(milliseconds: 300),
                        ),
                      ),
                    )
                        .animate(target: controller.shouldShake.value ? 1 : 0)
                        .shake(duration: Duration(milliseconds: 500), hz: 4)),
                const SizedBox(height: 60),

                // Number pad
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Row 1: 1, 2, 3
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNumberButton('1', context),
                            _buildNumberButton('2', context),
                            _buildNumberButton('3', context),
                          ],
                        ),
                        // Row 2: 4, 5, 6
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNumberButton('4', context),
                            _buildNumberButton('5', context),
                            _buildNumberButton('6', context),
                          ],
                        ),
                        // Row 3: 7, 8, 9
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNumberButton('7', context),
                            _buildNumberButton('8', context),
                            _buildNumberButton('9', context),
                          ],
                        ),
                        // Row 4: empty, 0, backspace
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Empty space
                            SizedBox(
                              width: 100,
                            ),

                            _buildNumberButton('0', context),
                            _buildBackspaceButton(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Alt kısım: Face ID / Parmak izi seçimi (PIN enable + biometrik enable ise)
                Obx(() {
                  final security = Get.find<SecurityController>();
                  if (!security.isBiometricAvailable.value ||
                      !security.isBiometricEnabled.value) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 50.0, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (Platform.isIOS)
                          _authOption(
                            context,
                            icon: ImageAssets.faceId,
                            label: 'face_id'.tr,
                            onTap: () async {
                              debugPrint(
                                  '[EnterPinCodeScreen] 🔐 Manual Face ID authentication started');
                              final securityController =
                                  Get.find<SecurityController>();
                              // Direkt biometric authentication yap (PIN ekranını tekrar açma)
                              final ok = await securityController
                                  .authenticateWithBiometric();
                              if (ok) {
                                debugPrint(
                                    '[EnterPinCodeScreen] ✅ Manual Face ID successful');
                                // Session flag'i set et
                                securityController.isAuthenticated.value = true;
                                Get.offAllNamed('/main');
                              } else {
                                debugPrint(
                                    '[EnterPinCodeScreen] ❌ Manual Face ID failed');
                              }
                            },
                          ),
                        if (Platform.isAndroid)
                          _authOption(
                            context,
                            icon: ImageAssets.fingerdebugPrint,
                            label: 'finger_debugPrint'.tr,
                            onTap: () async {
                              debugPrint(
                                  '[EnterPinCodeScreen] 🔐 Manual FingerdebugPrint authentication started');
                              final securityController =
                                  Get.find<SecurityController>();
                              // Direkt biometric authentication yap (PIN ekranını tekrar açma)
                              final ok = await securityController
                                  .authenticateWithBiometric();
                              if (ok) {
                                debugPrint(
                                    '[EnterPinCodeScreen] ✅ Manual FingerdebugPrint successful');
                                // Session flag'i set et
                                securityController.isAuthenticated.value = true;
                                Get.offAllNamed('/main');
                              } else {
                                debugPrint(
                                    '[EnterPinCodeScreen] ❌ Manual FingerdebugPrint failed');
                              }
                            },
                          ),
                      ],
                    ),
                  );
                }),

                // Home indicator
              ],
            ),
            // Overlay loading
            Obx(() {
              if (!controller.isLoading.value) return const SizedBox.shrink();
              return Container(
                color: Colors.black.withOpacity(0.25),
                child: Center(
                  child: Platform.isIOS
                      ? const CupertinoActivityIndicator(radius: 14)
                      : const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number, BuildContext context) {
    return InkWell(
      onTap: () => controller.addDigit(number),
      borderRadius: BorderRadius.circular(200),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(BuildContext context) {
    return InkWell(
      onTap: () => controller.removeLastDigit(),
      borderRadius: BorderRadius.circular(200),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 20,
              // ignore: deprecated_member_use
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _authOption(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 20,
            height: 20,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  /// Otomatik biometric authentication başlat
  Future<void> _startAutoBiometricAuth(SecurityController securityController,
      bool verifyOnly, bool forDisable) async {
    try {
      // Biometric aktif ve mevcut mu kontrol et
      if (!securityController.isBiometricEnabled.value ||
          !securityController.isBiometricAvailable.value) {
        debugPrint(
            '[EnterPinCodeScreen] Biometric not available or not enabled');
        return;
      }

      debugPrint('\n╔═══════════════════════════════════════════════════╗');
      debugPrint('║ [EnterPinCodeScreen] 🔐 Starting Auto Biometric   ║');
      debugPrint('╚═══════════════════════════════════════════════════╝');
      debugPrint(
          '[EnterPinCodeScreen] 📱 Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      debugPrint('[EnterPinCodeScreen] 🔍 Biometric Status:');
      debugPrint(
          '[EnterPinCodeScreen]   - isBiometricEnabled: ${securityController.isBiometricEnabled.value}');
      debugPrint(
          '[EnterPinCodeScreen]   - isBiometricAvailable: ${securityController.isBiometricAvailable.value}');

      // Kısa bir gecikme ekle (UI render olsun)
      await Future.delayed(Duration(milliseconds: 500));

      // Direkt biometric authentication yap (PIN ekranını tekrar açma)
      final bool didAuthenticate =
          await securityController.authenticateWithBiometric();

      if (didAuthenticate) {
        debugPrint(
            '[EnterPinCodeScreen] ✅ Biometric authentication successful');

        // Session flag'i set et
        securityController.isAuthenticated.value = true;

        // Eğer verifyOnly ve forDisable true ise, geri dön (disabled işlemi için)
        if (verifyOnly && forDisable) {
          debugPrint(
              '[EnterPinCodeScreen] 🔙 Returning to previous screen for disable operation');
          Get.back(result: true);
          return;
        }

        // Eğer verifyOnly true ama forDisable false ise (enable işlemi için)
        if (verifyOnly && !forDisable) {
          debugPrint(
              '[EnterPinCodeScreen] 🔙 Returning to previous screen for enable operation');
          Get.back(result: true);
          return;
        }

        debugPrint('[EnterPinCodeScreen] 🚀 Navigating to main screen');
        // Başarılı authentication sonrası ana ekrana git
        Get.offAllNamed('/main');
      } else {
        debugPrint(
            '[EnterPinCodeScreen] ❌ Biometric authentication failed or cancelled');
        debugPrint('[EnterPinCodeScreen] 📱 User can now use PIN code');
      }

      debugPrint('╔═══════════════════════════════════════════════════╗');
      debugPrint('║ [EnterPinCodeScreen] ✅ Auto Biometric Complete   ║');
      debugPrint('╚═══════════════════════════════════════════════════╝\n');
    } catch (e) {
      debugPrint('┌─────────────────────────────────────────────────┐');
      debugPrint('│ [EnterPinCodeScreen] ❌ Auto Biometric Error    │');
      debugPrint('└─────────────────────────────────────────────────┘');
      debugPrint('[EnterPinCodeScreen] 🚫 Error Details:');
      debugPrint('[EnterPinCodeScreen]   - Type: ${e.runtimeType}');
      debugPrint('[EnterPinCodeScreen]   - Message: $e');
      debugPrint('[EnterPinCodeScreen] 📱 User can use PIN code as fallback');
    }
  }
}
