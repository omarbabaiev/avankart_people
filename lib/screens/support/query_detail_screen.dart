import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/query_chat_controller.dart';
import 'package:avankart_people/services/query_service.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class QueryDetailScreen extends StatefulWidget {
  @override
  _QueryDetailScreenState createState() => _QueryDetailScreenState();
}

class _QueryDetailScreenState extends State<QueryDetailScreen> {
  final Map<String, dynamic> query = Get.arguments as Map<String, dynamic>;
  final QueryService _queryService = QueryService();

  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> ticketDetails = <String, dynamic>{}.obs;

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
  }

  Future<void> _loadTicketDetails() async {
    try {
      isLoading.value = true;
      final response = await _queryService.getTicketDetails(
        ticketId: query["id"],
      );

      if (response['success'] == true) {
        ticketDetails.value = response['sorguData'] ?? {};
      } else {
        ToastUtils.showErrorToast('ticket_details_load_error'.tr);
      }
    } catch (e) {
      ToastUtils.showErrorToast('ticket_details_load_error'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            query["id"],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          SizedBox(width: 15),
          TextButton.icon(
            icon: Image.asset(
              ImageAssets.chatIcon,
              width: 20,
              height: 20,
            ),
            label: Text(
              "chat".tr,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryColor),
            ),
            onPressed: () {
              _showChat(context);
            },
          )
        ],
      ),
      body: Obx(() {
        return Skeletonizer(
          enabled: isLoading.value,
          enableSwitchAnimation: true,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.onPrimary,
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "query".tr,
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Theme.of(context).unselectedWidgetColor,
                              fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: switch (isLoading.value
                                  ? "baxilir"
                                  : (ticketDetails['status'] ??
                                      query["status"])) {
                                "baxilir" => Color(0xffF9B100),
                                "hell_olundu" => AppTheme.greenColor,
                                "qaralama" =>
                                  Theme.of(context).unselectedWidgetColor,
                                "redd_edildi" =>
                                  Theme.of(context).colorScheme.error,
                                _ => Colors.transparent,
                              },
                            ),
                            SizedBox(width: 4),
                            Text(
                              switch (isLoading.value
                                  ? "baxilir"
                                  : (ticketDetails['status'] ??
                                      query["status"])) {
                                "baxilir" => "pending".tr,
                                "hell_olundu" => "solved".tr,
                                "qaralama" => "draft".tr,
                                "redd_edildi" => "rejected".tr,
                                _ => "status_not_found".tr,
                              },
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: switch (isLoading.value
                                    ? "baxilir"
                                    : (ticketDetails['status'] ??
                                        query["status"])) {
                                  "baxilir" => Color(0xffF9B100),
                                  "hell_olundu" => AppTheme.greenColor,
                                  "qaralama" =>
                                    Theme.of(context).colorScheme.onBackground,
                                  "redd_edildi" =>
                                    Theme.of(context).colorScheme.error,
                                  _ =>
                                    Theme.of(context).colorScheme.onBackground,
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      isLoading.value
                          ? "loading".tr
                          : (ticketDetails['title'] ?? query["title"]),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      isLoading.value
                          ? "loading".tr
                          : (ticketDetails['content'] ?? query["description"]),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).unselectedWidgetColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "query_category".tr,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).unselectedWidgetColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      isLoading.value
                          ? "loading".tr
                          : (ticketDetails['category'] ?? "account_problem".tr),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "reasons_of_the_problem".tr,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).unselectedWidgetColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      isLoading.value
                          ? "loading".tr
                          : (ticketDetails['title'] ?? query["title"]),
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showChat(BuildContext context) {
    final ScrollController _scrollController = ScrollController();

    // Önceki controller'ı temizle ve yeni oluştur
    Get.delete<QueryChatController>();
    final QueryChatController controller = Get.put(QueryChatController());

    // Ticket ID'yi controller'a geç ve mesajları yükle
    // Önce ticket detail'den gelen _id'yi kullan, yoksa string ticket_id kullan
    final String ticketIdToUse = ticketDetails['_id'] ?? query["id"];
    debugPrint('[DEBUG] Chat opened with ticket ID: $ticketIdToUse');
    debugPrint('[DEBUG] Ticket details _id: ${ticketDetails['_id']}');
    debugPrint('[DEBUG] Query id: ${query["id"]}');
    controller.currentTicketId.value = ticketIdToUse;
    controller.loadMessages();

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: Get.height * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 10),
                Center(child: context.buildBottomSheetHandle()),
                Obx(() {
                  return Skeletonizer(
                    enableSwitchAnimation: true,
                    enabled: controller.isLoading.value,
                    child: Column(
                      children: [
                        Text(
                          now,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).splashColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          height: Get.height * 0.6,
                          child: Obx(() {
                            if (controller.messages.isEmpty) {
                              return Center(
                                child: Text(
                                  "no_messages".tr,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).unselectedWidgetColor,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: controller.messages.length,
                              itemBuilder: (context, index) {
                                final message = controller.messages[index];
                                return _buildMessageTile(
                                  context,
                                  message.isFromUser,
                                  message.message,
                                  message.status,
                                );
                              },
                            );
                          }),
                        )
                      ],
                    ),
                  );
                }),
              ],
            ),
            floatingActionButton: Container(
              height: 72,
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: controller.textController.value,
                      enabled: !controller.isSending.value,
                      onChanged: (value) {
                        controller.messageText.value = value;
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 16),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          hintText: "your_message".tr,
                          hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Theme.of(context)
                                  .unselectedWidgetColor
                                  .withOpacity(.3),
                              fontSize: 13)),
                    ),
                  ),
                  Row(
                    children: [
                      Obx(() {
                        final isDisabled = controller.isSending.value ||
                            controller.messageText.value.trim().isEmpty;

                        return GestureDetector(
                          onTap: isDisabled
                              ? null
                              : () {
                                  controller.sendMessage(
                                      controller.textController.value.text);
                                },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDisabled
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            child: controller.isSending.value
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.white),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      ImageAssets.sendIcon,
                                      width: 10,
                                      height: 10,
                                      color: isDisabled
                                          ? AppTheme.white.withOpacity(0.5)
                                          : AppTheme.white,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ],
                  )
                ],
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(50)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageTile(
      BuildContext context, bool isFromUser, String message, String status) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              width: isFromUser ? Get.width - 130 : Get.width - 80,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft:
                      isFromUser ? Radius.circular(16) : Radius.circular(0),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight:
                      isFromUser ? Radius.circular(0) : Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isFromUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: !isFromUser
                        ? CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage(ImageAssets.avankartPartnerLogo),
                          )
                        : null,
                    title: Text(
                      textAlign: isFromUser ? TextAlign.end : TextAlign.start,
                      message,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Theme.of(context).unselectedWidgetColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  // Text(
                  //   _getStatusText(status),
                  //   style: TextStyle(
                  //     fontFamily: 'Poppins',
                  //     fontSize: 10,
                  //     color: isFromUser
                  //         ? AppTheme.white.withOpacity(0.7)
                  //         : Theme.of(context).unselectedWidgetColor,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'sending':
        return 'sending'.tr + '...';
      case 'sent':
        return 'sent'.tr;
      case 'unread':
        return 'unread'.tr;
      case 'read':
        return 'read'.tr;
      default:
        return 'status_not_found'.tr;
    }
  }

  String get now => DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());
}
