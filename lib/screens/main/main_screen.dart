import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/controllers/home_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/screens/initial/initial_card_select_screen.dart';
import 'package:avankart_people/screens/main/home_screen.dart';
import 'package:avankart_people/screens/main/settings_screen.dart';
import 'package:avankart_people/screens/main/card_screen.dart';
import 'package:avankart_people/screens/main/map_screen.dart';
import 'package:avankart_people/screens/payment/qr_payment_screen.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:avankart_people/widgets/payment/payment_bottom_sheet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late HomeController controller;
  DateTime? _lastBackPressTime;
  bool _showingExitToast = false;

  @override
  void initState() {
    super.initState();
    // HomeController'ı sınıf oluşturulduğunda başlat
    // permanent: true parametresi ekleyerek controller'ın kalıcı olmasını sağlayalım
    controller = Get.put(HomeController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).colorScheme.onBackground;
    final Color unselectedColor =
        Theme.of(context).colorScheme.onBackground.withOpacity(.7);

    return WillPopScope(
      // Geri tuşuna basıldığında
      onWillPop: () async {
        // Eğer özel bir sayfadaysak ana sayfalara dön
        if (controller.isSpecialPage) {
          controller.backToMainScreens();
          return false; // Navigasyonu engelle, kendi işlemimizi yapıyoruz
        }

        // Ana sayfalardan birindeyse geri tuşu işlevselliğini uygula
        return _handleBackPress();
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
                MapScreen(),
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
            PaymentBottomSheet.show(context);
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
          elevation: 0.8,
          height: 83,
          notchMargin: 4,
          shape: AutomaticNotchedShape(
            RoundedRectangleBorder(),
            StadiumBorder(),
          ),
          color: Theme.of(context).colorScheme.onPrimary,
          child: Obx(
            () => BottomNavigationBar(
              currentIndex: controller.selectedIndex,
              onTap: (index) {
                controller.onItemTapped(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,
              selectedLabelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                    activeIcon: Image.asset(ImageAssets.homeActive,
                        color: Theme.of(context).colorScheme.onBackground,
                        height: 24,
                        width: 24),
                    icon: Image.asset(ImageAssets.homeInactive,
                        height: 24, width: 24),
                    label: 'home'.tr),
                BottomNavigationBarItem(
                    activeIcon: Image.asset(ImageAssets.mapTrifold,
                        color: Theme.of(context).colorScheme.onBackground,
                        height: 24,
                        width: 24),
                    icon: Image.asset(ImageAssets.mapTrifoldInactive,
                        height: 24, width: 24),
                    label: 'map'.tr),
                BottomNavigationBarItem(
                    activeIcon: Image.asset(
                      ImageAssets.wallet,
                      height: 24,
                      width: 24,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    icon: Image.asset(ImageAssets.walletInactive,
                        height: 24, width: 24),
                    label: 'my_cards'.tr),
                BottomNavigationBarItem(
                    activeIcon: Image.asset(
                      ImageAssets.settingsActive,
                      height: 24,
                      width: 24,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    icon: Image.asset(ImageAssets.settingsInactive,
                        height: 24, width: 24),
                    label: 'settings'.tr),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Geri tuşu işlevselliği
  Future<bool> _handleBackPress() async {
    // Eğer Home sayfasında değilsek, Home sayfasına dön
    if (controller.selectedIndex != 0) {
      controller.onItemTapped(0);
      return false; // Navigasyonu engelle
    }

    // Home sayfasındaysak, çıkış işlevselliğini uygula
    DateTime now = DateTime.now();

    // İlk kez basıldıysa veya 2 saniyeden fazla geçtiyse
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!).inSeconds > 2) {
      _lastBackPressTime = now;

      // Toast mesajı göster
      if (!_showingExitToast) {
        _showingExitToast = true;
        Fluttertoast.showToast(
          msg: "exit_confirmation".tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.onBackground,
          textColor: Theme.of(context).scaffoldBackgroundColor,
          fontSize: 16.0,
        );

        // 2 saniye sonra toast flag'ini sıfırla
        Timer(const Duration(seconds: 2), () {
          _showingExitToast = false;
        });
      }

      return false; // Navigasyonu engelle
    }

    // İkinci kez basıldıysa uygulamadan çık
    return true;
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            splashColor: AppTheme.primaryColor.withOpacity(.4),
            onTap: onTap,
            child: Image.asset(
              selected ? activeIcon : icon,
              color: selected ? selectedColor : unselectedColor,
              width: 24,
              height: 24,
            ),
          ),
          SizedBox(height: 4),
          InkWell(
            splashColor: Colors.transparent,
            onTap: onTap,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? selectedColor : unselectedColor,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
