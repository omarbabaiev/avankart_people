import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';

class PaymentBottomSheet {
  static void show(BuildContext context) {
    final controller = Get.find<CardController>();
    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ödəniş edəcəyiniz kartı seçin",
                  style: TextStyle(
    fontFamily: 'Poppins',
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 20),
              Obx(() {
                return SizedBox(
                  child: Skeletonizer(
                    enableSwitchAnimation: true,
                    enabled: controller.cards.isEmpty,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: controller.cards.length,
                      itemBuilder: (context, index) {
                        final card = controller.cards[index];
                        final isSelected =
                            controller.selectedIndex.value == index;
                        return InkWell(
                            onTap: () => controller.selectedIndex.value = index,
                            child: PaymentCardTitle(
                              title: card['title'] as String,
                              balance: (card['balance'] as double)
                                  .toStringAsFixed(2),
                              icon: card['icon'] as String,
                              color: card['color'] as Color,
                              isSelected: isSelected,
                            ));
                      },
                    ),
                  ),
                );
              }),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.qrPayment);
                  },
                  style: AppTheme.primaryButtonStyle(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(
                    'next'.tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}

class PaymentCardTitle extends StatelessWidget {
  final String title;
  final String balance;
  final String icon;
  final Color color;
  final bool isSelected;

  const PaymentCardTitle({
    Key? key,
    required this.title,
    required this.balance,
    required this.icon,
    required this.color,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withOpacity(0.1)
            : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(50),
        border: isSelected
            ? Border.all(color: color, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 20,
                child: Image.asset(
                  icon,
                  width: 20,
                  height: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(context).unselectedWidgetColor),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Balans:",
                style: TextStyle(
    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).unselectedWidgetColor),
              ),
              SizedBox(width: 5),
              Text(
                balance,
                style: TextStyle(
    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              SizedBox(width: 5),
            ],
          )
        ],
      ),
    );
  }
}
