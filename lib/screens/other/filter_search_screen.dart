import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/controllers/filter_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class FilterSearchScreen extends GetView<FilterController> {
  final FilterController controller = Get.put(FilterController());

  FilterSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          'filter'.tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(() => controller.hasSelectedFilters
              ? CupertinoButton(
                  child: Text(
                    'clear_filters'.tr,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  onPressed: controller.clearFilters)
              : const SizedBox()),
          SizedBox(
            height: 37,
            width: 70,
            child: ElevatedButton(
              onPressed: () {},
              style: AppTheme.primaryButtonStyle().copyWith(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
              ),
              child: Text(
                'apply_filter'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            color: Theme.of(context).colorScheme.onPrimary,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: TextField(
                                // controller: _searchController,
                                // focusNode: _searchFocusNode,
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
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .unselectedItemColor
                                        ?.withOpacity(.8),
                                  ),
                                  fillColor: Colors.transparent,
                                  hintText: 'filter_category_hint'.tr,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .bottomNavigationBarTheme
                                      .unselectedItemColor
                                      ?.withOpacity(.8),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.filterCategories.length,
          itemBuilder: (context, categoryIndex) {
            final category = controller.filterCategories[categoryIndex];
            return Container(
              color: Theme.of(context).colorScheme.onPrimary,
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                    child: Text(
                      category['header'] as String,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).unselectedWidgetColor,
                      ),
                    ),
                  ),
                  ...List.generate(
                    (category['items'] as List).length,
                    (itemIndex) {
                      final item = (category['items'] as List)[itemIndex];
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 5, bottom: 8),
                        child: Row(
                          children: [
                            AppTheme.adaptiveCheckbox(
                              value: item['isSelected'] as bool,
                              onChanged: (_) => controller.toggleSelection(
                                  categoryIndex, itemIndex),
                              size: 24,
                            ),
                            SizedBox(width: 5),
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
