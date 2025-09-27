import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/query_chat_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/widgets/company_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QueryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> query = Get.arguments as Map<String, dynamic>;

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
            icon: Icon(
              Icons.chat_bubble_outline,
              size: 20,
            ),
            label: Text(
              "Chat",
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
      body: Column(
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
                      "Sorğu",
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
                          color: switch (query["status"]) {
                            "pending" => Color(0xffF9B100),
                            "solved" => AppTheme.greenColor,
                            "draft" => Theme.of(context).unselectedWidgetColor,
                            _ => Colors.transparent,
                          },
                        ),
                        SizedBox(width: 4),
                        Text(
                          switch (query["status"]) {
                            "pending" => "Gözləmədə",
                            "solved" => "Həll edildi",
                            "draft" => "Qaralama",
                            _ => "Status tapılmadı",
                          },
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: switch (query["status"]) {
                              "pending" => Color(0xffF9B100),
                              "solved" => AppTheme.greenColor,
                              "draft" =>
                                Theme.of(context).colorScheme.onBackground,
                              _ => Theme.of(context).colorScheme.onBackground,
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
                  query["title"],
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
                  query["description"],
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
                  "Sorğu kategoriyası",
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
                  "Hesab problemi",
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
                  "Problemin səbəbləri",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(query['reason'].length, (index) {
                    List _reasonList = query['reason'];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          _reasonList[index],
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        _reasonList[index] == _reasonList.last
                            ? SizedBox()
                            : Divider(
                                height: 0.1,
                                color: Theme.of(context).dividerColor,
                              )
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          ...query['files'].map((e) => buildFileTile(context, e)).toList(),
        ],
      ),
    );
  }

  Widget buildFileTile(BuildContext context, String url) {
    final fileName = url.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();

    Widget leadingWidget;
    if (['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(fileExtension)) {
      leadingWidget =
          Image.network(url, height: 40, width: 40, fit: BoxFit.cover);
    } else {
      IconData icon;
      switch (fileExtension) {
        case 'pdf':
          icon = Icons.picture_as_pdf_outlined;
          break;
        case 'doc':
        case 'docx':
          icon = Icons.description_outlined;
          break;
        case 'xls':
        case 'xlsx':
          icon = Icons.table_chart_outlined;
          break;
        case 'ppt':
        case 'pptx':
          icon = Icons.slideshow_outlined;
          break;
        default:
          icon = Icons.insert_drive_file_outlined;
      }
      leadingWidget =
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary);
    }

    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Theme.of(context).colorScheme.onPrimary,
      child: ListTile(
        leading: leadingWidget,
        trailing: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Theme.of(context).unselectedWidgetColor.withOpacity(0.2),
            border: Border.all(
              width: 2,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close,
              size: 14, color: Theme.of(context).unselectedWidgetColor),
        ),
        title: Text(
          fileName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          url,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Theme.of(context).unselectedWidgetColor,
          ),
        ),
      ),
    );
  }

  final now = DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now());

  void _showChat(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    final QueryChatController controller = Get.put(QueryChatController());

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
                Skeletonizer(
                  enableSwitchAnimation: true,
                  enabled: false,
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
                      SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        height: Get.height * 0.6,
                        child: Obx(() => ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.messages.length,
                              itemBuilder: (context, index) {
                                final message = controller.messages[index];
                                return _buildMessageTile(
                                  context,
                                  message['isUser'],
                                  message['message'],
                                );
                              },
                            )),
                      )
                    ],
                  ),
                ),
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
                      onChanged: (value) {},
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 16),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          hintText: "Mesajınız...",
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
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: Icon(
                          Icons.file_copy,
                          size: 20,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          controller
                              .addMessage(controller.textController.value.text);
                        },
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Icon(
                            Icons.send,
                            size: 20,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
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

  Animate _buildMessageTile(BuildContext context, bool isUser, String message) {
    return Animate(
      effects: [SlideEffect(begin: Offset(0, -.5), end: Offset(0, 0))],
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 287,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: !isUser ? Radius.circular(0) : Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight:
                      !isUser ? Radius.circular(12) : Radius.circular(0)),
              color: Theme.of(context).colorScheme.secondary),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              isUser
                  ? SizedBox()
                  : Container(
                      height: 50.2,
                      width: 50.57,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary),
                      padding: EdgeInsets.all(10),
                      child: Image.asset(
                        ImageAssets.png_logo,
                      ),
                    ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  message,
                  textAlign: isUser ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(.8),
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
