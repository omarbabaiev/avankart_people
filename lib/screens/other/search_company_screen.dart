import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/widgets/company_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SearchCompanyScreen extends StatefulWidget {
  @override
  _SearchCompanyScreenState createState() => _SearchCompanyScreenState();
}

class _SearchCompanyScreenState extends State<SearchCompanyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // TextField'a sayfa açılır açılmaz focus ver
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(68),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Hero(
                tag: Get.arguments?['heroTag'] ?? 'search_company',
                child: Container(
                  color: Theme.of(context).colorScheme.onPrimary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  ImageAssets.searchNormal,
                                  width: 24,
                                  height: 24,
                                  color: Theme.of(context)
                                      .bottomNavigationBarTheme
                                      .unselectedItemColor,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      autofocus: true,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (value) {
                                        // Arama yapıldığında burası çalışacak
                                        if (value.isNotEmpty) {
                                          // Arama sonuçlarını göster
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .bottomNavigationBarTheme
                                              .unselectedItemColor
                                              ?.withOpacity(.8),
                                        ),
                                        fillColor: Colors.transparent,
                                        hintText: 'search_placeholder'.tr,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .bottomNavigationBarTheme
                                            .unselectedItemColor
                                            ?.withOpacity(.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        CupertinoButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            'cancel'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Theme.of(context).unselectedWidgetColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 4,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.onPrimary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('search_history'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Theme.of(context).unselectedWidgetColor,
                          )),
                    ),
                    SizedBox(height: 6),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('restaurant'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onBackground,
                          )),
                      trailing: Icon(
                        Icons.close,
                        color: Theme.of(context).unselectedWidgetColor,
                        size: 24,
                      ),
                      onTap: () {
                        _searchController.text = 'restaurant'.tr;
                        _searchFocusNode.requestFocus();
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('ozsut'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onBackground,
                          )),
                      trailing: Icon(
                        Icons.close,
                        color: Theme.of(context).unselectedWidgetColor,
                        size: 24,
                      ),
                      onTap: () {
                        _searchController.text = 'ozsut'.tr;
                        _searchFocusNode.requestFocus();
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('borani_restaurant'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.onBackground,
                          )),
                      trailing: Icon(
                        Icons.close,
                        color: Theme.of(context).unselectedWidgetColor,
                        size: 24,
                      ),
                      onTap: () {
                        _searchController.text = 'borani_restaurant'.tr;
                        _searchFocusNode.requestFocus();
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
