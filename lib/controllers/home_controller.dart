import 'package:avankart_people/controllers/profile_controller.dart';
import 'package:avankart_people/controllers/notifications_controller.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/controllers/map_controller.dart';
import 'package:avankart_people/screens/main/card_screen.dart';
import 'package:avankart_people/screens/main/home_screen.dart';
import 'package:avankart_people/screens/main/settings_screen.dart';
import 'package:avankart_people/screens/other/profil_screen.dart';
import 'package:avankart_people/screens/support/support_screen.dart';
import 'package:avankart_people/screens/support/faq_screen.dart';
import 'package:avankart_people/screens/payment/qr_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/vibration_util.dart';
import '../utils/auth_utils.dart';
import '../utils/api_response_parser.dart';
import '../services/auth_service.dart';
import '../services/companies_service.dart';
import '../services/location_service.dart';
import '../models/user_model.dart';
import '../models/companies_response.dart';
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

  // User bilgileri
  final _user = Rxn<UserModel>();
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _showRetryButton = false.obs;
  final _retryMessage = ''.obs;

  // Companies bilgileri
  final _companies = <CompanyInListModel>[].obs;
  final _isLoadingCompanies = false.obs;
  final _companiesError = ''.obs;

  // Search query
  final _currentSearchQuery = ''.obs;

  // Pagination
  final _currentPageCompanies = 1.obs;
  final _totalPagesCompanies = 1.obs;
  final _totalItemsCompanies = 0.obs;
  final _hasMoreDataCompanies = true.obs;

  // Global retry yönetimi
  final _globalShowRetryButton = false.obs;
  final _globalRetryMessage = ''.obs;
  final _globalIsLoading = false.obs;
  final _globalRetryCallback = Rxn<Future<void> Function()>();

  // Hot reload kontrolü
  bool _isHotReload = false;

  // Services
  final AuthService _authService = AuthService();
  final CompaniesService _companiesService = CompaniesService();
  final LocationService _locationService = LocationService();

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
  UserModel? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get showRetryButton => _showRetryButton.value;
  String get retryMessage => _retryMessage.value;

  // Global retry getters
  bool get globalShowRetryButton => _globalShowRetryButton.value;
  String get globalRetryMessage => _globalRetryMessage.value;

  // Search query getter
  String get currentSearchQuery => _currentSearchQuery.value;
  bool get globalIsLoading => _globalIsLoading.value;
  Future<void> Function()? get globalRetryCallback =>
      _globalRetryCallback.value;

  // Companies getters
  List<CompanyInListModel> get companies => _companies;
  bool get isLoadingCompanies => _isLoadingCompanies.value;
  String get companiesError => _companiesError.value;

  // Pagination getters
  int get currentPageCompanies => _currentPageCompanies.value;
  int get totalPagesCompanies => _totalPagesCompanies.value;
  int get totalItemsCompanies => _totalItemsCompanies.value;
  bool get hasMoreDataCompanies => _hasMoreDataCompanies.value;

  // Controller başlatıldığında gerekli ayarları yapar
  @override
  void onInit() {
    super.onInit();

    // İlk açılış kontrolü

    // Animasyon controller'ı her durumda başlat
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Fade animasyonunu oluştur
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Hot reload kontrolü
    if (_user.value != null) {
      _isHotReload = true;
      print('[HOME CONTROLLER] Hot reload detected, skipping data loading');
    }

    // Sadece hot reload değilse ve ilk açılış değilse data yükle

    // Başlangıçta ana sayfayı göster (getProfile request olmadan)
    _changePageWithAnimation(0, skipProfileRequest: true);
    _isSpecialPage.value = false;

    // İlk açılışta önce user data'yı yükle, sonra companies'leri yükle
    if (!_isHotReload) {
      _initializeAppData();
    }
  }

  /// Uygulama başlangıcında data yükleme
  Future<void> _initializeAppData() async {
    try {
      print('[HOME CONTROLLER] Initializing app data...');

      // Önce user data'yı yükle
      await _loadUserData();

      // User data başarılıysa companies'leri yükle
      if (_user.value != null) {
        print(
            '[HOME CONTROLLER] User data loaded successfully, loading companies...');
        await loadCompanies();
      } else {
        print('[HOME CONTROLLER] User data failed to load, skipping companies');
      }

      print('[HOME CONTROLLER] App data initialization completed');
    } catch (e) {
      print('[HOME CONTROLLER] Error during app data initialization: $e');
      // Hata durumunda sadece companies'i yükle
      await loadCompanies();
    }
  }

  /// Retry butonuna basıldığında çağrılır
  Future<void> retryLoadData() async {
    if (_isLoading.value) return; // Çift tıklamayı önle

    _showRetryButton.value = false;
    _retryMessage.value = '';
    await _loadUserData();
  }

  /// Global retry butonuna basıldığında çağrılır
  Future<void> retryGlobalData() async {
    if (_globalIsLoading.value) return; // Çift tıklamayı önle

    _globalIsLoading.value = true;
    _globalShowRetryButton.value = false;
    _globalRetryMessage.value = '';

    try {
      if (_globalRetryCallback.value != null) {
        await _globalRetryCallback.value!();
      }
    } catch (e) {
      print('[HOME CONTROLLER] Global retry failed: $e');
      _globalShowRetryButton.value = true;
      _globalRetryMessage.value = _extractErrorMessage(e);
    } finally {
      _globalIsLoading.value = false;
    }
  }

  /// Global retry dialog'u göster
  void showGlobalRetryDialog(String message, Future<void> Function() callback) {
    _globalShowRetryButton.value = true;
    _globalRetryMessage.value = message;
    _globalRetryCallback.value = callback;
  }

  /// Global retry dialog'u gizle
  void hideGlobalRetryDialog() {
    _globalShowRetryButton.value = false;
    _globalRetryMessage.value = '';
    _globalRetryCallback.value = null;
  }

  /// Merkezi retry metodu - tüm verileri yeniden yükler
  Future<void> retryAllData() async {
    if (_isLoading.value) return; // Çift tıklamayı önle

    _isLoading.value = true;
    _showRetryButton.value = false;
    _retryMessage.value = '';

    try {
      // User data'yı yeniden yükle
      await _loadUserData();

      // Companies'leri de yeniden yükle
      await loadCompanies();

      // Profile data'yı da yeniden yükle
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().getProfile();
      }

      // Notifications'ları da yenile
      if (Get.isRegistered<NotificationsController>()) {
        await Get.find<NotificationsController>().refreshNotifications();
      }

      print('[HOME CONTROLLER] All data retry completed successfully');
    } catch (e) {
      print('[HOME CONTROLLER] Retry failed: $e');
      _showRetryButton.value = true;
      _retryMessage.value = _extractErrorMessage(e);
    } finally {
      _isLoading.value = false;
    }
  }

  /// User data'yı yenile (pull to refresh için)
  Future<void> refreshUserData() async {
    if (_isRefreshing.value) return; // Çift tıklamayı önle

    _isRefreshing.value = true;
    try {
      await _loadUserData();
      await loadCompanies(); // Companies'leri de yenile

      // Notifications'ları da yenile
      if (Get.isRegistered<NotificationsController>()) {
        await Get.find<NotificationsController>().refreshNotifications();
      }
    } finally {
      _isRefreshing.value = false;
    }
  }

  /// Companies'leri yükle
  Future<void> loadCompanies({
    String? filterType,
    String? search,
    String? cardId,
    List<String>? muessiseCategory,
    int page = 1,
    int limit = 10,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _currentPageCompanies.value = 1;
      _hasMoreDataCompanies.value = true;
    }

    if (!_hasMoreDataCompanies.value && !isRefresh) return;

    try {
      _isLoadingCompanies.value = true;
      _companiesError.value = '';

      print(
          '[HOME CONTROLLER] Loading companies... Page: ${_currentPageCompanies.value}');

      // Kullanıcının konumunu al
      final position = await _locationService.getCurrentLocation();
      double? lat = position?.latitude;
      double? lng = position?.longitude;

      print('[HOME CONTROLLER] Location: lat=$lat, lng=$lng');

      final response = await _companiesService.getCompanies(
        lat: lat,
        lng: lng,
        filterType: filterType,
        search: search,
        cardId: cardId,
        muessiseCategory: muessiseCategory,
        page: _currentPageCompanies.value,
        limit: limit,
      );

      if (response != null) {
        if (isRefresh) {
          _companies.value = response.muessises;
        } else {
          _companies.addAll(response.muessises);
        }

        // Pagination bilgilerini güncelle
        _totalPagesCompanies.value = response.totalPages;
        _totalItemsCompanies.value = response.total;
        _hasMoreDataCompanies.value =
            _currentPageCompanies.value < _totalPagesCompanies.value;

        if (_hasMoreDataCompanies.value) {
          _currentPageCompanies.value++;
        }

        print(
            '[HOME CONTROLLER] Companies loaded successfully: ${response.muessises.length} items, Total: ${_totalItemsCompanies.value}');
        update();
      } else {
        _companiesError.value = 'failed_to_load_companies'.tr;
        print('[HOME CONTROLLER] Failed to load companies - response is null');
      }
    } catch (e) {
      _companiesError.value = _extractErrorMessage(e);
      print('[HOME CONTROLLER] Error loading companies: $e');
    } finally {
      _isLoadingCompanies.value = false;
    }
  }

  /// Companies'leri yenile (pull to refresh için)
  Future<void> refreshCompanies() async {
    await loadCompanies(isRefresh: true);
  }

  /// Load more data for pagination
  Future<void> loadMoreCompanies() async {
    if (!_isLoadingCompanies.value && _hasMoreDataCompanies.value) {
      await loadCompanies();
    }
  }

  // User bilgilerini yükle
  Future<void> _loadUserData() async {
    try {
      _isLoading.value = true;
      _showRetryButton.value = false;
      _retryMessage.value = '';
      print('[HOME CONTROLLER] Loading user data...');

      final homeResponse = await _authService.home();

      // Eğer null döndüyse (token geçersiz veya logout gerekli), force logout yap
      if (homeResponse == null) {
        print('[HOME CONTROLLER] Token invalid or logout required');
        await AuthUtils.forceLogout();
        return;
      }

      // Check if logout is required (status 2) - UserModel'den status kontrol et
      if (homeResponse.user != null && homeResponse.user!.status == 2) {
        print(
            '[HOME CONTROLLER] Status 2 detected in user model, force logging out user');
        await AuthUtils.forceLogout();
        return;
      }

      print('[HOME CONTROLLER] ===== FULL HOME RESPONSE =====');
      print('[HOME CONTROLLER] Success: ${homeResponse.success}');
      print('[HOME CONTROLLER] Message: ${homeResponse.message}');
      print('[HOME CONTROLLER] Token: ${homeResponse.token}');

      if (homeResponse.user != null) {
        // print('[HOME CONTROLLER] ===== USER DETAILS =====');
        // print('[HOME CONTROLLER] ID: ${homeResponse.user?.id}');
        // print('[HOME CONTROLLER] Name: ${homeResponse.user?.name}');
        // print('[HOME CONTROLLER] Surname: ${homeResponse.user?.surname}');
        // print('[HOME CONTROLLER] People ID: ${homeResponse.user?.peopleId}');
        // print(
        //     '[HOME CONTROLLER] Sirket Name: ${homeResponse.user?.sirketId?.sirketName}');

        // print('[HOME CONTROLLER] Email: ${homeResponse.user?.email}');

        // print('[HOME CONTROLLER] Phone: ${homeResponse.user?.phone}');
        // print('[HOME CONTROLLER] Birth Date: ${homeResponse.user?.birthDate}');
        // print(
        //     '[HOME CONTROLLER] Total QR Codes: ${homeResponse.user?.totalQrCodes}');
        // print(
        //     '[HOME CONTROLLER] Today QR Codes: ${homeResponse.user?.todayQrCodes}');
        // print('[HOME CONTROLLER] Status: ${homeResponse.user?.status}');
        // print('[HOME CONTROLLER] ===== END USER DETAILS =====');
      } else {
        print('[HOME CONTROLLER] User is null!');
      }

      print('[HOME CONTROLLER] ===== END FULL HOME RESPONSE =====');

      if (homeResponse.success == true && homeResponse.user != null) {
        _user.value = homeResponse.user;
        print('[HOME CONTROLLER] User data loaded successfully');
        // UI'ı güncellemek için update() çağır
        update();
      } else {
        print('[HOME CONTROLLER] Failed to load user data');
        _showRetryButton.value = true;
        _retryMessage.value = 'failed_to_load_data'.tr;
      }
    } catch (e) {
      print('[HOME CONTROLLER] Error loading user data: $e');
      // AuthService'den gelen tüm hatalar retry edilebilir (sadece token geçersiz ve status 2 logout yapar)
      print('[HOME CONTROLLER] Showing retry button for error');
      _showRetryButton.value = true;
      _retryMessage.value = _extractErrorMessage(e);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Hata mesajını çıkar
  String _extractErrorMessage(dynamic error) {
    return ApiResponseParser.parseDioError(error);
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
      // Eğer home sekmesindeyse ve aynı sekmedeyse, yine de data'yı yenile (hot reload değilse)
      if (index == 0 && !_isHotReload) {
        refreshUserData();
      }
      return;
    }

    // Titreşim efekti
    VibrationUtil.lightVibrate();

    // User navigation yaptığında hot reload flag'ini reset et
    _isHotReload = false;

    // Seçili tab indexini güncelle
    _selectedIndex.value = index;
    _previousIndex.value = index;
    _isSpecialPage.value = false;

    // İlgili sayfayı yükle ve animasyonu başlat
    _changePageWithAnimation(index);

    // Home sekmesine tıklandığında profile request AT
    if (index == 0) {
      _loadUserData();
    }

    // My Cards sekmesine tıklandığında kartları yükle
    if (index == 2) {
      _loadCardData();
    }
  }

  // My Cards sekmesine tıklandığında CardController'ı başlat ve API request yap
  void _loadCardData() {
    try {
      // CardController'ı al veya oluştur
      final cardController = Get.find<CardController>();

      // Debug: User ve sirket bilgilerini kontrol et
      print('[HOME CONTROLLER] ===== CARD DATA DEBUG =====');
      print('[HOME CONTROLLER] User: ${_user.value != null}');
      if (_user.value != null) {
        print('[HOME CONTROLLER] User ID: ${_user.value!.id}');
        print('[HOME CONTROLLER] User Name: ${_user.value!.name}');
        print('[HOME CONTROLLER] SirketId: ${_user.value!.sirketId != null}');
        if (_user.value!.sirketId != null) {
          print('[HOME CONTROLLER] Sirket ID: ${_user.value!.sirketId!.id}');
          print(
              '[HOME CONTROLLER] Sirket Name: ${_user.value!.sirketId!.sirketName}');
        }
      }
      print('[HOME CONTROLLER] ===========================');

      // Her My Cards açıldığında kartları yeniden yükle
      // User'dan sirket_id'yi al
      String? sirketId;
      if (_user.value?.sirketId != null) {
        sirketId = _user.value!.sirketId!.id;
      }

      // Geçici test için statik sirket_id
      if (sirketId == null || sirketId.isEmpty) {
        sirketId = "68a1f8fdecf9649c26454a66"; // Test sirket_id
        print('[HOME CONTROLLER] Using static sirketId for test: $sirketId');
      }

      print('[HOME CONTROLLER] Final sirketId for API: $sirketId');

      // API request'i yap
      cardController.loadMyCards(sirketId: sirketId);
    } catch (e) {
      print('[HOME CONTROLLER] Error loading card data: $e');
      // CardController bulunamazsa oluştur
      final cardController = Get.put(CardController());

      // User'dan sirket_id'yi al
      String? sirketId;
      if (_user.value?.sirketId != null) {
        sirketId = _user.value!.sirketId!.id;
      }

      // Geçici test için statik sirket_id
      if (sirketId == null || sirketId.isEmpty) {
        sirketId = "68a1f8fdecf9649c26454a66"; // Test sirket_id
        print(
            '[HOME CONTROLLER] Using static sirketId for test (fallback): $sirketId');
      }

      print('[HOME CONTROLLER] Fallback sirketId for API: $sirketId');

      // API request'i yap
      cardController.loadMyCards(sirketId: sirketId);
    }
  }

  // Seçilen indekse göre ilgili sayfayı yükler
  void _changePageWithAnimation(int index, {bool skipProfileRequest = false}) {
    Widget newPage;
    switch (index) {
      case 0:
        newPage = HomeScreen();
        // Home screen'e geçerken profile request AT
        if (!skipProfileRequest && !_isHotReload) {
          _loadUserData();
        }
        break;
      case 1:
        // Map screen - profile request ATMA
        newPage = Container(); // Map screen placeholder
        // MapController'ı güncelle
        _updateMapController();
        break;
      case 2:
        // My Cards screen - profile request ATMA
        newPage = const CardScreen();
        break;
      case 3:
        newPage = const SettingsScreen();
        // Sadece settings screen'ine geçerken profile data'yı yenile (hot reload değilse)
        if (!_isHotReload && Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().getProfile();
        }
        break;
      default:
        newPage = HomeScreen();
    }

    _animatePageChange(newPage);
  }

  // Özel sayfalara yönlendirme metotları

  // Profil sayfasına yönlendirme
  void navigateToProfile() {
    // Titreşim efekti
    VibrationUtil.lightVibrate();

    // User navigation yaptığında hot reload flag'ini reset et
    _isHotReload = false;

    // Önceki sekme indeksini sakla
    _previousIndex.value = _selectedIndex.value;
    // Özel sayfada olduğumuzu belirt
    _isSpecialPage.value = true;
    // Profil sayfasına geç ve animasyonu başlat
    _animatePageChange(ProfilScreen());
  }

  // Destek sayfasına yönlendirme
  void navigateToSupport() {
    // Titreşim efekti
    VibrationUtil.lightVibrate();

    // User navigation yaptığında hot reload flag'ini reset et
    _isHotReload = false;

    // Önceki sekme indeksini sakla
    _previousIndex.value = _selectedIndex.value;
    // Özel sayfada olduğumuzu belirt
    _isSpecialPage.value = true;
    // Destek sayfasına geç ve animasyonu başlat
    _animatePageChange(const SupportScreen());
  }

  // FAQ sayfasına yönlendirme
  void navigateToFAQ() {
    // Titreşim efekti
    VibrationUtil.lightVibrate();

    // User navigation yaptığında hot reload flag'ini reset et
    _isHotReload = false;

    // Önceki sekme indeksini sakla
    _previousIndex.value = _selectedIndex.value;
    // Özel sayfada olduğumuzu belirt
    _isSpecialPage.value = true;
    // FAQ sayfasına geç ve animasyonu başlat
    _animatePageChange(const FAQScreen());
  }

  // QR ödeme sayfasına yönlendirme
  void navigateToQRPayment() {
    // Titreşim efekti
    VibrationUtil.lightVibrate();

    // User navigation yaptığında hot reload flag'ini reset et
    _isHotReload = false;

    // Önceki sekme indeksini sakla
    _previousIndex.value = _selectedIndex.value;
    // Özel sayfada olduğumuzu belirt
    _isSpecialPage.value = true;
    // QR ödeme sayfasına geç ve animasyonu başlat
    _animatePageChange(const QrPaymentScreen());
  }

  // Ana ekranlara geri dönme
  void backToMainScreens() {
    // Titreşim efekti
    VibrationUtil.lightVibrate();

    _isSpecialPage.value = false;
    _selectedIndex.value = _previousIndex.value;
    _changePageWithAnimation(_selectedIndex.value);
  }

  void navigateToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void navigateToNewPassword() {
    Get.toNamed(AppRoutes.newPassword);
  }

  void navigateToChangePassword() {
    Get.toNamed(AppRoutes.changePassword);
  }

  void navigateToQRDisplay(String amount, String qrData, String qrCode,
      {String? qrImageUrl}) {
    Get.toNamed(AppRoutes.qrDisplay);
  }

  // MapController'ı güncelle
  void _updateMapController() {
    try {
      if (Get.isRegistered<MapController>()) {
        final mapController = Get.find<MapController>();
        // Async fonksiyonu fire-and-forget olarak çağır
        mapController.refreshCompanies();
      }
    } catch (e) {
      print('[HOME CONTROLLER] MapController güncellenirken hata: $e');
    }
  }

  // Search results'ı home screen'de göster
  void showSearchResults(List<CompanyInListModel> searchResults,
      {String? searchQuery}) {
    print('[HOME CONTROLLER] Showing ${searchResults.length} search results');
    _companies.value = searchResults;
    _isLoadingCompanies.value = false;
    _companiesError.value = '';
    if (searchQuery != null) {
      _currentSearchQuery.value = searchQuery;
    }
    print('[HOME CONTROLLER] Search results assigned to companies list');
  }

  // Search'i temizle ve normal companies'leri yükle
  void clearSearchResults() {
    print('[HOME CONTROLLER] clearSearchResults called');
    _currentSearchQuery.value = '';
    print(
        '[HOME CONTROLLER] Calling loadCompanies() to reload normal companies');
    loadCompanies(isRefresh: true);
  }
}
