import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final Map<String, dynamic> paymentData;
  final String? errorMessage;

  const PaymentResultScreen({
    super.key,
    required this.isSuccess,
    required this.paymentData,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          CupertinoButton(
            onPressed: () {
              Get.toNamed(AppRoutes.support);
            },
            child: Row(
              children: [
                Image.asset(
                  ImageAssets.headset,
                  height: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 4),
                Text(
                  'support_button'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header - Support button

            // Success/Failure Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess
                    ? Color(0xFF10B981).withOpacity(0.1) // Light green
                    : Color(0xFFEF4444).withOpacity(0.1), // Light red
              ),
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess
                        ? Color(0xFF10B981) // Green
                        : Color(0xFFEF4444), // Red
                  ),
                  child: Icon(
                    isSuccess ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),

            SizedBox(height: 15),

            // Title
            Text(
              isSuccess ? 'payment_success'.tr : 'payment_failed'.tr,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground, // Dark gray
                fontFamily: 'Poppins',
              ),
            ),

            SizedBox(height: 8),

            // Subtitle
            Text(
              isSuccess
                  ? 'payment_success_description'.tr
                  : (errorMessage ?? 'payment_failed_description'.tr),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).unselectedWidgetColor, // Medium gray
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),

            // Payment Details Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB), // Very light gray
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFFE5E7EB), // Light border
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                      'amount'.tr, '${paymentData['amount']} ₼', true, context),
                  SizedBox(height: 12),
                  _buildStatusRow(),
                  SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(
                      'transaction_id'.tr,
                      paymentData['transaction_id'] ?? 'TRX-XXXXXXXXXXXXXX',
                      false,
                      context),
                  _buildDetailRow('card_type'.tr,
                      paymentData['card_type'] ?? 'Yemək', false, context),
                  _buildDetailRow(
                      'payment_date'.tr,
                      paymentData['payment_date'] ?? '31.12.2024, 13:22:16',
                      false,
                      context),
                  _buildDetailRow(
                      'receiving_institution'.tr,
                      paymentData['receiving_institution'] ?? 'Özsüt Restoran',
                      false,
                      context),
                  _buildDetailRow('payer_id'.tr,
                      paymentData['payer_id'] ?? 'RO-321', false, context),
                ],
              ),
            ),

            Spacer(),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Close screen and go back
                  Get.back();
                  Get.back();
                },
                style: AppTheme.primaryButtonStyle(),
                child: Text(
                  'completed'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Share Button
            Center(
              child: TextButton(
                onPressed: () {
                  // Share functionality
                },
                child: Text(
                  'share'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, // Purple
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, bool isAmount, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).unselectedWidgetColor, // Medium gray
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onBackground, // Dark gray
              fontWeight: isAmount ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'payment_status'.tr,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280), // Medium gray
              fontFamily: 'Poppins',
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSuccess
                  ? Color.fromARGB(24, 16, 185, 129) // Green
                  : Color.fromARGB(24, 239, 68, 68), // Red
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              isSuccess ? 'successful'.tr : 'failed'.tr,
              style: TextStyle(
                fontSize: 13,
                color: isSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
