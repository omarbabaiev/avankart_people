import 'notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationList extends StatelessWidget {
  final String type;

  const NotificationList({super.key, this.type = 'all'});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'restaurant_invitation'.tr,
        'message': 'restaurant_invitation'.tr,
        'time': '25.11.2024, 09:41',
        'type': 'accept_reject',
        'isRead': false,
      },
      {
        'title': 'system_update'.tr,
        'message': 'system_update'.tr,
        'time': '25.11.2024, 09:41',
        'type': 'update',
        'isRead': true,
      },
      {
        'title': 'qr_code_created'.tr,
        'message': 'qr_code_created'.tr,
        'time': '25.11.2024, 09:41',
        'type': 'info',
        'isRead': false,
      },
      {
        'title': 'payment_successful'.tr,
        'message': 'payment_successful'.tr,
        'time': '25.11.2024, 09:41',
        'type': 'info',
        'isRead': true,
      },
      {
        'title': 'password_updated'.tr,
        'message': 'password_updated'.tr,
        'time': '25.11.2024, 09:41',
        'type': 'info',
        'isRead': false,
      },
    ];

    // Filtreleme işlemi
    final filteredNotifications = type == 'all'
        ? notifications
        : type == 'read'
            ? notifications.where((n) => n['isRead'] == true).toList()
            : notifications.where((n) => n['isRead'] == false).toList();

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return NotificationItem(notification: notification);
      },
    );
  }
}
