import 'package:get/get.dart';
import '../services/notifications_service.dart';
import '../utils/api_response_parser.dart';
import 'package:flutter/material.dart';
import 'home_controller.dart';

class NotificationsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final NotificationsService _notificationsService = NotificationsService();

  // TabController
  late TabController tabController;

  // Observable variables
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // Retry functionality
  final RxBool showRetryButton = false.obs;
  final RxString retryMessage = ''.obs;

  // Action loading state
  final RxBool isActionLoading = false.obs;

  // Tab management
  final List<String> tabs = ['Hamısı', 'Oxunmuş', 'Oxunmamış'];
  final RxInt currentIndex = 0.obs;

  // API'den gelen count değerleri
  final RxInt apiAllCount = 0.obs;
  final RxInt apiReadCount = 0.obs;
  final RxInt apiUnreadCount = 0.obs;

  // Computed counts for tabs
  List<String> get counts {
    return [
      apiAllCount.value.toString(),
      apiReadCount.value.toString(),
      apiUnreadCount.value.toString()
    ];
  }

  // Ayrı notification listeleri
  RxList<Map<String, dynamic>> get allNotifications => notifications;

  RxList<Map<String, dynamic>> get readNotifications {
    return notifications
        .where((notification) => notification['read'] == true)
        .toList()
        .obs;
  }

  RxList<Map<String, dynamic>> get unreadNotifications {
    return notifications
        .where((notification) =>
            notification['read'] == false || notification['read'] == null)
        .toList()
        .obs;
  }

  @override
  void onInit() {
    super.onInit();
    // TabController'ı başlat
    tabController = TabController(length: tabs.length, vsync: this);

    // Tab değişikliklerini dinle
    tabController.addListener(() {
      if (currentIndex.value != tabController.index) {
        currentIndex.value = tabController.index;
      }
    });

    // Controller başlatıldığında notifications'ları yükle
    getNotifications();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Get all notifications
  Future<void> getNotifications() async {
    try {
      isLoading.value = true;
      showRetryButton.value = false;
      retryMessage.value = '';

      final response = await _notificationsService.getNotifications();

      // API'den gelen count değerlerini al
      apiAllCount.value = response['all'] ?? 0;
      apiReadCount.value = response['read'] ?? 0;
      apiUnreadCount.value = response['unread'] ?? 0;

      if (response['notification'] != null) {
        final List<Map<String, dynamic>> notificationList =
            List<Map<String, dynamic>>.from(response['notification']);

        // API'den gelen status'u read field'ına çevir
        for (var notification in notificationList) {
          if (notification['status'] == 'read') {
            notification['read'] = true;
          } else {
            notification['read'] = false;
          }
        }

        notifications.value = notificationList;
      } else {
        notifications.value = [];
      }

      print(
          '[NOTIFICATIONS CONTROLLER] Loaded ${notifications.length} notifications');
    } on NotificationsException catch (e) {
      print('[NOTIFICATIONS CONTROLLER ERROR] ${e.message}');
      final errorMessage = ApiResponseParser.parseApiMessage(e.message);

      // Global retry dialog'u göster
      final homeController = Get.find<HomeController>();
      homeController.showGlobalRetryDialog(
        errorMessage,
        getNotifications,
      );
    } catch (e) {
      print('[NOTIFICATIONS CONTROLLER ERROR] $e');
      final errorMessage = ApiResponseParser.parseDioError(e);

      // Global retry dialog'u göster
      final homeController = Get.find<HomeController>();
      homeController.showGlobalRetryDialog(
        errorMessage,
        getNotifications,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Respond to invite

  /// Update notification status (read/unread)
  Future<bool> updateNotificationStatus({
    required String id,
    required bool status,
  }) async {
    try {
      isLoading.value = true;

      final response = await _notificationsService.updateNotificationStatus(
        notificationId: id,
        status: status ? 'read' : 'unread',
      );

      print(
          '[NOTIFICATIONS CONTROLLER] Notification status updated: ${status ? 'read' : 'unread'}');

      // Başarılı response sonrası notifications'ları yenile
      await getNotifications();

      return true;
    } on NotificationsException catch (e) {
      print('[NOTIFICATIONS CONTROLLER ERROR] ${e.message}');
      return false;
    } catch (e) {
      print('[NOTIFICATIONS CONTROLLER ERROR] $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle notification read status
  Future<void> toggleNotificationStatus(String id) async {
    try {
      // Mevcut notification'ı bul
      final notificationIndex = notifications.indexWhere((n) => n['id'] == id);

      if (notificationIndex == -1) {
        print('[NOTIFICATIONS CONTROLLER] Notification not found: $id');
        return;
      }

      // Eğer notification zaten read ise işlem yapma
      final currentStatus = notifications[notificationIndex]['read'] ?? false;
      if (currentStatus) {
        print(
            '[NOTIFICATIONS CONTROLLER] Notification already read, skipping toggle: $id');
        return;
      }

      await updateNotificationStatus(
        id: id,
        status: true,
      );

      print('[NOTIFICATIONS CONTROLLER] Notification marked as read: $id');
    } catch (e) {
      print(
          '[NOTIFICATIONS CONTROLLER ERROR] Toggle notification status failed: $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      // Hata durumunda global retry dialog'u göster
      final homeController = Get.find<HomeController>();
      homeController.showGlobalRetryDialog(
        errorMessage,
        () => toggleNotificationStatus(id),
      );
    }
  }

  /// Toggle notification read status with specific status
  Future<void> toggleNotificationReadStatus(String id, bool isRead) async {
    try {
      isActionLoading.value = true;

      await updateNotificationStatus(
        id: id,
        status: isRead,
      );

      print(
          '[NOTIFICATIONS CONTROLLER] Notification status toggled to ${isRead ? "read" : "unread"}: $id');
    } catch (e) {
      print(
          '[NOTIFICATIONS CONTROLLER ERROR] Toggle notification read status failed: $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      // Hata durumunda global retry dialog'u göster
      final homeController = Get.find<HomeController>();
      homeController.showGlobalRetryDialog(
        errorMessage,
        () => toggleNotificationReadStatus(id, isRead),
      );
    } finally {
      isActionLoading.value = false;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await getNotifications();
  }

  /// Clear retry state
  void clearRetryState() {
    showRetryButton.value = false;
    retryMessage.value = '';
  }

  /// Retry butonuna basıldığında çağrılır
  Future<void> retryNotifications() async {
    if (isLoading.value) return; // Çift tıklamayı önle

    showRetryButton.value = false;
    retryMessage.value = '';

    await getNotifications();
  }

  /// Hatanın retry edilebilir olup olmadığını kontrol et
  bool _isRetryableError(String errorMessage) {
    return errorMessage.contains('network_error') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('Bağlantı') ||
        errorMessage.contains('internet');
  }

  /// Hata mesajını çıkar
  String _extractErrorMessage(String errorMessage) {
    if (errorMessage.contains('network_error')) {
      return 'network_error_retry'.tr;
    } else if (errorMessage.contains('connection') ||
        errorMessage.contains('timeout')) {
      return 'network_error_retry'.tr;
    }

    return errorMessage;
  }

  /// Get unread notifications count
  int get unreadCount {
    return notifications
        .where((notification) =>
            notification['read'] == false || notification['read'] == null)
        .length;
  }

  /// Get unread notifications count as observable
  RxInt get unreadCountObservable {
    return unreadNotifications.length.obs;
  }

  /// Change tab
  void changeTab(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      tabController.animateTo(index);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      isLoading.value = true;

      // Tüm unread notifications'ları read yap
      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i]['read'] == false ||
            notifications[i]['read'] == null) {
          await updateNotificationStatus(
            id: notifications[i]['id'],
            status: true,
          );
        }
      }

      print('[NOTIFICATIONS CONTROLLER] All notifications marked as read');
    } catch (e) {
      print('[NOTIFICATIONS CONTROLLER ERROR] $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Accept invite
  Future<void> acceptInvite(String notificationId) async {
    try {
      isActionLoading.value = true; // Loading başlat

      await _notificationsService.inviteAction(
        notificationId: notificationId,
        action: 'accept',
      );

      print('[NOTIFICATIONS CONTROLLER] Invite accepted: $notificationId');

      // Başarılı response sonrası notifications'ları yenile
      await getNotifications();
    } catch (e) {
      print('[NOTIFICATIONS CONTROLLER ERROR] Accept invite failed: $e');
      // Hata durumunda global retry dialog'u göster
      final homeController = Get.find<HomeController>();
      homeController.showGlobalRetryDialog(
        'invite_response_failed'.tr,
        () => acceptInvite(notificationId),
      );
    } finally {
      isActionLoading.value = false; // Loading bitir
    }
  }

  /// Ignore invite
  Future<void> rejectInvite(String notificationId) async {
    try {
      isActionLoading.value = true; // Loading başlat

      await _notificationsService.inviteAction(
        notificationId: notificationId,
        action: 'ignore',
      );

      print('[NOTIFICATIONS CONTROLLER] Invite ignored: $notificationId');

      // Başarılı response sonrası notifications'ları yenile
      await getNotifications();
    } catch (e) {
      print('[NOTIFICATIONS CONTROLLER ERROR] Ignore invite failed: $e');
      // Hata durumunda global retry dialog'u göster
      final homeController = Get.find<HomeController>();
      homeController.showGlobalRetryDialog(
        'invite_response_failed'.tr,
        () => rejectInvite(notificationId),
      );
    } finally {
      isActionLoading.value = false; // Loading bitir
    }
  }
}
