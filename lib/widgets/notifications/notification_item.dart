import 'package:avankart_people/assets/image_assets.dart';

import '../../utils/app_theme.dart';
import '../../utils/url_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;
  final Function(String)? onAccept;
  final Function(String)? onReject;
  final Function(String, bool)? onToggleReadStatus; // Read/unread toggle için
  final bool isLoading; // Loading state için

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onToggleReadStatus,
    this.isLoading = false,
  });

  String _formatDate(dynamic date) {
    if (date == null) return '';

    try {
      if (date is String) {
        // ISO 8601 format'ındaki tarihi parse et
        final DateTime dateTime = DateTime.parse(date);

        // Cihazın lokal saatine çevir
        final DateTime localDateTime = dateTime.toLocal();

        // Şu anki zamanı al
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime yesterday = today.subtract(const Duration(days: 1));
        final DateTime notificationDate = DateTime(
            localDateTime.year, localDateTime.month, localDateTime.day);

        // Saat formatını hazırla
        final String timeFormat =
            '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';

        // Tarih kontrolü
        if (notificationDate == today) {
          // Bugün
          return '${'today'.tr} $timeFormat';
        } else if (notificationDate == yesterday) {
          // Dün
          return '${'yesterday'.tr} $timeFormat';
        } else {
          // Diğer günler
          final String dayFormat =
              '${localDateTime.day.toString().padLeft(2, '0')}/${localDateTime.month.toString().padLeft(2, '0')}/${localDateTime.year}';
          return '$dayFormat $timeFormat';
        }
      }
      return '';
    } catch (e) {
      print('[NOTIFICATION] Error formatting date: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isRead =
        notification['read'] == true || notification['status'] == "read";

    return InkWell(
      onTap: () {
        // Notification type'a göre farklı aksiyonlar
        _handleNotificationTap(context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
          color: isRead
              ? theme.colorScheme.secondary
              : theme.colorScheme.onPrimary,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      notification['title'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.hyperLinkColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (!isRead) const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showMenu(context),
                        child: Image.asset(
                          ImageAssets.dropdown,
                          height: 32,
                          width: 32,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(
                notification['text'] ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.unselectedWidgetColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Text(
                _formatDate(notification['date']),
                style: TextStyle(fontSize: 10, color: theme.splashColor),
              ),
            ),
            if (notification['type'] == 'accept_reject' ||
                notification['type'] == 'invation')
              _buildAcceptRejectActions(theme, context),
            if (notification['type'] == 'update')
              _buildUpdateActions(theme, context),
          ],
        ),
      ),
    );
  }

  /// Notification'a tıklandığında çalışacak fonksiyon
  void _handleNotificationTap(BuildContext context) {
    final String type = notification['type'] ?? '';

    switch (type) {
      case 'info':
      case 'notification':
        _showInfoAlert(context);
        break;
      case 'update':
        _showUpdateAlert(context);
        break;
      case 'invation':
        _showInvitationBottomSheet(context);
        break;
      default:
        _showInfoAlert(context);

        // Diğer type'lar için hiçbir şey yapma
        break;
    }
  }

  /// Info type notification için alert
  void _showInfoAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      ImageAssets.bellringing,
                      height: 32,
                      width: 32,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  notification['title'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  notification['text'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: AppTheme.primaryButtonStyle(),
                    child: Text(
                      'ok'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Update type notification için alert
  void _showUpdateAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      ImageAssets.bellringing,
                      height: 32,
                      width: 32,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  notification['title'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  notification['text'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // Store'a yönlendir
                      await UrlUtils.launchStore();
                    },
                    style: AppTheme.primaryButtonStyle(),
                    child: Text(
                      'update'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'later'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Invitation type notification için bottom sheet
  void _showInvitationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'restaurant_name'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'restaurant_invitation'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Accept button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onAccept != null) {
                      onAccept!(notification['id']);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'accept'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Reject button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onReject != null) {
                      onReject!(notification['id']);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'reject'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final bool isRead =
        notification['read'] == true || notification['status'] == "read";

    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + button.size.width - 150, // Sağ tarafa kaydır
        offset.dy, // Yukarı çıkar ama item'ın üstüne çıkmasın
        offset.dx + button.size.width,
        offset.dy + button.size.height,
      ),
      items: [
        PopupMenuItem<String>(
          value: isRead ? 'unread' : 'read',
          child: Row(
            children: [
              Text(
                isRead ? 'mark_as_unread'.tr : 'mark_as_read'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null && onToggleReadStatus != null) {
        onToggleReadStatus!(notification['id'], !isRead);
      }
    });
  }

  Widget _buildAcceptRejectActions(ThemeData theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (onAccept != null) {
                      onAccept!(notification['id']);
                    }
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 34),
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Qəbul et',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: isLoading
                ? null
                : () {
                    if (onReject != null) {
                      onReject!(notification['id']);
                    }
                  },
            style: TextButton.styleFrom(
              foregroundColor: theme.unselectedWidgetColor,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                : Text(
                    'Redd et',
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 13,
                      color: theme.unselectedWidgetColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateActions(ThemeData theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () async {
              // Store'a yönlendir
              await UrlUtils.launchStore();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 34),
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              'update'.tr,
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: theme.unselectedWidgetColor,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'dismiss'.tr,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 13,
                color: theme.unselectedWidgetColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
