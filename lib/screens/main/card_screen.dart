import 'dart:io';

import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/widgets/bottom_sheets/request_for_imtiyaz_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class CardScreen extends GetView<CardController> {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CardController());

    return Obx(
      () {
        // Loading durumunda skeleton göster
        if (controller.isLoading.value) {
          return _buildCardScreenSkeleton(context);
        }

        // Kart yoksa uygun mesaj göster
        if (controller.cards.isEmpty && !controller.isLoading.value) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            appBar: AppBar(
              toolbarHeight: 68,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              centerTitle: false,
              title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'cards'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ),
            body: Center(
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Image.asset(ImageAssets.walletEmpty, height: 200),
                  SizedBox(height: 8),
                  Text(
                    'no_imtiyaz_card_found'.tr,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      textAlign: TextAlign.center,
                      'no_imtiyaz_card_found_description'.tr,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () {
                      RequestForImtiyazCardBottomSheet.show(context);
                    },
                    child: Text(
                      'muraciet_for_card'.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Güvenli erişim kontrolü
        if (controller.selectedCardIndex.value < 0 ||
            controller.selectedCardIndex.value >= controller.cards.length) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            appBar: AppBar(
              toolbarHeight: 68,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'cards'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ),
            body: Center(
              child: Column(
                children: [
                  Image.asset(ImageAssets.walletEmpty, height: 200),
                  SizedBox(height: 8),
                  Text(
                    'no_imtiyaz_card_found'.tr,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'no_imtiyaz_card_found_description'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () {
                      RequestForImtiyazCardBottomSheet.show(context);
                    },
                    child: Text(
                      'muraciet_for_card'.tr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Debug: Kart rengi bilgisi
        final currentCard =
            controller.cards[controller.selectedCardIndex.value];
        final cardColor = currentCard['color'];
        debugPrint('[CARD SCREEN] ===== CARD COLOR DEBUG =====');
        debugPrint(
            '[CARD SCREEN] Selected Index: ${controller.selectedCardIndex.value}');
        debugPrint('[CARD SCREEN] Card Title: ${currentCard['title']}');
        debugPrint('[CARD SCREEN] Card Color: $cardColor');
        debugPrint('[CARD SCREEN] Color Type: ${cardColor.runtimeType}');
        debugPrint('[CARD SCREEN] ============================');

        return Obx(
          () => Animate(
            effects: [
              FadeEffect(duration: 500.ms),
            ],
            child: AnimatedContainer(
              decoration: BoxDecoration(
                color: controller.cards[controller.selectedCardIndex.value]
                    ['color'],
              ),
              duration: Duration(milliseconds: 700),
              child: Stack(
                children: [
                  FadeInImage(
                    placeholder: AssetImage(ImageAssets.background),
                    image: AssetImage(ImageAssets.background),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SafeArea(
                      bottom: false,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Ekran yüksekliği
                          final screenHeight = constraints.maxHeight;
                          final safeAreaTop =
                              MediaQuery.of(context).padding.top;

                          // Card header yapısı yükseklikleri:
                          // - Top padding: 40
                          // - Pagination: 17
                          // - Spacing: 20
                          // - Bakiye alanı (kart ismi + bakiye): ~48 (13px text + 4px spacing + 28px counter)
                          // - Bottom spacing: 5
                          // - Butonlar: 70 (54px circle + 4px spacing + 12px text)

                          // Bakiye yüksekliği (butonlar hariç)
                          final bakiyeYuksekligi =
                              40.0 + 17.0 + 20.0 + 48.0 + 5.0; // ~130px
                          // Butonlar yüksekliği (circle + spacing + text)
                          final butonlarYuksekligi = 70.0; // 54 + 4 + 12
                          // Butonlar text'in altından boşluk (daha aşağı için artırıldı)
                          final butonlarAltindakiBosluk = 25.0;

                          // Maximum size: Sheet bakiyenin direkt altında (butonlar kaybolmuş)
                          final maxSize = 1.0 -
                              ((bakiyeYuksekligi + safeAreaTop) / screenHeight);

                          // Minimum size: Sheet butonların text'inin altından 15px boşlukla (butonlar görünür)
                          final minSize = 1.0 -
                              ((bakiyeYuksekligi +
                                      butonlarYuksekligi +
                                      butonlarAltindakiBosluk +
                                      safeAreaTop) /
                                  screenHeight);

                          // Clamp değerleri (güvenlik için)
                          final clampedMaxSize = maxSize.clamp(0.7, 0.95);
                          final clampedMinSize = minSize.clamp(0.4, 0.85);

                          // Initial size = min size (butonlar görünür başlasın)
                          final initialSize = clampedMinSize;

                          // Controller'a minSize'ı set et (buton gizleme için)
                          controller.bottomSheetMinSize = clampedMinSize;

                          return Stack(
                            children: [
                              // Üst kısım - Kart Bilgileri
                              _buildCardHeader(context),
                              // Alt kısım - İşlemler Listesi (DraggableScrollableSheet)
                              DraggableScrollableSheet(
                                initialChildSize: initialSize,
                                minChildSize: clampedMinSize,
                                maxChildSize: clampedMaxSize,
                                snap: true,
                                snapSizes: [clampedMinSize, clampedMaxSize],
                                snapAnimationDuration:
                                    const Duration(milliseconds: 400),
                                controller: controller.dragController,
                                builder: (BuildContext context,
                                    ScrollController scrollController) {
                                  return Hero(
                                    tag: 'card_header',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 16,
                                                  right: 16,
                                                  top: 12,
                                                  bottom: 3),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'transactions'.tr,
                                                    style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onBackground,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  // Row(
                                                  //   children: [
                                                  //     Container(
                                                  //       padding: EdgeInsets.all(10),
                                                  //       decoration: BoxDecoration(
                                                  //         color: Theme.of(context)
                                                  //             .colorScheme
                                                  //             .secondaryContainer,
                                                  //         shape: BoxShape.circle,
                                                  //       ),
                                                  //       child: Icon(
                                                  //         Icons
                                                  //             .file_download_outlined,
                                                  //         size: 20,
                                                  //         color: Theme.of(context)
                                                  //             .colorScheme
                                                  //             .onBackground,
                                                  //       ),
                                                  //     ),
                                                  //     SizedBox(width: 8),
                                                  //     Container(
                                                  //       padding: EdgeInsets.all(10),
                                                  //       decoration: BoxDecoration(
                                                  //         color: Theme.of(context)
                                                  //             .colorScheme
                                                  //             .secondaryContainer,
                                                  //         shape: BoxShape.circle,
                                                  //       ),
                                                  //       child: Icon(
                                                  //         Icons.analytics_outlined,
                                                  //         size: 20,
                                                  //         color: Theme.of(context)
                                                  //             .colorScheme
                                                  //             .onBackground,
                                                  //       ),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                ],
                                              ),
                                            ),
                                            Divider(
                                                color: Theme.of(context)
                                                    .dividerColor,
                                                thickness: .5),
                                            Expanded(
                                              child: Obx(
                                                () {
                                                  if (controller.hasTransactions
                                                              .value ==
                                                          false &&
                                                      controller
                                                              .isTransactionLoading
                                                              .value ==
                                                          false) {
                                                    return Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .receipt_long_outlined,
                                                            size: 64,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                          SizedBox(height: 16),
                                                          Text(
                                                            controller
                                                                .emptyTransactionMessage
                                                                .value,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            'new_transactions_here'
                                                                .tr,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .grey[500],
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          SizedBox(height: 80),
                                                        ],
                                                      ),
                                                    );
                                                  } else if (controller
                                                      .isTransactionLoading
                                                      .value) {
                                                    // Transaction listesi
                                                    return Skeletonizer(
                                                      enableSwitchAnimation:
                                                          true,
                                                      enabled: true,
                                                      child: ListView.builder(
                                                        controller:
                                                            scrollController,
                                                        itemCount:
                                                            5, // 5 skeleton item
                                                        itemBuilder:
                                                            (context, index) {
                                                          return _buildTransactionItem(
                                                              {
                                                                'title':
                                                                    'İşlemeweewew',
                                                                'subtitle':
                                                                    'Genelewewewewewewewe',
                                                                'amount':
                                                                    '0.ee',
                                                                'date': '0.ee',
                                                                'icon':
                                                                    'assets/images/Silver.png',
                                                                'isPositive':
                                                                    false,
                                                              },
                                                              context);
                                                        },
                                                      ),
                                                    );
                                                  } else {
                                                    // Transaction'ları tarih gruplarına ayır
                                                    final groupedTransactions =
                                                        <String,
                                                            List<
                                                                Map<String,
                                                                    dynamic>>>{};
                                                    String? currentDate;
                                                    for (var transaction
                                                        in controller
                                                            .transactions) {
                                                      final date =
                                                          transaction['date']
                                                                  as String? ??
                                                              '';
                                                      if (date != currentDate) {
                                                        currentDate = date;
                                                        if (!groupedTransactions
                                                            .containsKey(
                                                                date)) {
                                                          groupedTransactions[
                                                              date] = [];
                                                        }
                                                      }
                                                      groupedTransactions[date]!
                                                          .add(transaction);
                                                    }

                                                    final dates =
                                                        groupedTransactions.keys
                                                            .toList();

                                                    // Sliver listesi oluştur
                                                    final slivers = <Widget>[];
                                                    for (int dateIndex = 0;
                                                        dateIndex <
                                                            dates.length;
                                                        dateIndex++) {
                                                      final date =
                                                          dates[dateIndex];
                                                      final transactions =
                                                          groupedTransactions[
                                                              date]!;

                                                      // Sticky Header - Her tarih için benzersiz key
                                                      slivers.add(
                                                        SliverPersistentHeader(
                                                          key: ValueKey(
                                                              'header_$date'),
                                                          pinned: true,
                                                          delegate:
                                                              _StickyHeaderDelegate(
                                                            date: date,
                                                            backgroundColor: Theme
                                                                    .of(context)
                                                                .scaffoldBackgroundColor,
                                                          ),
                                                        ),
                                                      );

                                                      // Transaction Items
                                                      slivers.add(
                                                        SliverList(
                                                          key: ValueKey(
                                                              'list_$date'),
                                                          delegate:
                                                              SliverChildBuilderDelegate(
                                                            (context, index) {
                                                              final transaction =
                                                                  transactions[
                                                                      index];
                                                              final isLast = index ==
                                                                  transactions
                                                                          .length -
                                                                      1;
                                                              return Column(
                                                                children: [
                                                                  _buildTransactionItem(
                                                                      transaction,
                                                                      context),
                                                                  if (!isLast)
                                                                    Divider(
                                                                      indent:
                                                                          16,
                                                                      endIndent:
                                                                          16,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .dividerColor,
                                                                      thickness:
                                                                          .5,
                                                                    ),
                                                                ],
                                                              );
                                                            },
                                                            childCount:
                                                                transactions
                                                                    .length,
                                                          ),
                                                        ),
                                                      );
                                                    }

                                                    return NotificationListener<
                                                        ScrollNotification>(
                                                      onNotification:
                                                          (ScrollNotification
                                                              scrollInfo) {
                                                        // Sayfa sonuna gelince yeni veriler yükle
                                                        if (scrollInfo.metrics
                                                                .pixels >=
                                                            scrollInfo.metrics
                                                                    .maxScrollExtent -
                                                                200) {
                                                          if (controller.hasMore
                                                                  .value &&
                                                              !controller
                                                                  .isLoadingMore
                                                                  .value) {
                                                            controller
                                                                .loadMoreTransactions();
                                                          }
                                                        }
                                                        return false;
                                                      },
                                                      child: Skeletonizer(
                                                        enabled: controller
                                                            .isTransactionLoading
                                                            .value,
                                                        enableSwitchAnimation:
                                                            true,
                                                        child: CustomScrollView(
                                                          controller:
                                                              scrollController,
                                                          physics:
                                                              const AlwaysScrollableScrollPhysics(),
                                                          slivers: [
                                                            ...slivers,
                                                            // Loading indicator (daha fazla yüklenirken)
                                                            if (controller
                                                                .isLoadingMore
                                                                .value)
                                                              SliverToBoxAdapter(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16.0),
                                                                  child: Center(
                                                                    child: Platform
                                                                            .isIOS
                                                                        ? CupertinoActivityIndicator(
                                                                            color:
                                                                                Theme.of(context).colorScheme.onBackground,
                                                                          )
                                                                        : CircularProgressIndicator(
                                                                            color:
                                                                                Theme.of(context).colorScheme.primary,
                                                                          ),
                                                                  ),
                                                                ),
                                                              ),
                                                            // Alt padding - son itemların görünmesi için
                                                            SliverToBoxAdapter(
                                                              child: SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .padding
                                                                        .bottom +
                                                                    20,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  // Boş transaction durumu
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    final CardController controller = Get.put(CardController());
    // Responsive scaling based on screen height (baseline: 812)
    final double _screenHeight = MediaQuery.of(context).size.height;
    final double _scale = (_screenHeight / 812.0).clamp(0.85, 1.2);
    final double _topPadding = 40.0 * _scale;
    final double _paginationHeight = 17.0 * _scale;
    final double _space20 = 20.0 * _scale;
    final double _titleHeight = 16.0 * _scale;
    final double _balanceHeight = 32.0 * _scale;
    final double _bottomSpace = 5.0 * _scale;
    final double _actionCircleSize = 54.0 * _scale;
    final double _actionTextHeight = 12.0 * _scale;
    final double _dotSmall = 6.0 * _scale;
    final double _dotTall = 16.0 * _scale;
    return Obx(
      () {
        // Loading durumunda veya kart yoksa skeleton göster
        if (controller.isLoading.value || controller.cards.isEmpty) {
          return Skeletonizer(
            enableSwitchAnimation: true,
            enabled: true,
            child: Container(
              height: 220,
              child: Column(
                children: [
                  SizedBox(height: _topPadding),
                  // Skeleton pagination indicators
                  SizedBox(
                    height: _paginationHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: _dotSmall,
                          height: _dotSmall,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: _space20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Skeleton card title
                        Container(
                          width: 80,
                          height: _titleHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Skeleton balance
                        Container(
                          width: 120,
                          height: _balanceHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _bottomSpace),
                  // Skeleton action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Container(
                              width: _actionCircleSize,
                              height: _actionCircleSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 50,
                              height: _actionTextHeight,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
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
          );
        }

        return Container(
          height: 220, // ihtiyaca göre sabit bir yükseklik ver

          child: Column(
            children: [
              SizedBox(height: _topPadding),
              Obx(() => SizedBox(
                    height: _paginationHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.cards.length,
                        (index) => AnimatedContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: _dotSmall,
                          height: controller.selectedCardIndex.value == index
                              ? _dotTall
                              : _dotSmall,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: (controller.selectedCardIndex.value == index)
                                ? AppTheme.black
                                : AppTheme.white,
                          ),
                          duration: const Duration(milliseconds: 300),
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: _space20),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (index) {
                    // Güvenli index kontrolü
                    if (index >= 0 && index < controller.cards.length) {
                      controller.selectedCardIndex.value = index;
                      controller.onCardChanged(
                          index); // Kart değiştiğinde transaction'ları yenile
                    }
                  },
                  itemCount: controller.cards.length,
                  itemBuilder: (context, index) {
                    // Güvenli erişim kontrolü
                    if (index >= controller.cards.length) {
                      return Container(
                        child: Center(
                          child: Text(
                            'card_not_found'.tr,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                        ),
                      );
                    }

                    final card = controller.cards[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0, 0), end: Offset(0, -0.06))
                          .animate(controller.animationController),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            card['title'] ?? 'card'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.darkBodyBG,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ScaleTransition(
                            scale: controller.textSizeAnimation,
                            child: AnimatedFlipCounter(
                              value: (card['balance'] ?? 0.0).toDouble(),
                              fractionDigits: 1,
                              duration: const Duration(milliseconds: 800),
                              textStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkBodyBG,
                              ),
                              suffix: ' ${AppTheme.currencySymbol}',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: _bottomSpace),
              ScaleTransition(
                scale: controller.sizeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(Icons.add, 'balance'.tr, context,
                        onTap: () {
                      final currentCard =
                          controller.cards[controller.selectedCardIndex.value];
                      Get.toNamed(AppRoutes.cardBalance, arguments: {
                        'cardColor': currentCard['color'],
                        'cardTitle': currentCard['title'],
                        'cardIcon': currentCard['icon'],
                        'cardDescription': currentCard['description'],
                        'heroTag': 'card_header',
                      });
                    }),
                    _buildActionButton(Icons.qr_code_scanner, 'pay'.tr, context,
                        onTap: () {
                      Get.toNamed(AppRoutes.qrPayment);
                    }),
                    _buildActionButton(Icons.info_outline, 'info'.tr, context,
                        onTap: () {
                      final currentCard =
                          controller.cards[controller.selectedCardIndex.value];
                      Get.toNamed(AppRoutes.cardInfo, arguments: {
                        'cardColor': currentCard['color'],
                        'cardTitle': currentCard['title'],
                        'cardIcon': currentCard['icon'],
                        'cardDescription': currentCard['description'],
                        'heroTag': 'card_header',
                      });
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardScreenSkeleton(BuildContext context) {
    return Skeletonizer(
      enableSwitchAnimation: true,
      enabled: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300], // Skeleton için placeholder renk
        ),
        child: Stack(
          children: [
            // Background image
            FadeInImage(
              placeholder: AssetImage(ImageAssets.background),
              image: AssetImage(ImageAssets.background),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    // Skeleton Card Header
                    Container(
                      height: 220,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Skeleton pagination indicators
                          SizedBox(
                            height: 17,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (index) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Skeleton card title
                                Container(
                                  width: 80,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Skeleton balance
                                Container(
                                  width: 120,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Skeleton action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      width: 50,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
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
                    // Skeleton Bottom Sheet
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Ekran yüksekliği
                        final screenHeight = constraints.maxHeight;
                        final safeAreaTop = MediaQuery.of(context).padding.top;

                        // Card header yapısı yükseklikleri:
                        // - Top padding: 40
                        // - Pagination: 17
                        // - Spacing: 20
                        // - Bakiye alanı (kart ismi + bakiye): ~48 (13px text + 4px spacing + 28px counter)
                        // - Bottom spacing: 5
                        // - Butonlar: 70 (54px circle + 4px spacing + 12px text)

                        // Bakiye yüksekliği (butonlar hariç)
                        final bakiyeYuksekligi =
                            40.0 + 17.0 + 20.0 + 48.0 + 5.0; // ~130px
                        // Butonlar yüksekliği (circle + spacing + text)
                        final butonlarYuksekligi = 70.0; // 54 + 4 + 12
                        // Butonlar text'in altından boşluk (daha aşağı için artırıldı)
                        final butonlarAltindakiBosluk = 25.0;

                        // Maximum size: Sheet bakiyenin direkt altında (butonlar kaybolmuş)
                        final maxSize = 1.0 -
                            ((bakiyeYuksekligi + safeAreaTop) / screenHeight);

                        // Minimum size: Sheet butonların text'inin altından 15px boşlukla (butonlar görünür)
                        final minSize = 1.0 -
                            ((bakiyeYuksekligi +
                                    butonlarYuksekligi +
                                    butonlarAltindakiBosluk +
                                    safeAreaTop) /
                                screenHeight);

                        // Clamp değerleri (güvenlik için)
                        final clampedMaxSize = maxSize.clamp(0.7, 0.95);
                        final clampedMinSize = minSize.clamp(0.4, 0.85);

                        // Initial size = min size (butonlar görünür başlasın)
                        final initialSize = clampedMinSize;

                        return DraggableScrollableSheet(
                          initialChildSize: initialSize,
                          minChildSize: clampedMinSize,
                          maxChildSize: clampedMaxSize,
                          snap: true,
                          snapSizes: [clampedMinSize, clampedMaxSize],
                          builder: (BuildContext context,
                              ScrollController scrollController) {
                            return Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      top: 12,
                                      bottom: 3,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Skeleton "Transactions" title
                                        Container(
                                          width: 100,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).dividerColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: Theme.of(context).dividerColor,
                                    thickness: .5,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: scrollController,
                                      padding: EdgeInsets.zero,
                                      itemCount: 5,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: _buildTransactionItem(
                                            {
                                              'title': 'Loading...',
                                              'subtitle': 'Loading...',
                                              'amount': '0.00',
                                              'date': 'Loading',
                                              'icon':
                                                  'assets/images/Silver.png',
                                              'isPositive': false,
                                              'type': 'transaction',
                                              'status': 'success',
                                              'category': 'transaction',
                                            },
                                            context,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, BuildContext context,
      {required Function() onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.darkBodyBG,
                size: 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppTheme.darkBodyBG,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      Map<String, dynamic> transaction, BuildContext context) {
    final CardController controller = Get.find<CardController>();
    final transactionId = transaction['transactionId'] as String?;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        child: transaction['type'] == 'transaction'
            ? SizedBox.shrink()
            : Icon(
                Icons.sync,
                color: Theme.of(context).colorScheme.onBackground,
                size: 24,
              ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: transaction['type'] == 'transaction'
              ? Theme.of(context).dividerColor
              : AppTheme.greenColor,
          image: DecorationImage(
            opacity: transaction['type'] == 'transaction' ? 1.0 : 0.0,
            image: AssetImage(transaction['icon']),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        transaction['type'] == 'transaction'
            ? transaction['title']
            : "cashback".tr,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        transaction['subtitle'],
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Theme.of(context).unselectedWidgetColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            transaction['amount'],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: transaction['status'] == 'success'
                  ? AppTheme.greenColor
                  : AppTheme.redColor,
            ),
          ),
          SizedBox(width: 4),
          Text(
            AppTheme.currencySymbol,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: transaction['status'] == 'success'
                  ? AppTheme.greenColor
                  : AppTheme.redColor,
            ),
          ),
        ],
      ),
      onTap: () {
        final category = transaction['category'] as String? ?? 'transaction';

        if (transactionId != null && transactionId.isNotEmpty) {
          controller.loadTransactionDetailAndNavigate(transactionId, category);
        }
      },
    );
  }
}

// Sticky Header Delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String date;
  final Color backgroundColor;

  _StickyHeaderDelegate({
    required this.date,
    required this.backgroundColor,
  });

  @override
  double get minExtent => 40;

  @override
  double get maxExtent => 40;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        date,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return date != oldDelegate.date ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
