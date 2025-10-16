import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/favorites_controller.dart';
import 'package:avankart_people/controllers/notifications_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/widgets/company_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:io';

class FavoritesScreen extends StatefulWidget {
  FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late ScrollController _scrollController;
  late FavoritesController favoritesController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Initialize controller
    favoritesController = Get.put(FavoritesController());

    // Her screen açıldığında favorileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      favoritesController.refreshFavorites();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Obx(() => Text(
                'favorites'.tr + ' (${favoritesController.favorites.length})',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              )),
        ),
        actions: [
          // IconButton.filledTonal(
          //   icon: Image.asset(
          //     ImageAssets.trophy,
          //     width: 24,
          //     height: 24,
          //     color: Theme.of(context).colorScheme.onBackground,
          //   ),
          //   onPressed: () {
          //     Get.toNamed(AppRoutes.benefits);
          //   },
          //   style: IconButton.styleFrom(
          //     backgroundColor: Theme.of(context).colorScheme.secondary,
          //     fixedSize: Size(44, 44),
          //   ),
          // ),
          // SizedBox(width: 4),
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
                    final favoritesController = Get.find<FavoritesController>();
                    await favoritesController.refreshFavorites();
                  },
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 4),
                ),
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  title: GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.searchCompany,
                          arguments: {'heroTag': 'favorites_search_company'});
                    },
                    child: Hero(
                      tag: 'favorites_search_company',
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
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.filterSearch);
                              },
                              child: Container(
                                height: 44,
                                width: 44,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Header

                SliverToBoxAdapter(
                  child: SizedBox(height: 10),
                ),

                // Favorites List
                Obx(() {
                  if (favoritesController.isLoading &&
                      favoritesController.favorites.isEmpty) {
                    // Loading state
                    return SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 1.5,
                        crossAxisSpacing: 0,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Skeletonizer(
                          enabled: true,
                          enableSwitchAnimation: true,
                          child: CompanyCard(
                            name: 'Loading...',
                            location: 'Loading...',
                            distance: '0.0 km',
                            imageUrl: 'assets/images/image.png',
                            isOpen: true,
                            hasGift: false,
                            type: 'Company',
                            index: index,
                            companyId: '',
                            isFavorite: false,
                          ),
                        );
                      },
                    );
                  } else if (favoritesController.favorites.isEmpty) {
                    // Empty state
                    return SliverFillRemaining(
                      child: Animate(
                        effects: [
                          FadeEffect(duration: 700.ms),
                        ],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: Get.height / 3 - 100),
                              Image.asset(
                                ImageAssets.searchfavoriteicon,
                                height: 80,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'favorites_empty'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'favorites_empty_description'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Data state
                    return SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 1.5,
                        crossAxisSpacing: 0,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: favoritesController.favorites.length +
                          (favoritesController.hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Load more indicator
                        if (index == favoritesController.favorites.length) {
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

                        final company = favoritesController.favorites[index];
                        return Animate(
                          effects: [
                            FadeEffect(duration: 700.ms),
                          ],
                          child: Skeletonizer(
                            enableSwitchAnimation: true,
                            enabled: favoritesController.isLoading,
                            child: CompanyCard(
                              name: company.muessiseName,
                              location: company.location,
                              distance: company.displayDistance,
                              imageUrl: company.profileImagePath ??
                                  'assets/images/image.png',
                              isOpen: company.isOpen,
                              hasGift: false, // TODO: Bu bilgiyi API'den al
                              type: _getCompanyType(
                                  company), // TODO: Bu bilgiyi API'den al
                              index: index,
                              companyId: company.id,
                              isFavorite:
                                  true, // Favoriler listesindeki tüm şirketler zaten favoride
                            ),
                          ),
                        );
                      },
                    );
                  }
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
                final favoritesController = Get.find<FavoritesController>();
                await favoritesController.refreshFavorites();
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
                    automaticallyImplyLeading: false,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    title: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.searchCompany,
                            arguments: {'heroTag': 'favorites_search_company'});
                      },
                      child: Hero(
                        tag: 'favorites_search_company',
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
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(AppRoutes.filterSearch);
                                },
                                child: Container(
                                  height: 44,
                                  width: 44,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header

                  SliverToBoxAdapter(
                    child: SizedBox(height: 10),
                  ),

                  // Favorites List
                  Obx(() {
                    if (favoritesController.isLoading &&
                        favoritesController.favorites.isEmpty) {
                      // Loading state
                      return SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 1.5,
                          crossAxisSpacing: 0,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Animate(
                            effects: [
                              FadeEffect(duration: 700.ms),
                            ],
                            child: Skeletonizer(
                              enabled: true,
                              enableSwitchAnimation: true,
                              child: CompanyCard(
                                name: 'Loading...',
                                location: 'Loading...',
                                distance: '0.0 km',
                                imageUrl: 'assets/images/image.png',
                                isOpen: true,
                                hasGift: false,
                                type: 'Company',
                                index: index,
                                companyId: '',
                                isFavorite: false,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (favoritesController.favorites.isEmpty) {
                      // Empty state
                      return SliverFillRemaining(
                        child: Animate(
                          effects: [
                            FadeEffect(duration: 700.ms),
                          ],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: Get.height / 3 - 100),
                                Image.asset(
                                  ImageAssets.searchfavoriteicon,
                                  height: 80,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'favorites_empty'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'favorites_empty_description'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Data state
                      return SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 1.5,
                          crossAxisSpacing: 0,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: favoritesController.favorites.length +
                            (favoritesController.hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Load more indicator
                          if (index == favoritesController.favorites.length) {
                            return Container(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Platform.isIOS
                                    ? CupertinoActivityIndicator(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )
                                    : CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                              ),
                            );
                          }

                          final company = favoritesController.favorites[index];
                          return Skeletonizer(
                            enableSwitchAnimation: true,
                            enabled: favoritesController.isLoading,
                            child: CompanyCard(
                              name: company.muessiseName,
                              location: company.location,
                              distance: company.displayDistance,
                              imageUrl: company.profileImagePath ??
                                  'assets/images/image.png',
                              isOpen: company.isOpen,
                              hasGift: false, // TODO: Bu bilgiyi API'den al
                              type: _getCompanyType(
                                  company), // TODO: Bu bilgiyi API'den al
                              index: index,
                              companyId: company.id,
                              isFavorite:
                                  true, // Favoriler listesindeki tüm şirketler zaten favoride
                            ),
                          );
                        },
                      );
                    }
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

  // Scroll listener - kullanıcı aşağı scroll ettiğinde daha fazla veri yükle
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Son 200 piksel kaldığında daha fazla veri yükle
      final favoritesController = Get.find<FavoritesController>();
      if (favoritesController.hasMoreData && !favoritesController.isLoading) {
        favoritesController.loadMore();
      }
    }
  }

  /// Get company type for display
  String _getCompanyType(company) {
    // Bu fonksiyonu home screen'den kopyalayabiliriz
    // Şimdilik basit bir implementasyon
    return 'Company'; // Default
  }
}
