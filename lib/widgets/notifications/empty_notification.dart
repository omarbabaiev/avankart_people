import 'package:avankart_people/assets/image_assets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyNotification extends StatelessWidget {
  const EmptyNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Get.isDarkMode
              ? Image.asset(ImageAssets.bellIcon, width: 80, height: 80)
              : Image.asset(ImageAssets.bellIconDark, width: 80, height: 80),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'notification_updates'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
        ],
      ),
    );
  }
}
