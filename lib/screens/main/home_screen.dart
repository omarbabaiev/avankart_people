import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/home_controller.dart';
import 'package:avankart_people/controllers/notifications_controller.dart';
import 'package:avankart_people/controllers/filter_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:avankart_people/models/companies_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../widgets/company_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late ScrollController _scrollController;
  FilterController? _filterController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    // FilterController'ı başlat (varsa kullan, yoksa oluştur)
    try {
      _filterController = Get.isRegistered<FilterController>()
          ? Get.find<FilterController>()
          : Get.put(FilterController());
    } catch (e) {
      _filterController = Get.put(FilterController());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Scroll listener - kullanıcı aşağı scroll ettiğinde daha fazla veri yükle
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll - 200; // Son 200 piksel kaldığında

    if (currentScroll >= threshold) {
      final controller = Get.find<HomeController>();
      if (controller.hasMoreDataCompanies && !controller.isLoadingCompanies) {
        debugPrint('[HOME SCREEN] ===== LOAD MORE TRIGGERED =====');
        debugPrint('[HOME SCREEN] Current scroll: $currentScroll');
        debugPrint('[HOME SCREEN] Max scroll: $maxScroll');
        debugPrint('[HOME SCREEN] Threshold: $threshold');
        debugPrint(
            '[HOME SCREEN] Has more: ${controller.hasMoreDataCompanies}');
        debugPrint(
            '[HOME SCREEN] Is loading: ${controller.isLoadingCompanies}');
        controller.loadMoreCompanies();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Uygulama ön plana geldiğinde home screen'i refresh et
    if (state == AppLifecycleState.resumed) {
      debugPrint('[HOME SCREEN] 🔄 App resumed, refreshing companies...');
      final controller = Get.find<HomeController>();
      controller.refreshCompanies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Obx(() => Text(
                _getLocationText(controller),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )),
        ),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              fixedSize: Size(44, 44),
            ),
            icon: Image.asset(
              ImageAssets.heartStraight,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            onPressed: () {
              Get.toNamed(AppRoutes.favorites);
            },
          ),
          SizedBox(width: 4),
          Obx(() {
            final notificationsController = Get.find<NotificationsController>();
            final unreadCount = notificationsController.unreadCount;

            return Stack(
              children: [
                IconButton.filledTonal(
                  icon: Image.asset(
                    ImageAssets.bellInactive,
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  onPressed: () {
                    Get.toNamed(AppRoutes.notifications);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    fixedSize: Size(44, 44),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      alignment: Alignment.center,
                      child: Text(
                        unreadCount.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          }),
          SizedBox(width: 15),
        ],
      ),
      body: Platform.isIOS
          ? CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    final controller = Get.find<HomeController>();
                    await controller.refreshCompanies();
                  },
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 4),
                ),
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  title: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.searchCompany,
                          arguments: {'heroTag': 'home_search_company'});
                    },
                    child: Hero(
                      tag: 'home_search_company',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                                    Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        'search_placeholder'.tr,
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
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(AppRoutes.filterSearch);
                                  },
                                  child: Container(
                                    height: 44,
                                    width: 44,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      ImageAssets.funnel,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                ),
                                Obx(() {
                                  return !_filterController!.hasSelectedFilters
                                      ? const SizedBox.shrink()
                                      : Positioned(
                                          right: 4,
                                          top: 4,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'establishments'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        Obx(() {
                          final currentFilterType = controller.filterType;
                          return TextButton.icon(
                            onPressed: () {
                              showMenu(
                                menuPadding: EdgeInsets.all(5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                color: Theme.of(context).colorScheme.secondary,
                                context: context,
                                position: RelativeRect.fromLTRB(1, 250, 0, 0),
                                items: [
                                  PopupMenuItem(
                                    value: 'name',
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'a_to_z'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (currentFilterType == 'name')
                                          Icon(
                                            Icons.check,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                    onTap: () {
                                      controller.setFilterType('name');
                                    },
                                  ),
                                  PopupMenuItem(
                                    value: 'distance',
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'by_distance'.tr,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (currentFilterType == 'distance')
                                          Icon(
                                            Icons.check,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                    onTap: () {
                                      controller.setFilterType('distance');
                                    },
                                  ),
                                ],
                              );
                            },
                            icon: Image.asset(
                              ImageAssets.sortAscending,
                              width: 24,
                              height: 24,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            label: Text(
                              'sort'.tr,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Restaurant List
                Obx(() {
                  final isLoading = controller.isLoadingCompanies;
                  final companies = controller.companies;
                  final error = controller.companiesError;

                  // Error state
                  if (error.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildErrorState(context, error),
                    );
                  }

                  // Empty state (loading false ve companies empty)
                  if (!isLoading && companies.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildEmptyState(context),
                    );
                  }

                  return SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 1.5,
                      crossAxisSpacing: 0,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: companies.isEmpty
                        ? 6
                        : companies.length +
                            (controller.hasMoreDataCompanies ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (companies.isEmpty) {
                        // Skeleton card
                        return Animate(
                          effects: [
                            FadeEffect(duration: 700.ms),
                          ],
                          child: CompanyCard(
                            name: 'Company Name',
                            location: 'Company Location',
                            distance: '0.0 km',
                            imageUrl: 'assets/images/image.png',
                            isOpen: true,
                            hasGift: false,
                            type: 'business',
                            index: index,
                            companyId: '0',
                          ),
                        );
                      }

                      // Load more indicator
                      if (index == companies.length) {
                        return Container(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Platform.isIOS
                                ? CupertinoActivityIndicator(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                : CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                          ),
                        );
                      }

                      final company = companies[index];
                      return Animate(
                        effects: [
                          FadeEffect(duration: 700.ms),
                        ],
                        child: CompanyCard(
                          name: company.muessiseName,
                          location: company.location,
                          distance: company.displayDistance,
                          imageUrl: company.xariciCoverImagePath ??
                              'assets/images/image.png',
                          isOpen: company.isOpen,
                          hasGift: false, // TODO: Bu bilgiyi API'den al
                          // TODO: Bu bilgiyi API'den al
                          index: index,
                          companyId: company.id,
                          isFavorite: company.isFavorite, type: 'business',
                        ),
                      );
                    },
                  );
                }),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
                  ),
                )
              ],
            )
          : RefreshIndicator.adaptive(
              onRefresh: () async {
                final controller = Get.find<HomeController>();
                await controller.refreshCompanies();
              },
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 4),
                  ),
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    snap: true,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    title: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.searchCompany,
                            arguments: {'heroTag': 'home_search_company'});
                      },
                      child: Hero(
                        tag: 'home_search_company',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
                                      Obx(() {
                                        final homeController =
                                            Get.find<HomeController>();
                                        final searchText = homeController
                                                .currentSearchQuery.isNotEmpty
                                            ? homeController.currentSearchQuery
                                            : 'search_placeholder'.tr;

                                        return Material(
                                          color: Colors.transparent,
                                          child: Text(
                                            searchText,
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
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(AppRoutes.filterSearch);
                                    },
                                    child: Container(
                                      height: 44,
                                      width: 44,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        ImageAssets.funnel,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    if (_filterController == null ||
                                        !_filterController!.hasSelectedFilters)
                                      return const SizedBox.shrink();

                                    return Positioned(
                                      right: 4,
                                      top: 4,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 5, left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'establishments'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          SizedBox(width: 10),
                          Obx(() {
                            final currentFilterType = controller.filterType;
                            return TextButton.icon(
                              onPressed: () {
                                showMenu(
                                  menuPadding: EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  context: context,
                                  position: RelativeRect.fromLTRB(1, 250, 0, 0),
                                  items: [
                                    PopupMenuItem(
                                      value: 'name',
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'a_to_z'.tr,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (currentFilterType == 'name')
                                            Icon(
                                              Icons.check,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                      onTap: () {
                                        controller.setFilterType('name');
                                      },
                                    ),
                                    PopupMenuItem(
                                      value: 'distance',
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'by_distance'.tr,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (currentFilterType == 'distance')
                                            Icon(
                                              Icons.check,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                      onTap: () {
                                        controller.setFilterType('distance');
                                      },
                                    ),
                                  ],
                                );
                              },
                              icon: Image.asset(
                                ImageAssets.sortAscending,
                                width: 24,
                                height: 24,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                              label: Text(
                                'sort'.tr,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Company List
                  Obx(() {
                    final isLoading = controller.isLoadingCompanies;
                    final companies = controller.companies;
                    final error = controller.companiesError;

                    // Error state
                    if (error.isNotEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildErrorState(context, error),
                      );
                    }

                    // Empty state (loading false ve companies empty)
                    if (!isLoading && companies.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState(context),
                      );
                    }

                    return SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 1.5,
                        crossAxisSpacing: 0,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: companies.isEmpty
                          ? 6
                          : companies.length +
                              (controller.hasMoreDataCompanies ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (companies.isEmpty) {
                          // Skeleton card
                          return Skeletonizer(
                            enabled: true,
                            enableSwitchAnimation: true,
                            child: Animate(
                              effects: [
                                FadeEffect(duration: 700.ms),
                              ],
                              child: CompanyCard(
                                name: 'Company Name',
                                location: 'Company Location',
                                distance: '0.0 km',
                                imageUrl: 'assets/images/image.png',
                                isOpen: true,
                                hasGift: false,
                                type: 'business',
                                index: index,
                                companyId: '0',
                              ),
                            ),
                          );
                        }

                        // Load more indicator
                        if (index == companies.length) {
                          return Container(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Platform.isIOS
                                  ? CupertinoActivityIndicator(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                            ),
                          );
                        }

                        final company = companies[index];
                        return Animate(
                          effects: [
                            FadeEffect(duration: 700.ms),
                          ],
                          child: CompanyCard(
                            name: company.muessiseName,
                            location: company.location,
                            distance: company.displayDistance,
                            imageUrl: company.profileImagePath ??
                                'assets/images/image.png',
                            isOpen: company.isOpen,
                            hasGift: false, // TODO: Bu bilgiyi API'den al
                            index: index,
                            companyId: company.id,
                            isFavorite: company.isFavorite, type: 'business',
                          ),
                        );
                      },
                    );
                  }),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 150,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Animate(
      effects: [
        FadeEffect(duration: 700.ms),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'error_loading_companies'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 16),
            ElevatedButton(
              style: AppTheme.primaryButtonStyle(),
              onPressed: () {
                final controller = Get.find<HomeController>();
                controller.refreshCompanies();
              },
              child: Text(
                'retry'.tr,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          Image.asset(
            ImageAssets.pepIcon,
            height: 30,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          const SizedBox(height: 16),
          Text(
            'no_companies_available'.tr,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
                fontFamily: "Poppins"),
          ),
          const SizedBox(height: 8),
          Text(
            'pull_to_refresh'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.outline,
                fontFamily: "Poppins"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: AppTheme.primaryButtonStyle(),
            onPressed: () {
              final controller = Get.find<HomeController>();
              controller.refreshCompanies();
            },
            child: Text(
              'refresh'.tr,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dinamik lokasyon metni döndür
  String _getLocationText(HomeController controller) {
    // Eğer companies yüklendiyse ve konum varsa
    if (controller.companies.isNotEmpty) {
      // İlk company'nin distance'ına bakarak konum olup olmadığını kontrol et
      final hasLocation = controller.companies.first.distance > 0;
      if (hasLocation) {
        return 'current_location'.tr;
      }
    }
    // Varsayılan olarak Baku göster
    return 'baku_azerbaijan'.tr;
  }
}
