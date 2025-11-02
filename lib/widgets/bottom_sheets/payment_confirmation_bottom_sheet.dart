import 'dart:io';
import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/utils/app_theme.dart';

class PaymentConfirmationBottomSheet extends StatefulWidget {
  final Map<String, dynamic> paymentData;
  final Function() onConfirm;
  final Function() onCancel;

  const PaymentConfirmationBottomSheet({
    super.key,
    required this.paymentData,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<PaymentConfirmationBottomSheet> createState() =>
      _PaymentConfirmationBottomSheetState();
}

class _PaymentConfirmationBottomSheetState
    extends State<PaymentConfirmationBottomSheet> {
  final RxBool _isLoading = false.obs;

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
            const SizedBox(height: 10),

            // Transaction Icon
            Container(
              width: 55,
              height: 55,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onError,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                ImageAssets.arrowLeftRight,
                height: 5,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'confirm_payment'.tr,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'confirm_payment_description'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Payment Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                      'amount'.tr, '${widget.paymentData['amount']} ₼',
                      isAmount: true),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      'payment_status'.tr, 'awaiting_confirmation'.tr,
                      status: 'awaiting', isStatus: true),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      'transaction_id'.tr,
                      widget.paymentData['transaction_id'] ??
                          'TRX-XXXXXXXXXXXXXX'),
                  _buildDetailRow('card_type'.tr,
                      widget.paymentData['card_type'] ?? 'Yemək'),
                  _buildDetailRow(
                      'payment_date'.tr,
                      widget.paymentData['payment_date'] ??
                          '31.12.2024, 13:22:16'),
                  _buildDetailRow(
                      'receiving_institution'.tr,
                      widget.paymentData['receiving_institution'] ??
                          'Özsüt Restoran'),
                  _buildDetailRow('paying_company'.tr,
                      widget.paymentData['paying_company'] ?? 'Veysəloğlu MMC'),
                  _buildDetailRow('payer_id'.tr,
                      widget.paymentData['payer_id'] ?? 'RO-321'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading.value ? null : _onConfirmPressed,
                    style: AppTheme.primaryButtonStyle(),
                    child: _isLoading.value
                        ? _buildPlatformLoadingIndicator()
                        : Text(
                            'confirm'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                )),
            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: () {
                widget.onCancel();
                Get.back();
              },
              child: Text(
                'cancel'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
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

  Widget _buildDetailRow(String label, String value,
      {bool isAmount = false, bool isStatus = false, String? status}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).unselectedWidgetColor,
              fontFamily: 'Poppins',
            ),
          ),
          if (isStatus && status == 'awaiting')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: isAmount ? 14 : 13,
                fontWeight: isAmount ? FontWeight.w500 : FontWeight.w500,
                color: Theme.of(context).colorScheme.onBackground,
                fontFamily: 'Poppins',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlatformLoadingIndicator() {
    if (Platform.isIOS) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CupertinoActivityIndicator(
          radius: 10,
          color: Colors.white,
        ),
      );
    } else {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }

  void _onConfirmPressed() {
    _isLoading.value = true;

    // Ödeme onayını callback ile gönder
    widget.onConfirm();

    // Loading durumunu 2 saniye sonra kapat
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _isLoading.value = false;
        Get.back();
      }
    });
  }
}
