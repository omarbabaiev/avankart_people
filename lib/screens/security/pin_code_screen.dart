import 'package:avankart_people/controllers/pin_code_controller.dart';
import 'package:avankart_people/controllers/security_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SetPinCodeScreen extends GetView<PinCodeController> {
  final bool allowBack;

  const SetPinCodeScreen({super.key, this.allowBack = false});

  @override
  Widget build(BuildContext context) {
    // Arguments'dan allowBack değerini al
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;
    final bool allowBackFromArgs = arguments?['allowBack'] ?? false;
    final bool finalAllowBack = allowBack || allowBackFromArgs;

    // Controller'ı başlat
    Get.put(PinCodeController());
    Get.find<SecurityController>();

    // PIN ayarlama modunu başlat
    controller.startSetupMode();

    return WillPopScope(
      onWillPop: () async =>
          finalAllowBack, // Settings'den geliyorsa geri gidebilsin
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading:
              finalAllowBack, // Settings'den geliyorsa geri tuşunu göster
          title: Text(
            'set_pin_code'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),

            // Title
            Text(
              'pin_code'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Obx(() => Text(
                  controller.isConfirmScreen.value
                      ? 'pin_code_repeat'.tr
                      : 'pin_code_enter'.tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 40),

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

            // Home indicator
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
}
