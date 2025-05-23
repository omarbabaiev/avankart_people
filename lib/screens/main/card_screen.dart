import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CardScreen extends GetView<CardController> {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CardController());

    return Obx(
      () => AnimatedContainer(
        decoration: BoxDecoration(
          color: controller.cards[controller.selectedIndex.value]['color'],
          image: DecorationImage(
            image: AssetImage(
                'assets/images/cards_backgrounds/background_food.png'),
            fit: BoxFit.cover,
          ),
        ),
        duration: Duration(milliseconds: 400),
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
                  maxChildSize: 0.8,
                  snap: true,
                  snapSizes: [0.7, 0.8],
                  snapAnimationDuration: const Duration(milliseconds: 200),
                  controller: controller.dragController,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 12, bottom: 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tranzaksiyalar',
                                  style: GoogleFonts.poppins(
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
                              () => ListView.separated(
                                controller: scrollController,
                                itemCount: controller.transactions.length,
                                separatorBuilder: (context, index) => Divider(
                                  indent: 16,
                                  endIndent: 16,
                                  color: Theme.of(context).dividerColor,
                                  thickness: .5,
                                ),
                                itemBuilder: (context, index) {
                                  final transaction =
                                      controller.transactions[index];
                                  if (index == 0 ||
                                      transaction['date'] !=
                                          controller.transactions[index - 1]
                                              ['date']) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 16, bottom: 8),
                                          child: Text(
                                            transaction['date'],
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.black54),
                                          ),
                                        ),
                                        _buildTransactionItem(transaction),
                                      ],
                                    );
                                  }
                                  return _buildTransactionItem(transaction);
                                },
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
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    final CardController controller = Get.put(CardController());
    return Obx(
      () => Container(
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
                        width: controller.selectedIndex.value == index ? 6 : 6,
                        height:
                            controller.selectedIndex.value == index ? 16 : 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: controller.selectedIndex.value == index
                              ? Theme.of(context).colorScheme.onBackground
                              : AppTheme.white,
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
                onPageChanged: (index) =>
                    controller.selectedIndex..value = index,
                itemCount: controller.cards.length,
                itemBuilder: (context, index) {
                  final card = controller.cards[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(0, 0), end: Offset(0, -0.06))
                        .animate(controller.animationController),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          card['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ScaleTransition(
                          scale: controller.textSizeAnimation,
                          child: Text(
                            card['balance'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onBackground,
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
                  _buildActionButton(Icons.add, 'Balans', context,
                      onTap: () {}),
                  _buildActionButton(Icons.qr_code_scanner, 'Ödən', context,
                      onTap: () {
                    Get.toNamed(AppRoutes.qrPayment);
                  }),
                  _buildActionButton(Icons.info_outline, 'Məlu', context,
                      onTap: () {}),
                ],
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
                color: Theme.of(context).colorScheme.onBackground,
                size: 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
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
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        transaction['subtitle'],
        style: GoogleFonts.poppins(
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
            style: GoogleFonts.poppins(
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
