import 'package:avankart_people/controllers/profile_controller.dart';
import 'package:avankart_people/controllers/notifications_controller.dart';
import 'package:avankart_people/controllers/card_controller.dart';
import 'package:avankart_people/controllers/map_controller.dart';
import 'package:avankart_people/controllers/filter_controller.dart';
import 'package:avankart_people/screens/main/card_screen.dart';
import 'package:avankart_people/screens/main/home_screen.dart';
import 'package:avankart_people/screens/main/settings_screen.dart';
import 'package:avankart_people/screens/other/profil_screen.dart';
import 'package:avankart_people/screens/support/support_screen.dart';
import 'package:avankart_people/screens/support/faq_screen.dart';
import 'package:avankart_people/screens/payment/qr_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  final GetStorage _storage = GetStorage();
  
  // Filter type
  final _filterType = 'name'.obs; // Default: 'name' (ada göre), 'distance' (distans'a göre)
  static const String _filterTypeKey = 'home_filter_type';

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
  
  // Filter getter
  String get filterType => _filterType.value;

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
      debugPrint(
          '[HOME CONTROLLER] Hot reload detected, skipping data loading');
    }

    // Sadece hot reload değilse ve ilk açılış değilse data yükle

    // Başlangıçta ana sayfayı göster (getProfile request olmadan)
    // Main screen açıldığında her zaman ilk sayfaya (index 0) git
    _selectedIndex.value = 0;
    _previousIndex.value = 0;
    _changePageWithAnimation(0, skipProfileRequest: true);
    _isSpecialPage.value = false;

    // Load filter type from storage
    _loadFilterType();

    // İlk açılışta önce user data'yı yükle, sonra companies'leri yükle
    if (!_isHotReload) {
      _initializeAppData();
    }
  }

  /// Uygulama başlangıcında data yükleme
  Future<void> _initializeAppData() async {
    try {
      debugPrint('[HOME CONTROLLER] Initializing app data...');

      // Önce user data'yı yükle
      await _loadUserData();

      // User data başarılıysa companies'leri yükle
      if (_user.value != null) {
        debugPrint(
            '[HOME CONTROLLER] User data loaded successfully, loading companies...');
        await loadCompanies();
      } else {
        debugPrint(
            '[HOME CONTROLLER] User data failed to load, skipping companies');
      }

      debugPrint('[HOME CONTROLLER] App data initialization completed');
    } catch (e) {
      debugPrint('[HOME CONTROLLER] Error during app data initialization: $e');
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
      debugPrint('[HOME CONTROLLER] Global retry failed: $e');
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

      debugPrint('[HOME CONTROLLER] All data retry completed successfully');
    } catch (e) {
      debugPrint('[HOME CONTROLLER] Retry failed: $e');
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
    List<String>? cards,
    List<String>? muessiseCategory,
    int page = 1,
    int limit = 20,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _currentPageCompanies.value = 1;
      _hasMoreDataCompanies.value = true;
      _companies.value = []; // Refresh'te listeyi temizle
    }

    if (!_hasMoreDataCompanies.value && !isRefresh) {
      debugPrint('[HOME CONTROLLER] No more data to load');
      return;
    }

    if (_isLoadingCompanies.value) {
      debugPrint('[HOME CONTROLLER] Already loading, skipping');
      return;
    }

    try {
      _isLoadingCompanies.value = true;
      _companiesError.value = '';

      debugPrint(
          '[HOME CONTROLLER] Loading companies... Page: ${_currentPageCompanies.value}, Limit: $limit');

      // Kullanıcının konumunu al
      final position = await _locationService.getCurrentLocation();
      double? lat = position?.latitude;
      double? lng = position?.longitude;

      debugPrint('[HOME CONTROLLER] Location: lat=$lat, lng=$lng');

      // Use saved filter type if filterType is not provided
      final finalFilterType = filterType ?? _filterType.value;
      
      // Filter controller'dan seçilen kart ID'lerini al
      List<String>? selectedCardIds;
      
      // Önce FilterController'dan seçimleri almaya çalış
      if (Get.isRegistered<FilterController>()) {
        try {
          final filterController = Get.find<FilterController>();
          final ids = filterController.getSelectedCardIds();
          if (ids.isNotEmpty) {
            selectedCardIds = ids;
            debugPrint('[HOME CONTROLLER] Selected card IDs from filter controller: $selectedCardIds');
          }
        } catch (e) {
          debugPrint('[HOME CONTROLLER] Error getting filter from controller: $e');
        }
      }
      
      // Eğer FilterController'dan seçim alınamadıysa, storage'dan direkt oku
      if (selectedCardIds == null || selectedCardIds.isEmpty) {
        try {
          final savedIds = _storage.read<List>(FilterController.selectedFiltersKey);
          if (savedIds != null && savedIds.isNotEmpty) {
            selectedCardIds = savedIds.cast<String>();
            debugPrint('[HOME CONTROLLER] Selected card IDs from storage: $selectedCardIds');
          }
        } catch (e) {
          debugPrint('[HOME CONTROLLER] Error reading filter from storage: $e');
        }
      }
      
      // cards parametresi verilmişse onu kullan, yoksa filter'dan seçilen kartları kullan
      final finalCards = cards ?? selectedCardIds;
      
      debugPrint('[HOME CONTROLLER] Using cards: $finalCards');

      final response = await _companiesService.getCompanies(
        lat: lat,
        lng: lng,
        filterType: finalFilterType,
        search: search ?? '',
        cardId: cardId,
        cards: finalCards,
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
        
        // Daha fazla veri var mı kontrolü
        // API'den gelen item sayısı limit'e eşitse, muhtemelen daha fazla veri var
        // Eğer gelen item sayısı limit'ten azsa, son sayfadayız demektir
        final receivedItemsCount = response.muessises.length;
        final hasMore = receivedItemsCount >= limit; // Gelen item sayısı limit'e eşit veya fazlaysa, daha fazla veri var
        
        _hasMoreDataCompanies.value = hasMore;

        debugPrint(
            '[HOME CONTROLLER] Companies loaded successfully: $receivedItemsCount items');
        debugPrint(
            '[HOME CONTROLLER] Current page: ${_currentPageCompanies.value}, Total pages: ${_totalPagesCompanies.value}');
        debugPrint(
            '[HOME CONTROLLER] Current loaded: ${_companies.length}, Response total: ${response.total}');
        debugPrint(
            '[HOME CONTROLLER] Received items: $receivedItemsCount, Limit: $limit');
        debugPrint(
            '[HOME CONTROLLER] Has more data: $_hasMoreDataCompanies (based on received items >= limit)');

        // Eğer daha fazla veri varsa bir sonraki sayfaya geç
        if (_hasMoreDataCompanies.value) {
          _currentPageCompanies.value++;
          debugPrint(
              '[HOME CONTROLLER] Next page will be: ${_currentPageCompanies.value}');
        } else {
          debugPrint('[HOME CONTROLLER] No more data to load (received items < limit)');
        }

        update();
      } else {
        _companiesError.value = 'failed_to_load_companies'.tr;
        debugPrint(
            '[HOME CONTROLLER] Failed to load companies - response is null');
      }
    } catch (e) {
      _companiesError.value = _extractErrorMessage(e);
      debugPrint('[HOME CONTROLLER] Error loading companies: $e');
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
      debugPrint('[HOME CONTROLLER] Loading user data...');

      final homeResponse = await _authService.home();

      // Eğer null döndüyse (token geçersiz veya logout gerekli), force logout yap
      if (homeResponse == null) {
        debugPrint('[HOME CONTROLLER] Token invalid or logout required');
        await AuthUtils.forceLogout();
        return;
      }

      // Check if logout is required (status 2) - UserModel'den status kontrol et
      if (homeResponse.user != null && homeResponse.user!.status == 2) {
        debugPrint(
            '[HOME CONTROLLER] Status 2 detected in user model, force logging out user');
        await AuthUtils.forceLogout();
        return;
      }

      debugPrint('[HOME CONTROLLER] ===== FULL HOME RESPONSE =====');
      debugPrint('[HOME CONTROLLER] Success: ${homeResponse.success}');
      debugPrint('[HOME CONTROLLER] Message: ${homeResponse.message}');
      debugPrint('[HOME CONTROLLER] Token: ${homeResponse.token}');

      if (homeResponse.user != null) {
        // debugPrint('[HOME CONTROLLER] ===== USER DETAILS =====');
        // debugPrint('[HOME CONTROLLER] ID: ${homeResponse.user?.id}');
        // debugPrint('[HOME CONTROLLER] Name: ${homeResponse.user?.name}');
        // debugPrint('[HOME CONTROLLER] Surname: ${homeResponse.user?.surname}');
        // debugPrint('[HOME CONTROLLER] People ID: ${homeResponse.user?.peopleId}');
        // debugPrint(
        //     '[HOME CONTROLLER] Sirket Name: ${homeResponse.user?.sirketId?.sirketName}');

        // debugPrint('[HOME CONTROLLER] Email: ${homeResponse.user?.email}');

        // debugPrint('[HOME CONTROLLER] Phone: ${homeResponse.user?.phone}');
        // debugPrint('[HOME CONTROLLER] Birth Date: ${homeResponse.user?.birthDate}');
        // debugPrint(
        //     '[HOME CONTROLLER] Total QR Codes: ${homeResponse.user?.totalQrCodes}');
        // debugPrint(
        //     '[HOME CONTROLLER] Today QR Codes: ${homeResponse.user?.todayQrCodes}');
        // debugPrint('[HOME CONTROLLER] Status: ${homeResponse.user?.status}');
        // debugPrint('[HOME CONTROLLER] ===== END USER DETAILS =====');
      } else {
        debugPrint('[HOME CONTROLLER] User is null!');
      }

      debugPrint('[HOME CONTROLLER] ===== END FULL HOME RESPONSE =====');

      if (homeResponse.success == true && homeResponse.user != null) {
        _user.value = homeResponse.user;
        debugPrint('[HOME CONTROLLER] User data loaded successfully');
        // UI'ı güncellemek için update() çağır
        update();
      } else {
        debugPrint('[HOME CONTROLLER] Failed to load user data');
        _showRetryButton.value = true;
        _retryMessage.value = 'failed_to_load_data'.tr;
      }
    } catch (e) {
      debugPrint('[HOME CONTROLLER] Error loading user data: $e');
      // AuthService'den gelen tüm hatalar retry edilebilir (sadece token geçersiz ve status 2 logout yapar)
      debugPrint('[HOME CONTROLLER] Showing retry button for error');
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
      debugPrint('[HOME CONTROLLER] ===== CARD DATA DEBUG =====');
      debugPrint('[HOME CONTROLLER] User: ${_user.value != null}');
      if (_user.value != null) {
        debugPrint('[HOME CONTROLLER] User ID: ${_user.value!.id}');
        debugPrint('[HOME CONTROLLER] User Name: ${_user.value!.name}');
        debugPrint(
            '[HOME CONTROLLER] SirketId: ${_user.value!.sirketId != null}');
        if (_user.value!.sirketId != null) {
          debugPrint(
              '[HOME CONTROLLER] Sirket ID: ${_user.value!.sirketId!.id}');
          debugPrint(
              '[HOME CONTROLLER] Sirket Name: ${_user.value!.sirketId!.sirketName}');
        }
      }
      debugPrint('[HOME CONTROLLER] ===========================');

      // Her My Cards açıldığında kartları yeniden yükle
      // User'dan sirket_id'yi al
      String? sirketId;
      if (_user.value?.sirketId != null) {
        sirketId = _user.value!.sirketId!.id;
      }

      // Geçici test için statik sirket_id
      if (sirketId == null || sirketId.isEmpty) {
        sirketId = "68a1f8fdecf9649c26454a66"; // Test sirket_id
        debugPrint(
            '[HOME CONTROLLER] Using static sirketId for test: $sirketId');
      }

      debugPrint('[HOME CONTROLLER] Final sirketId for API: $sirketId');

      // API request'i yap
      cardController.loadMyCards(sirketId: sirketId);
    } catch (e) {
      debugPrint('[HOME CONTROLLER] Error loading card data: $e');
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
        debugPrint(
            '[HOME CONTROLLER] Using static sirketId for test (fallback): $sirketId');
      }

      debugPrint('[HOME CONTROLLER] Fallback sirketId for API: $sirketId');

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
      debugPrint('[HOME CONTROLLER] MapController güncellenirken hata: $e');
    }
  }

  // Search results'ı home screen'de göster
  void showSearchResults(List<CompanyInListModel> searchResults,
      {String? searchQuery}) {
    debugPrint(
        '[HOME CONTROLLER] Showing ${searchResults.length} search results');
    _companies.value = searchResults;
    _isLoadingCompanies.value = false;
    _companiesError.value = '';
    if (searchQuery != null) {
      _currentSearchQuery.value = searchQuery;
    }
    debugPrint('[HOME CONTROLLER] Search results assigned to companies list');
  }

  // Search'i temizle ve normal companies'leri yükle
  void clearSearchResults() {
    debugPrint('[HOME CONTROLLER] clearSearchResults called');
    _currentSearchQuery.value = '';
    debugPrint(
        '[HOME CONTROLLER] Calling loadCompanies() to reload normal companies');
    loadCompanies(isRefresh: true);
  }

  /// Load filter type from storage
  void _loadFilterType() {
    final savedFilterType = _storage.read(_filterTypeKey);
    if (savedFilterType != null && savedFilterType is String) {
      _filterType.value = savedFilterType;
      debugPrint('[HOME CONTROLLER] Loaded filter type from storage: $savedFilterType');
    } else {
      _filterType.value = 'name'; // Default
      debugPrint('[HOME CONTROLLER] Using default filter type: name');
    }
  }

  /// Set filter type and save to storage
  void setFilterType(String filterType) {
    if (filterType != 'name' && filterType != 'distance') {
      debugPrint('[HOME CONTROLLER] Invalid filter type: $filterType');
      return;
    }
    
    _filterType.value = filterType;
    _storage.write(_filterTypeKey, filterType);
    debugPrint('[HOME CONTROLLER] Filter type set and saved: $filterType');
    
    // Reload companies with new filter
    loadCompanies(filterType: filterType, isRefresh: true);
  }
}
