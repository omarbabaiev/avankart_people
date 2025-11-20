import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/companies_response.dart';
import '../services/companies_service.dart';
import '../services/location_service.dart';
import 'home_controller.dart';

class SearchController extends GetxController {
  // Services
  final CompaniesService _companiesService = CompaniesService();
  final LocationService _locationService = LocationService();
  final GetStorage _storage = GetStorage();

  // Search state
  final _searchQuery = ''.obs;
  final _searchResults = <CompanyInListModel>[].obs;
  final _isSearching = false.obs;
  final _searchHistory = <String>[].obs;
  final _noResultsFound = false.obs;

  // Getters
  String get searchQuery => _searchQuery.value;
  List<CompanyInListModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching.value;
  List<String> get searchHistory => _searchHistory;
  bool get noResultsFound => _noResultsFound.value;

  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
  }

  // Search query'yi güncelle
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  // Search query'yi temizle
  void clearSearchQuery() {
    _searchQuery.value = '';
    _searchResults.clear();
    _noResultsFound.value = false;
  }

  // Search yap
  Future<void> searchCompanies(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _noResultsFound.value = false;
      return;
    }

    // Request atıldığı anda search history'ye ekle
    _addToSearchHistory(query);

    _isSearching.value = true;
    _noResultsFound.value = false;

    try {
      debugPrint('[SEARCH CONTROLLER] Searching for: $query');

      // Kullanıcının konumunu al
      final position = await _locationService.getCurrentLocation();
      double? lat = position?.latitude;
      double? lng = position?.longitude;

      debugPrint('[SEARCH CONTROLLER] Location: lat=$lat, lng=$lng');

      // Companies service'den search yap
      final response = await _companiesService.searchCompanies(
        query: query,
        lat: lat,
        lng: lng,
      );

      if (response != null && response.isNotEmpty) {
        _searchResults.value = response.muessises;
        _noResultsFound.value = false;
        debugPrint(
            '[SEARCH CONTROLLER] Found ${_searchResults.length} results');

        // Home screen'e dön ve search results'ı göster
        _navigateToHomeWithResults(response.muessises);
      } else {
        _searchResults.clear();
        _noResultsFound.value = true;
        debugPrint('[SEARCH CONTROLLER] No results found');
      }
    } catch (e) {
      debugPrint('[SEARCH CONTROLLER] Search error: $e');
      _searchResults.clear();
      _noResultsFound.value = true;

      // Eğer sadece "status: ok" response'u geliyorsa, bu normal bir durum
      if (e.toString().contains('status: ok')) {
        debugPrint('[SEARCH CONTROLLER] No results found for query: $query');
      }
    } finally {
      _isSearching.value = false;
    }
  }

  // Search history'ye ekle
  void _addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;

    // Aynı query varsa kaldır
    _searchHistory.remove(query.trim());

    // Başa ekle
    _searchHistory.insert(0, query.trim());

    // Son 3'ü tut
    if (_searchHistory.length > 3) {
      _searchHistory.removeRange(3, _searchHistory.length);
    }

    // Storage'a kaydet
    _saveSearchHistory();
  }

  // Search history'den kaldır
  void removeFromSearchHistory(String query) {
    _searchHistory.remove(query);
    _saveSearchHistory();
  }

  // Search history'yi temizle
  void clearSearchHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
  }

  // Search history'yi storage'dan yükle
  void _loadSearchHistory() {
    try {
      final history = _storage.read<List>('search_history') ?? [];
      _searchHistory.value = history.cast<String>();
    } catch (e) {
      debugPrint('[SEARCH CONTROLLER] Error loading search history: $e');
      _searchHistory.clear();
    }
  }

  // Search history'yi storage'a kaydet
  void _saveSearchHistory() {
    try {
      _storage.write('search_history', _searchHistory);
    } catch (e) {
      debugPrint('[SEARCH CONTROLLER] Error saving search history: $e');
    }
  }

  // Search results'ı temizle
  void clearSearchResults() {
    _searchResults.clear();
    _searchQuery.value = '';
    _noResultsFound.value = false;
  }

  // Home screen'e dön ve search results'ı göster
  void _navigateToHomeWithResults(List<CompanyInListModel> results) {
    try {
      debugPrint(
          '[SEARCH CONTROLLER] Navigating to home with ${results.length} results');

      // HomeController'ı bul
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        // Search results'ı home screen'de göster ve search query'yi de gönder
        homeController.showSearchResults(results,
            searchQuery: _searchQuery.value);
        debugPrint(
            '[SEARCH CONTROLLER] Search results assigned to home companies');
      } else {
        debugPrint('[SEARCH CONTROLLER] HomeController not found');
      }

      // Search screen'den çık
      Get.back();
      debugPrint('[SEARCH CONTROLLER] Returned to home screen');
    } catch (e) {
      debugPrint('[SEARCH CONTROLLER] Error navigating to home: $e');
    }
  }

  // Cancel butonuna basıldığında
  void onCancelPressed() {
    try {
      // Eğer search query boş ise sadece çık, request atma
      if (_searchQuery.value.trim().isEmpty) {
        debugPrint(
            '[SEARCH CONTROLLER] Search query is empty, just closing without request');
        clearSearchQuery();
        Get.back();
        return;
      }

      // Search query'yi temizle
      clearSearchQuery();

      // HomeController'ı bul ve normal companies'leri yükle
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        // clearSearchResults zaten search null ile home request atıyor
        homeController.clearSearchResults();
        debugPrint(
            '[SEARCH CONTROLLER] Search cleared and home request sent with null search');
      }

      // Search screen'den çık
      Get.back();
    } catch (e) {
      debugPrint('[SEARCH CONTROLLER] Error on cancel: $e');
    }
  }
}
