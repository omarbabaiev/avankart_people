import 'package:avankart_people/assets/image_assets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';

class NotFoundScreen extends StatefulWidget {
  const NotFoundScreen({super.key});

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageAssets.notFound,
              width: Get.width * 0.7,
              height: Get.width * 0.7,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              'page_not_found'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
