import 'package:avankart_people/screens/main/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/support/support_screen.dart';

import '../utils/vibration_util.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Seçili tab indeksi
  final _selectedIndex = 0.obs;
  // Önceki geçerli tab indeksi (profil, destek vb. sayfalara gidildiğinde kullanılmak üzere)
  final _previousIndex = 0.obs;
  // Özel bir sayfada olup olmadığımızı takip eden değişken
  final _isSpecialPage = false.obs;

  // Geçerli sayfayı tutar
  final _currentPage = Rx<Widget>(const SizedBox());

  // Animasyon controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Bir flag ekleyelim
  bool _isDisposed = false;

  int get selectedIndex => _selectedIndex.value;
  int get previousIndex => _previousIndex.value;
  bool get isSpecialPage => _isSpecialPage.value;
  Widget get currentPage => _currentPage.value;
  Animation<double> get fadeAnimation => _fadeAnimation;

  // Controller başlatıldığında gerekli ayarları yapar
  @override
  void onInit() {
    super.onInit();

    // Animasyon controller'ı başlat
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Fade animasyonunu oluştur
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Başlangıçta ana sayfayı göster
    _changePageWithAnimation(0);
    _isSpecialPage.value = false;
  }

  @override
  void onClose() {
    _isDisposed = true;
    _animationController.dispose();
    super.onClose();
  }

  // Sayfa değiştirme animasyonu
  Future<void> _animatePageChange(Widget newPage) async {
    // Controller dispose edildiyse işlem yapma
    if (_isDisposed) {
      _currentPage.value = newPage;
      return;
    }

    try {
      // Animasyonu sıfırla
      _animationController.reset();

      // Yeni sayfayı ayarla
      _currentPage.value = newPage;

      // Animasyonu başlat
      if (!_isDisposed) {
        await _animationController.forward();
      }
    } catch (e) {
      // Herhangi bir hata olursa sadece sayfayı değiştir
      _currentPage.value = newPage;
    }
  }

  // Bottom navigation bar'da bir sekmeye tıklandığında çağrılır
  void onItemTapped(int index) {
    // Eğer şu anki index aynıysa ve özel sayfada değilsek, hiçbir şey yapma
    if (_selectedIndex.value == index && !_isSpecialPage.value) {
      return;
    }

    // Titreşim efekti
    VibrationUtil.lightVibrate();

    // Seçili tab indexini güncelle
    _selectedIndex.value = index;
    _previousIndex.value = index;
    _isSpecialPage.value = false;

    // İlgili sayfayı yükle ve animasyonu başlat
    _changePageWithAnimation(index);
  }

  // Seçilen indekse göre ilgili sayfayı yükler
  void _changePageWithAnimation(int index) {
    Widget newPage;
    switch (index) {
      case 0:
        newPage = const HomeScreen();
        break;
      case 1:
        newPage = const HomeScreen();
        break;
      case 2:
        newPage = const HomeScreen();
        break;
      default:
        newPage = const HomeScreen();
    }

    _animatePageChange(newPage);
  }

  // Özel sayfalara yönlendirme metotları

  // Profil sayfasına yönlendirme
  // void navigateToProfile() {
  //   // Titreşim efekti
  //   VibrationUtil.lightVibrate();

  //   // Önceki sekme indeksini sakla
  //   _previousIndex.value = _selectedIndex.value;
  //   // Özel sayfada olduğumuzu belirt
  //   _isSpecialPage.value = true;
  //   // Profil sayfasına geç ve animasyonu başlat
  //   _animatePageChange(ProfileScreen());
  // }

  // Destek sayfasına yönlendirme
  void navigateToSupport() {
    // Titreşim efekti
    VibrationUtil.lightVibrate();

    // Önceki sekme indeksini sakla
    _previousIndex.value = _selectedIndex.value;
    // Özel sayfada olduğumuzu belirt
    _isSpecialPage.value = true;
    // Destek sayfasına geç ve animasyonu başlat
    _animatePageChange(const SupportScreen());
  }

  // QR kod oluşturma sayfasına yönlendirme
  // void navigateToCreateQR() {
  //   // Titreşim efekti
  //   VibrationUtil.lightVibrate();

  //   // Önceki sekme indeksini sakla
  //   _previousIndex.value = _selectedIndex.value;
  //   // Özel sayfada olduğumuzu belirt
  //   _isSpecialPage.value = true;
  //   // QR kod sayfasına geç ve animasyonu başlat
  //   _animatePageChange(const CreateQRScreen());
  // }

  // Ana ekranlara geri dönme
  void backToMainScreens() {
    // Titreşim efekti
    VibrationUtil.lightVibrate();

    _isSpecialPage.value = false;
    _selectedIndex.value = _previousIndex.value;
    _changePageWithAnimation(_selectedIndex.value);
  }

  // void navigateToNotifications() {
  //   Get.put(NotificationsController());
  //   Get.toNamed(AppRoutes.notifications);
  // }

  void navigateToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void navigateToNewPassword() {
    Get.toNamed(AppRoutes.newPassword);
  }

  void navigateToChangePassword() {
    Get.toNamed(AppRoutes.changePassword);
  }

  // void navigateToQRDisplay(String amount, String qrData, String qrCode) {
  //   Get.to(
  //     () => QRDisplayScreen(
  //       amount: amount,
  //       qrData: qrData,
  //       qrCode: qrCode,
  //       onTimerComplete: () {
  //         Get.back();
  //       },
  //     ),
  //   );
  // }
}
