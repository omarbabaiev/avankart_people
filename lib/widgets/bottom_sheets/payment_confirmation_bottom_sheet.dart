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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Transaction Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_horiz,
                size: 30,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'confirm_payment'.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              'confirm_payment_description'.tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Payment Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          if (isStatus && status == 'awaiting')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: isAmount ? 16 : 14,
                fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
                color: isAmount ? AppTheme.black : Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
        ],
      ),
    );
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
