import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/notifications_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/widgets/notifications/empty_notification.dart';
import 'package:avankart_people/widgets/notifications/notification_item.dart';
import 'package:avankart_people/widgets/notifications/notification_tabs.dart';
import 'package:avankart_people/widgets/notifications/skeletonizer_notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // NotificationsController'ı başlat ve notifications'ları çek
    final notificationsController = Get.put(NotificationsController());

    // Sayfa açılınca notifications'ları yenile (sadece data yoksa)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notificationsController.notifications.isEmpty) {
        notificationsController.getNotifications();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'notifications'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          // IconButton.filledTonal(
          //   icon: Image.asset(
          //     ImageAssets.trophy,
          //     width: 24,
          //     height: 24,
          //     color: Theme.of(context).colorScheme.onBackground,
          //   ),
          //   onPressed: () {
          //     Get.toNamed(AppRoutes.benefits);
          //   },
          //   style: IconButton.styleFrom(
          //     backgroundColor: Theme.of(context).colorScheme.secondary,
          //     fixedSize: Size(44, 44),
          //   ),
          // ),
          // SizedBox(width: 4),
          IconButton.filledTonal(
            icon: Image.asset(
              ImageAssets.heartStraight,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.favorites);
            },
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              fixedSize: Size(44, 44),
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            const NotificationTabs(),
            const SizedBox(height: 12),
            Expanded(
              child: controller.notifications.isEmpty
                  ? const EmptyNotification()
                  : TabBarView(
                      controller: controller.tabController,
                      physics:
                          const ClampingScrollPhysics(), // Tab'lar arası geçiş için
                      children: [
                        // Hamısı tab
                        _buildNotificationList(controller.allNotifications),
                        // Oxunmuş tab
                        _buildNotificationList(controller.readNotifications),
                        // Oxunmamış tab
                        _buildNotificationList(controller.unreadNotifications),
                      ],
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNotificationList(RxList<Map<String, dynamic>> notifications) {
    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: Skeletonizer(
        enabled: controller.isLoading.value,
        enableSwitchAnimation: true,
        child: notifications.isEmpty && !controller.isLoading.value
            ? const EmptyNotification()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount:
                    controller.isLoading.value ? 5 : notifications.length,
                itemBuilder: (context, index) {
                  if (controller.isLoading.value) {
                    return const SkeletonizerNotificationItem();
                  } else {
                    final notification = notifications[index];
                    return NotificationItem(
                      notification: notification,
                      onTap: () {
                        // Toggle notification read status when tapped
                        controller.toggleNotificationStatus(notification['id']);
                      },
                      onToggleReadStatus: (notificationId, isRead) {
                        // Toggle notification read status
                        controller.toggleNotificationReadStatus(
                            notificationId, isRead);
                      },
                      onAccept: (notificationId) {
                        // Accept invite
                        controller.acceptInvite(notificationId);
                      },
                      onReject: (notificationId) {
                        // Reject invite
                        controller.rejectInvite(notificationId);
                      },
                      isLoading: controller.isActionLoading.value,
                    );
                  }
                },
              ),
      ),
    );
  }
}
