import 'package:avankart_people/models/companies_response.dart';
import 'package:avankart_people/services/companies_service.dart';
import 'package:avankart_people/utils/api_response_parser.dart';
import 'package:avankart_people/utils/toast_utils.dart';
import 'package:avankart_people/utils/vibration_util.dart';
import 'package:flutter/material.dart';
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
    int limit = 20,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _currentPage.value = 1;
      _hasMoreData.value = true;
      _favorites.value = []; // Refresh'te listeyi temizle
    }

    if (!_hasMoreData.value && !isRefresh) {
      debugPrint('[FAVORITES CONTROLLER] No more data to load');
      return;
    }

    if (_isLoading.value) {
      debugPrint('[FAVORITES CONTROLLER] Already loading, skipping');
      return;
    }

    try {
      _isLoading.value = true;
      _error.value = '';

      debugPrint(
          '[FAVORITES CONTROLLER] Loading favorites... Page: ${_currentPage.value}, Limit: $limit');

      final response = await _companiesService.getFavoriteCompanies(
        lat: null, // Collection'da null olarak gönderiliyor
        lng: null, // Collection'da null olarak gönderiliyor
        filterType: filterType ?? 'name',
        search: search,
        cards: cards ?? [],
        muessiseCategory: muessiseCategory ?? [],
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
        
        // Daha fazla veri var mı kontrolü
        // API'den gelen item sayısı limit'e eşitse, muhtemelen daha fazla veri var
        // Eğer gelen item sayısı limit'ten azsa, son sayfadayız demektir
        final receivedItemsCount = response.muessises.length;
        final hasMore = receivedItemsCount >= limit; // Gelen item sayısı limit'e eşit veya fazlaysa, daha fazla veri var
        
        _hasMoreData.value = hasMore;

        if (_hasMoreData.value) {
          _currentPage.value++;
        }

        debugPrint(
            '[FAVORITES CONTROLLER] Favorites loaded successfully: $receivedItemsCount items');
        debugPrint(
            '[FAVORITES CONTROLLER] Current page: ${_currentPage.value}, Total pages: ${_totalPages.value}');
        debugPrint(
            '[FAVORITES CONTROLLER] Current loaded: ${_favorites.length}, Response total: ${response.total}');
        debugPrint(
            '[FAVORITES CONTROLLER] Received items: $receivedItemsCount, Limit: $limit');
        debugPrint(
            '[FAVORITES CONTROLLER] Has more data: $_hasMoreData (based on received items >= limit)');
        update();
      } else {
        _error.value = 'failed_to_load_favorites'.tr;
        debugPrint(
            '[FAVORITES CONTROLLER] Failed to load favorites - response is null');
      }
    } catch (e) {
      _error.value = _extractErrorMessage(e);
      debugPrint('[FAVORITES CONTROLLER] Error loading favorites: $e');
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

  /// Check if a company is in favorites
  bool isFavorite(String companyId) {
    return _favorites.any((company) => company.id == companyId);
  }

  /// Toggle favorite status for a company
  Future<bool> toggleFavorite(String muessiseId) async {
    try {
      // Favori toggle - haptic feedback
      VibrationUtil.selectionVibrate();

      debugPrint('\n╔═══════════════════════════════════════════════════╗');
      debugPrint('║ [FAVORITES CONTROLLER] 🎯 Toggle Favorite Started ║');
      debugPrint('╚═══════════════════════════════════════════════════╝');
      debugPrint('[FAVORITES CONTROLLER] 📋 Input Parameters:');
      debugPrint('[FAVORITES CONTROLLER]   - Company ID: $muessiseId');

      // Mevcut durumu kontrol et (toggle öncesi)
      final wasInFavorites = _favorites.any((c) => c.id == muessiseId);

      debugPrint('[FAVORITES CONTROLLER] 📊 Current State:');
      debugPrint(
          '[FAVORITES CONTROLLER]   - Total Favorites: ${_favorites.length}');
      debugPrint(
          '[FAVORITES CONTROLLER]   - Was in favorites: $wasInFavorites');
      debugPrint('[FAVORITES CONTROLLER] ⏱️  Start Time: ${DateTime.now()}');
      debugPrint('─────────────────────────────────────────────────────');

      final response = await _companiesService.toggleFavorite(
        muessiseId: muessiseId,
      );

      debugPrint('─────────────────────────────────────────────────────');
      debugPrint('[FAVORITES CONTROLLER] 📥 Service Response Received:');
      debugPrint(
          '[FAVORITES CONTROLLER]   - Response: ${response != null ? "Not Null" : "NULL"}');

      if (response != null) {
        debugPrint('[FAVORITES CONTROLLER]   - Status: ${response.status}');
        debugPrint('[FAVORITES CONTROLLER]   - Message: ${response.message}');
        debugPrint('[FAVORITES CONTROLLER]   - Is Valid: ${response.isValid}');
        debugPrint('[FAVORITES CONTROLLER]   - Is Added: ${response.isAdded}');
        debugPrint(
            '[FAVORITES CONTROLLER]   - Is Removed: ${response.isRemoved}');
      }

      // Message field'ına göre karar ver (message: "added" veya "removed")
      if (response != null && response.isValid) {
        debugPrint('[FAVORITES CONTROLLER] ✅ Valid response received');
        debugPrint('[FAVORITES CONTROLLER] 📝 Message: "${response.message}"');

        if (response.isRemoved) {
          // Message: "removed" → Favoriden çıkarıldı
          final oldCount = _favorites.length;
          _favorites.removeWhere((company) => company.id == muessiseId);
          final newCount = _favorites.length;
          _totalItems.value--;

          debugPrint('┌─────────────────────────────────────────────────┐');
          debugPrint('│ [FAVORITES CONTROLLER] ✅ Favorite REMOVED      │');
          debugPrint('└─────────────────────────────────────────────────┘');
          debugPrint('[FAVORITES CONTROLLER] 📊 State Updated:');
          debugPrint('[FAVORITES CONTROLLER]   - Old Count: $oldCount');
          debugPrint('[FAVORITES CONTROLLER]   - New Count: $newCount');
          debugPrint(
              '[FAVORITES CONTROLLER]   - Removed: ${oldCount - newCount} item(s)');
          debugPrint(
              '[FAVORITES CONTROLLER]   - Total Items: ${_totalItems.value}');
          debugPrint(
              '[FAVORITES CONTROLLER] 💬 Showing Toast: removed_from_favorites');

          ToastUtils.showSuccessToast('removed_from_favorites'.tr);
          update();

          debugPrint('╔═══════════════════════════════════════════════════╗');
          debugPrint('║ [FAVORITES CONTROLLER] ✅ Toggle Complete: REMOVED║');
          debugPrint('╚═══════════════════════════════════════════════════╝\n');
          return false; // Artık favoride değil
        } else if (response.isAdded) {
          // Message: "added" → Favoriye eklendi
          debugPrint('┌─────────────────────────────────────────────────┐');
          debugPrint('│ [FAVORITES CONTROLLER] ✅ Favorite ADDED        │');
          debugPrint('└─────────────────────────────────────────────────┘');
          debugPrint('[FAVORITES CONTROLLER] 📊 Current State:');
          debugPrint(
              '[FAVORITES CONTROLLER]   - Total Favorites: ${_favorites.length}');
          debugPrint(
              '[FAVORITES CONTROLLER]   - Note: Item will appear after refresh');
          debugPrint(
              '[FAVORITES CONTROLLER] 💬 Showing Toast: added_to_favorites');

          ToastUtils.showSuccessToast('added_to_favorites'.tr);
          update();

          debugPrint('╔═══════════════════════════════════════════════════╗');
          debugPrint('║ [FAVORITES CONTROLLER] ✅ Toggle Complete: ADDED  ║');
          debugPrint('╚═══════════════════════════════════════════════════╝\n');
          return true; // Artık favoride
        }
      } else {
        // Geçersiz response
        debugPrint('┌─────────────────────────────────────────────────┐');
        debugPrint('│ [FAVORITES CONTROLLER] ⚠️  Invalid Response      │');
        debugPrint('└─────────────────────────────────────────────────┘');
        debugPrint('[FAVORITES CONTROLLER] ❌ Response Details:');
        debugPrint('[FAVORITES CONTROLLER]   - Status: ${response?.status}');
        debugPrint('[FAVORITES CONTROLLER]   - Message: ${response?.message}');
        debugPrint('[FAVORITES CONTROLLER] 💬 Showing Error Toast');

        ToastUtils.showErrorToast(
          response?.message ?? 'unexpected_response'.tr,
        );

        debugPrint('╔═══════════════════════════════════════════════════╗');
        debugPrint('║ [FAVORITES CONTROLLER] ⚠️  Toggle Failed: Invalid ║');
        debugPrint('╚═══════════════════════════════════════════════════╝\n');
      }

      return false;
    } catch (e) {
      debugPrint('┌─────────────────────────────────────────────────┐');
      debugPrint('│ [FAVORITES CONTROLLER] ❌ Exception Caught       │');
      debugPrint('└─────────────────────────────────────────────────┘');
      debugPrint('[FAVORITES CONTROLLER] 🚫 Error Details:');
      debugPrint('[FAVORITES CONTROLLER]   - Type: ${e.runtimeType}');
      debugPrint('[FAVORITES CONTROLLER]   - Message: $e');

      final errorMessage = _extractErrorMessage(e);
      debugPrint(
          '[FAVORITES CONTROLLER] 📝 Parsed Error Message: $errorMessage');
      debugPrint('[FAVORITES CONTROLLER] 💬 Showing Error Toast');

      ToastUtils.showErrorToast(errorMessage);

      debugPrint('╔═══════════════════════════════════════════════════╗');
      debugPrint('║ [FAVORITES CONTROLLER] ❌ Toggle Failed: Exception║');
      debugPrint('╚═══════════════════════════════════════════════════╝\n');
      return false;
    }
  }
}
