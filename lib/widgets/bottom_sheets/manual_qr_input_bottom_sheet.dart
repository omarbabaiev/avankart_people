import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/utils/app_theme.dart';

class ManualQrInputBottomSheet extends StatefulWidget {
  final Function(String qrCode) onQrCodeEntered;

  const ManualQrInputBottomSheet({
    super.key,
    required this.onQrCodeEntered,
  });

  @override
  State<ManualQrInputBottomSheet> createState() =>
      _ManualQrInputBottomSheetState();
}

class _ManualQrInputBottomSheetState extends State<ManualQrInputBottomSheet> {
  final List<TextEditingController> _controllers =
      List.generate(16, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(16, (index) => FocusNode());
  final RxBool _isLoading = false.obs;
  final RxBool _isAllFieldsFilled = false.obs;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      // Bir sonraki alana geç
      if (index < 15) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Son alan dolduruldu, focus'u kaldır
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Geri tuşuna basıldı, önceki alana geç
      _focusNodes[index - 1].requestFocus();
    }

    // Tüm alanların dolu olup olmadığını kontrol et
    _checkAllFieldsFilled();
  }

  void _checkAllFieldsFilled() {
    final allFilled =
        _controllers.every((controller) => controller.text.isNotEmpty);
    _isAllFieldsFilled.value = allFilled;
  }

  void _onPaymentPressed() {
    print('[MANUAL QR INPUT] ===== PAYMENT PRESSED =====');

    // Tüm alanların dolu olup olmadığını kontrol et
    final qrCode = _controllers.map((controller) => controller.text).join();
    print('[MANUAL QR INPUT] QR Code: $qrCode');
    print('[MANUAL QR INPUT] QR Code Length: ${qrCode.length}');

    if (qrCode.length == 16) {
      print('[MANUAL QR INPUT] QR Code is valid, starting payment process...');
      _isLoading.value = true;

      // QR kodunu callback ile gönder
      print('[MANUAL QR INPUT] Calling onQrCodeEntered callback...');
      widget.onQrCodeEntered(qrCode);

      // Bottom sheet'i kapat
      print('[MANUAL QR INPUT] Closing bottom sheet...');
      Get.back();
    } else {
      print('[MANUAL QR INPUT] QR Code is incomplete, showing error...');
      SnackbarUtils.showErrorSnackbar(
        'qr_code_incomplete'.tr,
      );
    }

    print('[MANUAL QR INPUT] ===========================');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            context.buildBottomSheetHandle(),
            SizedBox(height: 10),

            // QR Code Icon
            Container(
              width: 60,
              height: 60,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                ImageAssets.barcode,
                width: 32,
                height: 32,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'qr_code'.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'qr_code_manual_instruction'.tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // QR Code Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(16, (index) {
                return Container(
                  width: 21,
                  height: 40,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      counterText: '',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .unselectedWidgetColor!
                                .withOpacity(0.5)),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).unselectedWidgetColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppTheme.primaryColor, width: 2),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _onDigitChanged(index, value),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Payment Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isLoading.value || !_isAllFieldsFilled.value)
                        ? null
                        : _onPaymentPressed,
                    style: AppTheme.primaryButtonStyle().copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Theme.of(context).unselectedWidgetColor!;
                          }
                          return AppTheme.primaryColor;
                        },
                      ),
                    ),
                    child: _isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'pay'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isAllFieldsFilled.value
                                  ? Colors.white
                                  : Theme.of(context).unselectedWidgetColor,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                )),
            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'cancel'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).unselectedWidgetColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
