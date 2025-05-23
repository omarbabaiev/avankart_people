import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BenefitsController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController rotationController;
  late TabController tabController;

  final RxInt selectedTabIndex = 0.obs;
  final RxBool isDialogVisible = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Rotation animation controller
    rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Tab controller
    tabController = TabController(
      length: 5,
      vsync: this,
    );

    // Tab değişikliklerini dinle
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });
  }

  @override
  void onClose() {
    rotationController.dispose();
    tabController.dispose();
    super.onClose();
  }

  // Dialog gösterme fonksiyonu
  void showBenefitDialog(BuildContext context, int index) {
    isDialogVisible.value = true;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: AppTheme.primaryTextColor,
        child: Container(
          height: 219,
          width: 250,
          decoration: BoxDecoration(
            color: AppTheme.primaryTextColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Image.asset("assets/images/Silver.png", height: 60),
                    SizedBox(height: 16),
                    Text(
                      "Ən çox yemək yeyən",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "10/10 dəfə yemək ye",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withOpacity(0.1)),
              TextButton(
                onPressed: () {
                  isDialogVisible.value = false;
                  Get.back();
                },
                child: Text(
                  "Mükafatı al",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
