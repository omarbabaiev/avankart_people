import 'package:avankart_people/models/companies_response.dart';
import 'package:avankart_people/services/companies_service.dart';
import 'package:avankart_people/utils/api_response_parser.dart';
import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:get/get.dart';

class FavoritesController extends GetxController {
  final CompaniesService _companiesService = CompaniesService();

  // Favorites data
  final _favorites = <CompanyInListModel>[].obs;
  final _isLoading = false.obs;
  final _error = ''.obs;

  // Pagination
  final _currentPage = 1.obs;
  final _totalPages = 1.obs;
  final _totalItems = 0.obs;
  final _hasMoreData = true.obs;

  // Getters
  List<CompanyInListModel> get favorites => _favorites;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalItems => _totalItems.value;
  bool get hasMoreData => _hasMoreData.value;

  @override
  void onInit() {
    super.onInit();
    // loadFavorites(); // Bu satırı kaldırdık, sadece screen'e girince request atacak
  }

  /// Load favorite companies
  Future<void> loadFavorites({
    String? filterType,
    String? search,
    List<String>? cards,
    List<String>? muessiseCategory,
    int page = 1,
    int limit = 10,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _currentPage.value = 1;
      _hasMoreData.value = true;
    }

    if (!_hasMoreData.value && !isRefresh) return;

    try {
      _isLoading.value = true;
      _error.value = '';

      print(
          '[FAVORITES CONTROLLER] Loading favorites... Page: ${_currentPage.value}');

      final response = await _companiesService.getFavoriteCompanies(
        filterType: filterType,
        search: search,
        cards: cards,
        muessiseCategory: muessiseCategory,
        page: _currentPage.value,
        limit: limit,
      );

      if (response != null) {
        if (isRefresh) {
          _favorites.value = response.muessises;
        } else {
          _favorites.addAll(response.muessises);
        }

        // Pagination bilgilerini güncelle
        _totalPages.value = response.totalPages;
        _totalItems.value = response.total;
        _hasMoreData.value = _currentPage.value < _totalPages.value;

        if (_hasMoreData.value) {
          _currentPage.value++;
        }

        print(
            '[FAVORITES CONTROLLER] Favorites loaded successfully: ${response.muessises.length} items, Total: ${_totalItems.value}');
        update();
      } else {
        _error.value = 'failed_to_load_favorites'.tr;
        print(
            '[FAVORITES CONTROLLER] Failed to load favorites - response is null');
      }
    } catch (e) {
      _error.value = _extractErrorMessage(e);
      print('[FAVORITES CONTROLLER] Error loading favorites: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh favorites
  Future<void> refreshFavorites() async {
    await loadFavorites(isRefresh: true);
  }

  /// Load more data for pagination
  Future<void> loadMore() async {
    if (!_isLoading.value && _hasMoreData.value) {
      await loadFavorites();
    }
  }

  /// Toggle favorite status (remove from favorites)
  Future<bool> toggleFavorite(String companyId) async {
    // Önce favorites listesinde bu company'yi bul
    final companyIndex =
        _favorites.indexWhere((company) => company.id == companyId);
    if (companyIndex == -1) return false;

    final company = _favorites[companyIndex];
    final newFavoriteStatus = !company.isFavorite;

    try {
      // Optimistic update - UI'ı hemen güncelle
      _favorites[companyIndex] = CompanyInListModel(
        id: company.id,
        muessiseName: company.muessiseName,
        location: company.location,
        locationPoint: company.locationPoint,
        cards: company.cards,
        profileImagePath: company.profileImagePath,
        xariciCoverImagePath: company.xariciCoverImagePath,
        schedule: company.schedule,
        distance: company.distance,
        isFavorite: newFavoriteStatus,
      );

      // API çağrısını yap
      final response =
          await _companiesService.addToFavorites(muessiseId: companyId);

      print('[FAVORITES CONTROLLER] API Response: $response');

      // Yeni response formatına göre status kontrolü yap
      // Response formatı: {"status": "added", "message": "added"} veya {"status": "removed", "message": "removed"}
      if (response['status'] == 'added' || response['status'] == 'removed') {
        // Başarılı - eğer removed ise listesinden çıkar
        if (response['status'] == 'removed') {
          _favorites.removeAt(companyIndex);
          SnackbarUtils.showSuccessSnackbar(
              'company_removed_from_favorites'.tr);
        } else {
          SnackbarUtils.showSuccessSnackbar('company_added_to_favorites'.tr);
        }
        print(
            '[FAVORITES CONTROLLER] Favorite toggled successfully for company: $companyId, status: ${response['status']}, message: ${response['message']}');
        return true;
      } else {
        // Hata durumu - UI'ı geri al
        _favorites[companyIndex] = company;
        SnackbarUtils.showErrorSnackbar('failed_to_update_favorite'.tr);
        print(
            '[FAVORITES CONTROLLER] Failed to toggle favorite for company: $companyId, response: $response');
        return false;
      }
    } catch (e) {
      // Hata durumunda geri al - orijinal company'yi geri yükle
      final companyIndex =
          _favorites.indexWhere((company) => company.id == companyId);
      if (companyIndex != -1) {
        // Orijinal company'yi geri yükle
        _favorites[companyIndex] = company;
      }
      SnackbarUtils.showErrorSnackbar('network_error'.tr);
      print('[FAVORITES CONTROLLER] Error toggling favorite: $e');
      return false;
    }
  }

  /// Hata mesajını çıkar
  String _extractErrorMessage(dynamic error) {
    return ApiResponseParser.parseDioError(error);
  }
}
