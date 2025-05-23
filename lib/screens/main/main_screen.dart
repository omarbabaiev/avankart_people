import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/controllers/home_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/screens/initial/initial_card_select_screen.dart';
import 'package:avankart_people/screens/main/home_screen.dart';
import 'package:avankart_people/screens/main/settings_screen.dart';
import 'package:avankart_people/screens/main/card_screen.dart';
import 'package:avankart_people/screens/payment/qr_payment_screen.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key}) {
    // HomeController'ı sınıf oluşturulduğunda başlat
    // permanent: true parametresi ekleyerek controller'ın kalıcı olmasını sağlayalım
    Get.put(HomeController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return WillPopScope(
      // Geri tuşuna basıldığında
      onWillPop: () async {
        // Eğer özel bir sayfadaysak ana sayfalara dön
        if (controller.isSpecialPage) {
          controller.backToMainScreens();
          return false; // Navigasyonu engelle, kendi işlemimizi yapıyoruz
        }
        // Ana sayfalardan birindeyse uygulamadan çık
        return true;
      },
      child: Scaffold(
        extendBody: true,
        // Obx ile controller.currentPage değiştiğinde UI'ı otomatik güncelle
        body: Obx(
          () => FadeTransition(
            opacity: controller.fadeAnimation,
            child: IndexedStack(
              index: controller.selectedIndex,
              children: [
                HomeScreen(),
                Container(child: Center(child: Text('Xəritə'))),
                CardScreen(),
                SettingsScreen()
              ],
            ),
          ),
        ),

        // FAB olarak QR kod butonu
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          onPressed: () {
            _showPaymentBottomSheet(context);
          },
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0.5,
          child: Image.asset(
            ImageAssets.scan,
            width: 24,
            height: 24,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // Bottom navigation bar
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 0.5,
          height: 83,
          notchMargin: 4,
          shape: const CircularNotchedRectangle(),
          color: Theme.of(context).colorScheme.onPrimary,
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sol taraftaki ikonlar
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        context: context,
                        icon: ImageAssets.homeInactive,
                        activeIcon: ImageAssets.homeActive,
                        label: 'Əsas səhifə',
                        index: 0,
                        selected: controller.isSpecialPage
                            ? controller.previousIndex == 0
                            : controller.selectedIndex == 0,
                        onTap: () => controller.onItemTapped(0),
                      ),
                      _buildNavItem(
                        context: context,
                        icon: ImageAssets.mapTrifoldInactive,
                        activeIcon: ImageAssets.mapTrifold,
                        label: 'Xəritə',
                        index: 1,
                        selected: controller.isSpecialPage
                            ? controller.previousIndex == 1
                            : controller.selectedIndex == 1,
                        onTap: () => controller.onItemTapped(1),
                      ),
                    ],
                  ),
                ),

                // Orta boşluk (FAB için)

                // Sağ taraftaki ikonlar
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        context: context,
                        icon: ImageAssets.walletInactive,
                        activeIcon: ImageAssets.wallet,
                        label: 'Kartlarım',
                        index: 2,
                        selected: controller.isSpecialPage
                            ? controller.previousIndex == 2
                            : controller.selectedIndex == 2,
                        onTap: () => controller.onItemTapped(2),
                      ),
                      _buildNavItem(
                        context: context,
                        icon: ImageAssets.settingsInactive,
                        activeIcon: ImageAssets.settingsActive,
                        label: 'Tənzimləmələr',
                        index: 3,
                        selected: controller.isSpecialPage
                            ? controller.previousIndex == 3
                            : controller.selectedIndex == 3,
                        onTap: () => controller.onItemTapped(3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation bar öğeleri için yardımcı metod
  Widget _buildNavItem({
    required BuildContext context,
    required String icon,
    required String activeIcon,
    required String label,
    required int index,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color selectedColor = Theme.of(context).colorScheme.onBackground;
    final Color unselectedColor =
        Theme.of(context).colorScheme.onBackground.withOpacity(.7);

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              selected ? activeIcon : icon,
              color: selected ? selectedColor : unselectedColor,
              width: 24,
              height: 24,
            ),
            Text(
              label,
              style: TextStyle(
                color: selected ? selectedColor : unselectedColor,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentBottomSheet(BuildContext context) {
    final controller = Get.find<CardController>();
    context.showPerformantBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ödəniş edəcəyiniz kartı seçin",
                  style: GoogleFonts.poppins(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 20),
              Obx(() {
                // Seçili indeksi anlık olarak görmek için bir print ve Text ekleyelim
                print(
                    "Bottom Sheet Obx rebuilding. Selected Index: ${controller.selectedIndex.value}");
                return SizedBox(
                  child: Skeletonizer(
                    enableSwitchAnimation: true,
                    enabled: controller.cards.isEmpty,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: controller.cards.length,
                      itemBuilder: (context, index) {
                        final card = controller.cards[index];
                        final isSelected =
                            controller.selectedIndex.value == index;
                        return InkWell(
                            onTap: () => controller.selectedIndex.value = index,
                            child: _buildCardTitle(
                              context,
                              card['title'] as String,
                              (card['balance'] as double).toStringAsFixed(2),
                              card['icon'] as String,
                              card['color'] as Color,
                              isSelected,
                            ));
                      },
                    ),
                  ),
                );
              }),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.qrPayment);
                  },
                  style: AppTheme.primaryButtonStyle(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(
                    'next'.tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'cancel'.tr,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardTitle(BuildContext context, String title, String balance,
      String icon, Color color, bool isSelected) {
    return Container(
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
                child: Image.asset(
                  icon,
                  width: 20,
                  height: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
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
                "Balans:",
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).unselectedWidgetColor),
              ),
              SizedBox(width: 5),
              Text(
                balance,
                style: GoogleFonts.poppins(
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
