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

class CardScreen extends GetView<CardController> {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CardController());

    return Obx(
      () {
        // Loading durumunda loading göster
        if (controller.isLoading.value) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .scaffoldBackgroundColor, // Varsayılan loading rengi
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          );
        }

        // Kart yoksa uygun mesaj göster
        if (controller.cards.isEmpty && !controller.isLoading.value) {
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
        print('[CARD SCREEN] ===== CARD COLOR DEBUG =====');
        print(
            '[CARD SCREEN] Selected Index: ${controller.selectedCardIndex.value}');
        print('[CARD SCREEN] Card Title: ${currentCard['title']}');
        print('[CARD SCREEN] Card Color: $cardColor');
        print('[CARD SCREEN] Color Type: ${cardColor.runtimeType}');
        print('[CARD SCREEN] ============================');

        return Obx(
          () => Animate(
            effects: [
              FadeEffect(duration: 500.ms),
            ],
            child: AnimatedContainer(
              color: controller.cards[controller.selectedCardIndex.value]
                  ['color'],
              duration: Duration(milliseconds: 700),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      // Üst kısım - Kart Bilgileri
                      _buildCardHeader(context),
                      // Alt kısım - İşlemler Listesi (DraggableScrollableSheet)
                      DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.7,
                        maxChildSize: 0.9,
                        snap: true,
                        snapSizes: [0.7, 0.9],
                        snapAnimationDuration:
                            const Duration(milliseconds: 1000),
                        controller: controller.dragController,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 16, right: 16, top: 12, bottom: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'transactions'.tr,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.file_download_outlined,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.analytics_outlined,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                    color: Theme.of(context).dividerColor,
                                    thickness: .5),
                                Expanded(
                                  child: Obx(
                                    () {
                                      if (controller.hasTransactions.value ==
                                              false &&
                                          controller
                                                  .isTransactionLoading.value ==
                                              false) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.receipt_long_outlined,
                                                size: 64,
                                                color: Colors.grey[400],
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                controller
                                                    .emptyTransactionMessage
                                                    .value,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'new_transactions_here'.tr,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[500],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 80),
                                            ],
                                          ),
                                        );
                                      } else if (controller
                                          .isTransactionLoading.value) {
                                        // Transaction listesi
                                        return Skeletonizer(
                                          enableSwitchAnimation: true,
                                          enabled: true,
                                          child: ListView.builder(
                                            controller: scrollController,
                                            itemCount: 5, // 5 skeleton item
                                            itemBuilder: (context, index) {
                                              return _buildTransactionItem({
                                                'title': 'İşlemeweewew',
                                                'subtitle':
                                                    'Genelewewewewewewewe',
                                                'amount': '0.ee',
                                                'date': '0.ee',
                                                'icon':
                                                    'assets/images/Silver.png',
                                                'isPositive': false,
                                              });
                                            },
                                          ),
                                        );
                                      } else {
                                        return Skeletonizer(
                                          enabled: controller
                                              .isTransactionLoading.value,
                                          enableSwitchAnimation: true,
                                          child: ListView.separated(
                                            controller: scrollController,
                                            itemCount:
                                                controller.transactions.length,
                                            separatorBuilder:
                                                (context, index) => Divider(
                                              indent: 16,
                                              endIndent: 16,
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              thickness: .5,
                                            ),
                                            itemBuilder: (context, index) {
                                              final transaction = controller
                                                  .transactions[index];
                                              if (index == 0 ||
                                                  transaction['date'] !=
                                                      controller.transactions[
                                                          index - 1]['date']) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 16, bottom: 8),
                                                      child: Text(
                                                        transaction['date'],
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black54),
                                                      ),
                                                    ),
                                                    _buildTransactionItem(
                                                        transaction),
                                                  ],
                                                );
                                              }
                                              return _buildTransactionItem(
                                                  transaction);
                                            },
                                          ),
                                        );
                                      }
                                      // Boş transaction durumu
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    final CardController controller = Get.put(CardController());
    return Obx(
      () {
        // Loading durumunda veya kart yoksa boş container döndür
        if (controller.isLoading.value || controller.cards.isEmpty) {
          return Container(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        return Container(
          height: 220, // ihtiyaca göre sabit bir yükseklik ver

          child: Column(
            children: [
              const SizedBox(height: 40),
              Obx(() => SizedBox(
                    height: 17,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.cards.length,
                        (index) => AnimatedContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: controller.selectedCardIndex.value == index
                              ? 16
                              : 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: controller.selectedCardIndex.value == index
                                ? Theme.of(context).colorScheme.onBackground
                                : Theme.of(context).scaffoldBackgroundColor,
                          ),
                          duration: const Duration(milliseconds: 300),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
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
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ScaleTransition(
                            scale: controller.textSizeAnimation,
                            child: Text(
                              (card['balance'] ?? 0.0).toString(),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              ScaleTransition(
                scale: controller.sizeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(Icons.add, 'balance'.tr, context,
                        onTap: () {}),
                    _buildActionButton(Icons.qr_code_scanner, 'pay'.tr, context,
                        onTap: () {
                      Get.toNamed(AppRoutes.qrPayment);
                    }),
                    _buildActionButton(Icons.info_outline, 'info'.tr, context,
                        onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
                color: Theme.of(context).colorScheme.onBackground,
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
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(transaction['icon']),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        transaction['title'],
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        transaction['subtitle'],
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.black54,
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
              color: transaction['isPositive']
                  ? Colors.green
                  : Theme.of(Get.context!).colorScheme.onBackground,
            ),
          ),
          SizedBox(width: 4),
          Image.asset(
            ImageAssets.manat,
            width: 10,
            height: 10,
            color: transaction['isPositive']
                ? AppTheme.greenColor
                : Theme.of(Get.context!).colorScheme.onBackground,
          ),
        ],
      ),
    );
  }
}
