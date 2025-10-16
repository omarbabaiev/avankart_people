import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/controllers/home_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/widgets/bottom_sheets/request_for_imtiyaz_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';

class PaymentBottomSheet {
  static void show(BuildContext context) {
    final controller = Get.find<CardController>();

    // Payment bottom sheet açıldığında payment seçimini sıfırla
    controller.selectedPaymentIndex.value = -1;

    // Payment bottom sheet açıldığında kartları yükle - sirketId ile birlikte
    _loadCardsWithSirketId(controller);

    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Obx(() {
                if (!controller.cards.isEmpty && !controller.isLoading.value) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "select_card_to_pay".tr,
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 17,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                } else {
                  return SizedBox(height: 0);
                }
              }),
              SizedBox(height: 20),
              Obx(() {
                // Loading state için skeleton göster

                // Kartlar yüklendiyse göster
                if (controller.cards.isEmpty && !controller.isLoading.value) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            ImageAssets.walletEmpty,
                            height: 80,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'no_card_found'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'no_card_found_description'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Theme.of(context).unselectedWidgetColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: AppTheme.primaryButtonStyle(),
                            onPressed: () {
                              Get.back(); // Payment bottom sheet'i kapat
                              RequestForImtiyazCardBottomSheet.show(context);
                            },
                            child: Text(
                              'muraciet_for_card'.tr,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Obx(
                  () => Skeletonizer(
                    enabled: controller.isLoading.value,
                    enableSwitchAnimation: true,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: controller.isLoading.value
                          ? 3
                          : controller.cards.length,
                      itemBuilder: (context, index) {
                        if (!controller.isLoading.value) {
                          final card = controller.cards[index];
                          return Obx(() {
                            final isSelected =
                                controller.selectedPaymentIndex.value == index;
                            print(
                                '[PAYMENT BOTTOM SHEET] Card $index isSelected: $isSelected');
                            return InkWell(
                                onTap: () {
                                  print(
                                      '[PAYMENT BOTTOM SHEET] Card selected: $index');
                                  print(
                                      '[PAYMENT BOTTOM SHEET] Card title: ${card['title']}');
                                  controller.selectedPaymentIndex.value = index;
                                },
                                child: PaymentCardTitle(
                                  title: card['title'] as String,
                                  balance: (card['balance'] as double)
                                      .toStringAsFixed(2),
                                  icon: card['icon'] as String,
                                  color: card['color'] as Color,
                                  isSelected: isSelected,
                                ));
                          });
                        } else {
                          return PaymentCardTitle(
                            title: 'dsdsdsdsd',
                            balance: '111111',
                            icon: 'gear',
                            color: AppTheme.primaryColor,
                            isSelected: false,
                          );
                        }
                      },
                    ),
                  ),
                );
              }),
              SizedBox(height: 20),
              // Next butonu - sadece kart seçildiğinde aktif
              Obx(() {
                final hasCards = controller.cards.isNotEmpty;
                final isCardSelected =
                    controller.selectedPaymentIndex.value >= 0 &&
                        controller.selectedPaymentIndex.value <
                            controller.cards.length;
                final canProceed =
                    hasCards && isCardSelected && !controller.isLoading.value;

                print('[PAYMENT BOTTOM SHEET] Button state check:');
                print('[PAYMENT BOTTOM SHEET] hasCards: $hasCards');
                print(
                    '[PAYMENT BOTTOM SHEET] selectedPaymentIndex: ${controller.selectedPaymentIndex.value}');
                print('[PAYMENT BOTTOM SHEET] isCardSelected: $isCardSelected');
                print(
                    '[PAYMENT BOTTOM SHEET] isLoading: ${controller.isLoading.value}');
                print('[PAYMENT BOTTOM SHEET] canProceed: $canProceed');

                return Obx(() {
                  if (!controller.cards.isEmpty &&
                      !controller.isLoading.value) {
                    return SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: canProceed
                            ? () {
                                // Seçili kartı QR payment controller'a gönder
                                final selectedCard = controller.cards[
                                    controller.selectedPaymentIndex.value];
                                print(
                                    '[PAYMENT BOTTOM SHEET] Selected card: ${selectedCard['title']}');

                                // QR payment screen'e git
                                Get.toNamed(AppRoutes.qrPayment);
                              }
                            : null,
                        style: AppTheme.primaryButtonStyle(
                          backgroundColor: canProceed
                              ? AppTheme.primaryColor
                              : Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          'next'.tr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: canProceed ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(height: 44);
                  }
                });
              }),
              SizedBox(height: 16),
              Obx(() {
                if (!controller.cards.isEmpty && !controller.isLoading.value) {
                  return TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).unselectedWidgetColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return SizedBox(height: 0);
                }
              }),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // SirketId ile kartları yükle
  static void _loadCardsWithSirketId(CardController controller) {
    try {
      // Her payment butonuna basıldığında kartları yeniden yükle
      // HomeController'dan sirketId'yi al
      String? sirketId;
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        sirketId = homeController.user?.sirketId?.id;
      }

      // Geçici test için statik sirket_id
      if (sirketId == null || sirketId.isEmpty) {
        sirketId = "68a1f8fdecf9649c26454a66"; // Test sirket_id
        print(
            '[PAYMENT BOTTOM SHEET] Using static sirketId for test: $sirketId');
      }

      print('[PAYMENT BOTTOM SHEET] Loading cards with sirketId: $sirketId');

      // Kartları sirketId ile yükle
      controller.loadMyCards(sirketId: sirketId);
    } catch (e) {
      print('[PAYMENT BOTTOM SHEET] Error loading cards: $e');
      // Hata durumunda fallback olarak kartları yükle
      controller.loadMyCards();
    }
  }
}

class PaymentCardTitle extends StatelessWidget {
  final String title;
  final String balance;
  final String icon;
  final Color color;
  final bool isSelected;

  const PaymentCardTitle({
    Key? key,
    required this.title,
    required this.balance,
    required this.icon,
    required this.color,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withOpacity(0.1)
            : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(50),
        border: isSelected
            ? Border.all(color: color, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 20,
                child: CachedNetworkImage(
                  imageUrl: icon,
                  width: 20,
                  height: 20,
                  color: Colors.black,
                  placeholder: (context, url) =>
                      Image.asset(ImageAssets.png_logo, width: 20, height: 20),
                  errorWidget: (context, url, error) =>
                      Image.asset(ImageAssets.png_logo, width: 20, height: 20),
                ),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onBackground
                        : Theme.of(context).unselectedWidgetColor),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "balance".tr,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).unselectedWidgetColor),
              ),
              SizedBox(width: 5),
              Text(
                balance,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              SizedBox(width: 5),
            ],
          )
        ],
      ),
    );
  }
}
