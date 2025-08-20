import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notifications_controller.dart';
import 'notification_tab_item.dart';

class NotificationTabs extends GetView<NotificationsController> {
  const NotificationTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.notifications.isEmpty
        ? const SizedBox.shrink()
        : Container(
            height: 45,
            margin: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => NotificationTabItem(
                        text: controller.tabs[0],
                        count: controller.counts[0],
                        isSelected: controller.currentIndex.value == 0,
                        onTap: () => controller.changeTab(0),
                      )),
                  Obx(() => NotificationTabItem(
                        text: controller.tabs[1],
                        count: controller.counts[1],
                        isSelected: controller.currentIndex.value == 1,
                        onTap: () => controller.changeTab(1),
                      )),
                  Obx(() => NotificationTabItem(
                        text: controller.tabs[2],
                        count: controller.counts[2],
                        isSelected: controller.currentIndex.value == 2,
                        onTap: () => controller.changeTab(2),
                      )),
                ],
              ),
            ),
          ));
  }
}
