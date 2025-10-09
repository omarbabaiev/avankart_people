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

  /// Hata mesajını çıkar
  String _extractErrorMessage(dynamic error) {
    return ApiResponseParser.parseDioError(error);
  }

  /// Toggle favorite status for a company
  Future<bool> toggleFavorite(String muessiseId) async {
    try {
      print('\n╔═══════════════════════════════════════════════════╗');
      print('║ [FAVORITES CONTROLLER] 🎯 Toggle Favorite Started ║');
      print('╚═══════════════════════════════════════════════════╝');
      print('[FAVORITES CONTROLLER] 📋 Input Parameters:');
      print('[FAVORITES CONTROLLER]   - Company ID: $muessiseId');

      // Mevcut durumu kontrol et (toggle öncesi)
      final wasInFavorites = _favorites.any((c) => c.id == muessiseId);

      print('[FAVORITES CONTROLLER] 📊 Current State:');
      print('[FAVORITES CONTROLLER]   - Total Favorites: ${_favorites.length}');
      print('[FAVORITES CONTROLLER]   - Was in favorites: $wasInFavorites');
      print('[FAVORITES CONTROLLER] ⏱️  Start Time: ${DateTime.now()}');
      print('─────────────────────────────────────────────────────');

      final response = await _companiesService.toggleFavorite(
        muessiseId: muessiseId,
      );

      print('─────────────────────────────────────────────────────');
      print('[FAVORITES CONTROLLER] 📥 Service Response Received:');
      print(
          '[FAVORITES CONTROLLER]   - Response: ${response != null ? "Not Null" : "NULL"}');

      if (response != null) {
        print('[FAVORITES CONTROLLER]   - Status: ${response.status}');
        print('[FAVORITES CONTROLLER]   - Message: ${response.message}');
        print('[FAVORITES CONTROLLER]   - Is Valid: ${response.isValid}');
        print('[FAVORITES CONTROLLER]   - Is Added: ${response.isAdded}');
        print('[FAVORITES CONTROLLER]   - Is Removed: ${response.isRemoved}');
      }

      // Message field'ına göre karar ver (message: "added" veya "removed")
      if (response != null && response.isValid) {
        print('[FAVORITES CONTROLLER] ✅ Valid response received');
        print('[FAVORITES CONTROLLER] 📝 Message: "${response.message}"');

        if (response.isRemoved) {
          // Message: "removed" → Favoriden çıkarıldı
          final oldCount = _favorites.length;
          _favorites.removeWhere((company) => company.id == muessiseId);
          final newCount = _favorites.length;
          _totalItems.value--;

          print('┌─────────────────────────────────────────────────┐');
          print('│ [FAVORITES CONTROLLER] ✅ Favorite REMOVED      │');
          print('└─────────────────────────────────────────────────┘');
          print('[FAVORITES CONTROLLER] 📊 State Updated:');
          print('[FAVORITES CONTROLLER]   - Old Count: $oldCount');
          print('[FAVORITES CONTROLLER]   - New Count: $newCount');
          print(
              '[FAVORITES CONTROLLER]   - Removed: ${oldCount - newCount} item(s)');
          print('[FAVORITES CONTROLLER]   - Total Items: ${_totalItems.value}');
          print(
              '[FAVORITES CONTROLLER] 💬 Showing Snackbar: removed_from_favorites');

          SnackbarUtils.showSuccessSnackbar('removed_from_favorites'.tr);
          update();

          print('╔═══════════════════════════════════════════════════╗');
          print('║ [FAVORITES CONTROLLER] ✅ Toggle Complete: REMOVED║');
          print('╚═══════════════════════════════════════════════════╝\n');
          return false; // Artık favoride değil
        } else if (response.isAdded) {
          // Message: "added" → Favoriye eklendi
          print('┌─────────────────────────────────────────────────┐');
          print('│ [FAVORITES CONTROLLER] ✅ Favorite ADDED        │');
          print('└─────────────────────────────────────────────────┘');
          print('[FAVORITES CONTROLLER] 📊 Current State:');
          print(
              '[FAVORITES CONTROLLER]   - Total Favorites: ${_favorites.length}');
          print(
              '[FAVORITES CONTROLLER]   - Note: Item will appear after refresh');
          print(
              '[FAVORITES CONTROLLER] 💬 Showing Snackbar: added_to_favorites');

          SnackbarUtils.showSuccessSnackbar('added_to_favorites'.tr);
          update();

          print('╔═══════════════════════════════════════════════════╗');
          print('║ [FAVORITES CONTROLLER] ✅ Toggle Complete: ADDED  ║');
          print('╚═══════════════════════════════════════════════════╝\n');
          return true; // Artık favoride
        }
      } else {
        // Geçersiz response
        print('┌─────────────────────────────────────────────────┐');
        print('│ [FAVORITES CONTROLLER] ⚠️  Invalid Response      │');
        print('└─────────────────────────────────────────────────┘');
        print('[FAVORITES CONTROLLER] ❌ Response Details:');
        print('[FAVORITES CONTROLLER]   - Status: ${response?.status}');
        print('[FAVORITES CONTROLLER]   - Message: ${response?.message}');
        print('[FAVORITES CONTROLLER] 💬 Showing Error Snackbar');

        SnackbarUtils.showErrorSnackbar(
          response?.message ?? 'unexpected_response'.tr,
        );

        print('╔═══════════════════════════════════════════════════╗');
        print('║ [FAVORITES CONTROLLER] ⚠️  Toggle Failed: Invalid ║');
        print('╚═══════════════════════════════════════════════════╝\n');
      }

      return false;
    } catch (e) {
      print('┌─────────────────────────────────────────────────┐');
      print('│ [FAVORITES CONTROLLER] ❌ Exception Caught       │');
      print('└─────────────────────────────────────────────────┘');
      print('[FAVORITES CONTROLLER] 🚫 Error Details:');
      print('[FAVORITES CONTROLLER]   - Type: ${e.runtimeType}');
      print('[FAVORITES CONTROLLER]   - Message: $e');

      final errorMessage = _extractErrorMessage(e);
      print('[FAVORITES CONTROLLER] 📝 Parsed Error Message: $errorMessage');
      print('[FAVORITES CONTROLLER] 💬 Showing Error Snackbar');

      SnackbarUtils.showErrorSnackbar(errorMessage);

      print('╔═══════════════════════════════════════════════════╗');
      print('║ [FAVORITES CONTROLLER] ❌ Toggle Failed: Exception║');
      print('╚═══════════════════════════════════════════════════╝\n');
      return false;
    }
  }
}
