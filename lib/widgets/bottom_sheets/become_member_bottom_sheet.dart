import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/home_controller.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BecomeMemberBottomSheet {
  static void show(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final String userId = homeController.user?.peopleId ?? 'AP-XXXXXXXXXX';

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: Get.height * 0.6,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Center(child: context.buildBottomSheetHandle()),
              SizedBox(height: 20),

              // User ID Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "ID ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        userId,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: userId));
                      ToastUtils.showSuccessToast('id_copied'.tr);
                    },
                    child: Image.asset(
                      ImageAssets.copySimple,
                      width: 24,
                      height: 24,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Steps
              _buildStep(
                color: AppTheme.surfaceColor,
                iconColor: AppTheme.black,
                context,
                stepNumber: 1,
                icon: ImageAssets.passwordCopy,
                title: 'Yuxarıda qeyd olunan istifadəçi ID-sini kopyala'.tr,
              ),
              SizedBox(height: 5),
              Column(
                children: List.generate(
                  7,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Container(
                            height: 7,
                            width: 1.5,
                            color: AppTheme.hintAccent,
                          ),
                          SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),

              _buildStep(
                color: AppTheme.hyperLinkColor,
                iconColor: AppTheme.white,
                context,
                stepNumber: 2,
                icon: ImageAssets.pepIcon,
                title:
                    'Kopyaladığınız ID nömrənizi çalışdığınız şirkətə göndərin'
                        .tr,
              ),
              SizedBox(height: 7),
              Column(
                children: List.generate(
                  7,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Container(
                            height: 7,
                            width: 1.5,
                            color: AppTheme.hintAccent,
                          ),
                          SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              _buildStep(
                color: AppTheme.successColor,
                iconColor: AppTheme.white,
                context,
                stepNumber: 3,
                icon: ImageAssets.pepIcon,
                title:
                    'Səlahiyyətli şəxs sizi şirkətə əlavə etdikdən sonra xidmətlərimizdən tam yararlanın'
                        .tr,
              ),

              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildStep(
    BuildContext context, {
    required int stepNumber,
    required String icon,
    required String title,
    required Color color,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Step Icon
        Container(
          width: 40,
          height: 40,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(
            icon,
            color: iconColor,
            width: 20,
            height: 20,
          ),
        ),

        SizedBox(width: 16),

        // Step Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onBackground,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
