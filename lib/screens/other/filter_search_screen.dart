import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/controllers/filter_controller.dart';
import 'package:avankart_people/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:io';

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
              onPressed: () async {
                // HomeController'ı bul ve companies'leri yenile
                if (Get.isRegistered<HomeController>()) {
                  final homeController = Get.find<HomeController>();
                  // Filter'dan seçilen kartlar otomatik olarak loadCompanies'de kullanılacak
                  await homeController.loadCompanies(isRefresh: true);
                }
                // Home screen'e geri dön
                Get.back();
              },
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
                                onChanged: (value) {
                                  controller.updateSearchQuery(value);
                                },
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
        () {
          // Empty state - filter categories boşsa
          if (controller.filterCategories.isEmpty &&
              !controller.isLoadingCards) {
            return _buildEmptyState(context);
          }

          // Loading sırasında skeleton göster
          if (controller.isLoadingCards) {
            return _buildFilterSkeleton(context);
          }

          // Platform-specific refresh
          final categories = controller.filteredCategories;

          if (Platform.isIOS) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    await controller.loadFilterCards();
                  },
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, categoryIndex) {
                      final category = categories[categoryIndex];
                      return Animate(
                        effects: [
                          FadeEffect(duration: 700.ms),
                        ],
                        child: Container(
                          color: Theme.of(context).colorScheme.onPrimary,
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 5, bottom: 5),
                                child: Text(
                                  category['header'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).unselectedWidgetColor,
                                  ),
                                ),
                              ),
                              ...List.generate(
                                (category['items'] as List).length,
                                (itemIndex) {
                                  final item =
                                      (category['items'] as List)[itemIndex];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: 16, right: 16, top: 5, bottom: 8),
                                    child: Row(
                                      children: [
                                        AppTheme.adaptiveCheckbox(
                                          value: item['isSelected'] as bool,
                                          onChanged: (_) =>
                                              controller.toggleSelection(
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ],
            );
          } else {
            return RefreshIndicator.adaptive(
              onRefresh: () async {
                await controller.loadFilterCards();
              },
              child: Animate(
                effects: [
                  FadeEffect(duration: 700.ms),
                ],
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = categories[categoryIndex];
                    return Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 5, bottom: 5),
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
                              final item =
                                  (category['items'] as List)[itemIndex];
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 5, bottom: 8),
                                child: Row(
                                  children: [
                                    AppTheme.adaptiveCheckbox(
                                      value: item['isSelected'] as bool,
                                      onChanged: (_) =>
                                          controller.toggleSelection(
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
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
        },
      ),
    );
  }

  Widget _buildFilterSkeleton(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.only(bottom: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton header
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 10),
            child: Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: Theme.of(context).unselectedWidgetColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Skeleton items
          ...List.generate(
            5, // Her kategori için 5 item skeleton'u
            (itemIndex) {
              return Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 12),
                child: Row(
                  children: [
                    // Skeleton checkbox
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).unselectedWidgetColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Skeleton text
                    Expanded(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Theme.of(context).unselectedWidgetColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 80,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            const SizedBox(height: 24),
            Text(
              'no_filter_categories'.tr,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'no_filter_categories_description'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
