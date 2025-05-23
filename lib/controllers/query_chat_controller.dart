import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class QueryChatController extends GetxController {
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final textController = TextEditingController().obs;

  void addMessage(String text) {
    if (text.trim().isNotEmpty) {
      messages.add({
        'isUser': true,
        'message': text,
        'timestamp': DateTime.now().toString(),
      });
      textController.value.text = "";
    }
  }
}
