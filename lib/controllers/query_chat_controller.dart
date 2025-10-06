import 'dart:async';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:avankart_people/models/message_model.dart';
import 'package:avankart_people/services/query_chat_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QueryChatController extends GetxController {
  final QueryChatService _chatService = QueryChatService();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString currentTicketId = ''.obs;
  final textController = TextEditingController().obs;
  final RxString messageText = ''.obs;

  Timer? _messageRefreshTimer;
  int _lastMessageCount = 0;

  @override
  void onInit() {
    super.onInit();
    // Ticket ID'yi argument'lardan al ama otomatik loadMessages çağırma
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      // Önce ticket detail'den gelen _id'yi kontrol et, yoksa string ticket_id kullan
      final String? ticketId = args['_id'] ?? args['id'];
      currentTicketId.value = ticketId ?? '';
      // loadMessages() otomatik çağrılmayacak, manuel olarak çağrılacak
    }
  }

  @override
  void onClose() {
    _stopMessageRefreshTimer();
    textController.value.dispose();
    super.onClose();
  }

  /// Mesajları yükle
  Future<void> loadMessages() async {
    if (currentTicketId.value.isEmpty) return;

    try {
      isLoading.value = true;
      final allMessages =
          await _chatService.getAllMessages(currentTicketId.value);
      messages.assignAll(allMessages);

      // İlk yüklemede mesaj sayısını kaydet ve timer'ı başlat
      if (_lastMessageCount == 0) {
        _lastMessageCount = allMessages.length;
        _startMessageRefreshTimer();
      }
    } catch (e) {
      // Toast ile hata göster [[memory:6819767]]
      SnackbarUtils.showErrorSnackbar(
        'messages_load_error'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Yeni mesaj gönder
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || currentTicketId.value.isEmpty) return;

    try {
      isSending.value = true;

      // Debug: Hangi ticket ID kullanılıyor
      print('[DEBUG] Sending message with ticket ID: ${currentTicketId.value}');

      // Önce mesajı UI'da göster
      final tempMessage = MessageModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        from: 'current_user',
        fromModel: 'PeopleUser',
        toModel: 'AdminUser',
        message: text,
        status: 'sending',
        ticketId: currentTicketId.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      messages.add(tempMessage);
      textController.value.clear();
      messageText.value = '';

      // API'ye gönder
      final response = await _chatService.sendMessage(
        message: text,
        ticketId: currentTicketId.value,
      );

      // Geçici mesajı kaldır ve gerçek mesajı ekle
      messages.removeWhere((msg) => msg.id == tempMessage.id);
      messages.add(response.data);

      // Toast ile başarı mesajı göster [[memory:6819767]]
      Fluttertoast.showToast(
        msg: 'message_sent'.tr,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      // Hata durumunda geçici mesajı kaldır
      messages.removeWhere((msg) => msg.id.startsWith('temp_'));

      // Toast ile hata göster [[memory:6819767]]
      Fluttertoast.showToast(
        msg: 'message_send_error'.tr,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      isSending.value = false;
    }
  }

  /// Mesajları yenile
  Future<void> refreshMessages() async {
    await loadMessages();
  }

  /// Mesaj durumunu güncelle
  Future<void> markAsRead(String messageId) async {
    try {
      await _chatService.markMessageAsRead(messageId);

      // Local'de mesaj durumunu güncelle
      final index = messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        final message = messages[index];
        messages[index] = MessageModel(
          id: message.id,
          from: message.from,
          fromModel: message.fromModel,
          to: message.to,
          toModel: message.toModel,
          message: message.message,
          status: 'read',
          ticketId: message.ticketId,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt,
        );
      }
    } catch (e) {
      // Hata durumunda sessizce geç
    }
  }

  /// Mesajların sayısını getir
  int get messageCount => messages.length;

  /// Okunmamış mesaj sayısını getir
  int get unreadCount =>
      messages.where((msg) => !msg.isRead && !msg.isFromUser).length;

  /// Mesaj yenileme timer'ını başlat
  void _startMessageRefreshTimer() {
    _stopMessageRefreshTimer(); // Önceki timer'ı temizle

    _messageRefreshTimer = Timer.periodic(
      Duration(seconds: 10),
      (timer) => _checkForNewMessages(),
    );
  }

  /// Mesaj yenileme timer'ını durdur
  void _stopMessageRefreshTimer() {
    _messageRefreshTimer?.cancel();
    _messageRefreshTimer = null;
  }

  /// Yeni mesajları kontrol et
  Future<void> _checkForNewMessages() async {
    if (currentTicketId.value.isEmpty || isLoading.value || isSending.value) {
      return;
    }

    try {
      final allMessages =
          await _chatService.getAllMessages(currentTicketId.value);

      // Yeni mesaj varsa güncelle
      if (allMessages.length > _lastMessageCount) {
        messages.assignAll(allMessages);
        _lastMessageCount = allMessages.length;

        print('[DEBUG] New messages found! Total: ${allMessages.length}');
      }
    } catch (e) {
      // Hata durumunda sessizce geç, kullanıcıyı rahatsız etme
      print('[DEBUG] Error checking for new messages: $e');
    }
  }
}
