import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../models/card_models.dart';
import '../services/cards_service.dart';
import '../utils/api_response_parser.dart';

class FilterController extends GetxController {
  final CardsService _cardsService = CardsService();
  final GetStorage _storage = GetStorage();

  final _isLoadingCards = false.obs;
  final _cardFilterCategories = <CardFilterCategory>[].obs;

  bool get isLoadingCards => _isLoadingCards.value;
  List<CardFilterCategory> get cardFilterCategories => _cardFilterCategories;

  // Storage key for selected filters
  static const String _selectedFiltersKey = 'selected_filter_card_ids';

  // Make it public so HomeController can access it
  static String get selectedFiltersKey => _selectedFiltersKey;

  // Static veriler kaldırıldı - sadece API'den gelen veriler kullanılacak
  var filterCategories = <Map<String, Object>>[].obs;

  // Reactive badge kontrolü için
  final _hasSelectedFilters = false.obs;
  bool get hasSelectedFilters => _hasSelectedFilters.value;

  // Search query için
  final _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;

  // Filtrelenmiş kategoriler - search query'ye göre
  List<Map<String, Object>> get filteredCategories {
    if (_searchQuery.value.isEmpty) {
      return filterCategories;
    }

    final query = _searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      return filterCategories;
    }

    final filtered = <Map<String, Object>>[];

    for (var category in filterCategories) {
      final categoryHeader = (category['header'] as String).toLowerCase();
      final items = category['items'] as List;
      final filteredItems = <Map<String, Object>>[];

      // Category header'da ara
      if (categoryHeader.contains(query)) {
        // Header eşleşirse tüm item'ları ekle
        for (var item in items) {
          filteredItems.add(Map<String, Object>.from(item as Map));
        }
      } else {
        // Item'larda ara
        for (var item in items) {
          final itemTitle = (item['title'] as String).toLowerCase();
          if (itemTitle.contains(query)) {
            filteredItems.add(Map<String, Object>.from(item as Map));
          }
        }
      }

      // Eğer filtered items varsa category'yi ekle
      if (filteredItems.isNotEmpty) {
        filtered.add(<String, Object>{
          'header': category['header'] as Object,
          'id': category['id'] as Object,
          'items': filteredItems,
        });
      }
    }

    return filtered;
  }

  // Seçili filter kontrolünü güncelle
  void _updateHasSelectedFilters() {
    bool hasSelected = false;
    for (var category in filterCategories) {
      final items = category['items'] as List?;
      if (items != null) {
        for (var item in items) {
          if (item['isSelected'] == true) {
            hasSelected = true;
            break;
          }
        }
        if (hasSelected) break;
      }
    }
    _hasSelectedFilters.value = hasSelected;
  }

  // Search query'yi güncelle
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  // Search query'yi temizle
  void clearSearchQuery() {
    _searchQuery.value = '';
  }

  /// Get selected card IDs from filter categories
  List<String> getSelectedCardIds() {
    final selectedCardIds = <String>[];

    for (var category in filterCategories) {
      final items = category['items'] as List;
      for (var item in items) {
        if (item['isSelected'] == true && item['id'] != null) {
          selectedCardIds.add(item['id'] as String);
        }
      }
    }

    debugPrint('[FILTER CONTROLLER] Selected card IDs: $selectedCardIds');
    return selectedCardIds;
  }

  void clearFilters() {
    for (var category in filterCategories) {
      final items = category['items'] as List;
      for (var item in items) {
        item['isSelected'] = false;
      }
    }
    // Storage'ı da temizle
    _storage.remove(_selectedFiltersKey);
    filterCategories.refresh();
    _updateHasSelectedFilters();
    debugPrint('[FILTER CONTROLLER] Filters cleared and storage removed');
  }

  void toggleSelection(int categoryIndex, int itemIndex) {
    // Filtrelenmiş kategorilerden item'ı bul
    final filteredCategories = this.filteredCategories;
    if (categoryIndex >= filteredCategories.length) return;

    final filteredCategory = filteredCategories[categoryIndex];
    final filteredItems = filteredCategory['items'] as List;
    if (itemIndex >= filteredItems.length) return;

    final filteredItem = filteredItems[itemIndex] as Map<String, dynamic>;
    final itemId = filteredItem['id'] as String?;

    if (itemId == null) return;

    // Orijinal filterCategories'de aynı ID'ye sahip item'ı bul ve toggle et
    for (var category in filterCategories) {
      final items = category['items'] as List;
      for (var item in items) {
        if (item['id'] == itemId) {
          item['isSelected'] = !(item['isSelected'] as bool);
          filterCategories.refresh();
          _updateHasSelectedFilters();
          _saveSelectedFilters();
          return;
        }
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadFilterCards();
  }

  /// Load filter cards from API
  Future<void> loadFilterCards() async {
    try {
      _isLoadingCards.value = true;
      debugPrint('[FILTER CONTROLLER] Loading filter cards...');

      final response = await _cardsService.getCardsForFilter();

      if (response != null && response.success && response.data.isNotEmpty) {
        _cardFilterCategories.value = response.data;
        debugPrint(
            '[FILTER CONTROLLER] Filter cards loaded successfully: ${response.data.length} categories');

        // API'den gelen verileri mevcut filterCategories formatına dönüştür
        // Header: kategori adı (örn: "Silver Card", "Gold Card")
        // Items: o kategorinin içindeki kartlar (örn: "Yemək kartı", "Yanacaq kartı")
        _updateFilterCategoriesFromApi(response.data);
        // Kaydedilmiş seçimleri restore et
        _loadSelectedFilters();
      } else {
        debugPrint(
            '[FILTER CONTROLLER] Failed to load filter cards - response is null, not successful, or empty');
        // API'den veri gelmezse filterCategories boş kalacak, empty state gösterilecek
      }
    } catch (e) {
      debugPrint('[FILTER CONTROLLER] Error loading filter cards: $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      debugPrint('[FILTER CONTROLLER] Error message: $errorMessage');
    } finally {
      _isLoadingCards.value = false;
    }
  }

  /// Update filterCategories from API data
  void _updateFilterCategoriesFromApi(List<CardFilterCategory> apiCategories) {
    final updatedCategories = <Map<String, Object>>[];

    for (var apiCategory in apiCategories) {
      // Kategori adını header olarak kullan (örn: "Silver Card", "Gold Card")
      // Kategori içindeki kartları items olarak kullan (örn: "Yemək kartı", "Yanacaq kartı")
      final items = apiCategory.cards
          .map((card) => <String, Object>{
                'title': card.name, // Kart adı (örn: "Yemək kartı")
                'isSelected': false,
                'id': card.id, // Kart ID'si
              })
          .toList();

      updatedCategories.add(<String, Object>{
        'header': apiCategory.name, // Kategori adı (örn: "Silver Card")
        'items': items, // Bu kategorinin kartları
        'id': apiCategory.id, // Kategori ID'si
      });
    }

    filterCategories.value = updatedCategories;
    _updateHasSelectedFilters();
    debugPrint(
        '[FILTER CONTROLLER] Filter categories updated from API: ${updatedCategories.length} categories');
    debugPrint(
        '[FILTER CONTROLLER] Categories: ${updatedCategories.map((c) => c['header']).join(', ')}');
  }

  /// Save selected filter card IDs to storage
  void _saveSelectedFilters() {
    try {
      final selectedIds = getSelectedCardIds();
      if (selectedIds.isEmpty) {
        // Eğer hiç seçim yoksa storage'ı temizle
        _storage.remove(_selectedFiltersKey);
        debugPrint('[FILTER CONTROLLER] No selected filters, storage cleared');
      } else {
        _storage.write(_selectedFiltersKey, selectedIds);
        debugPrint('[FILTER CONTROLLER] Saved selected filters: $selectedIds');
      }
    } catch (e) {
      debugPrint('[FILTER CONTROLLER] Error saving selected filters: $e');
    }
  }

  /// Load selected filter card IDs from storage and restore selections
  void _loadSelectedFilters() {
    try {
      final savedIds = _storage.read<List>(_selectedFiltersKey);
      if (savedIds == null || savedIds.isEmpty) {
        debugPrint('[FILTER CONTROLLER] No saved filters found');
        return;
      }

      final savedIdSet = savedIds.cast<String>().toSet();
      debugPrint('[FILTER CONTROLLER] Loading saved filters: $savedIdSet');

      // Mevcut kartlardaki tüm ID'leri topla
      final availableIds = <String>{};
      for (var category in filterCategories) {
        final items = category['items'] as List;
        for (var item in items) {
          final itemId = item['id'] as String?;
          if (itemId != null) {
            availableIds.add(itemId);
          }
        }
      }

      // Storage'daki ID'lerden mevcut olmayanları filtrele
      final validIds = savedIdSet.intersection(availableIds);

      // Eğer hiç geçerli ID yoksa storage'ı temizle
      if (validIds.isEmpty && savedIdSet.isNotEmpty) {
        debugPrint(
            '[FILTER CONTROLLER] No valid saved filters found, clearing storage');
        _storage.remove(_selectedFiltersKey);
        return;
      }

      // Restore selections based on valid saved IDs
      bool anyRestored = false;
      for (var category in filterCategories) {
        final items = category['items'] as List;
        for (var item in items) {
          final itemId = item['id'] as String?;
          if (itemId != null && validIds.contains(itemId)) {
            item['isSelected'] = true;
            anyRestored = true;
          }
        }
      }

      filterCategories.refresh();
      _updateHasSelectedFilters();

      // Eğer hiçbir seçim restore edilmediyse storage'ı temizle
      if (!anyRestored && savedIdSet.isNotEmpty) {
        debugPrint('[FILTER CONTROLLER] No filters restored, clearing storage');
        _storage.remove(_selectedFiltersKey);
      } else {
        debugPrint('[FILTER CONTROLLER] Restored selected filters: $validIds');
      }
    } catch (e) {
      debugPrint('[FILTER CONTROLLER] Error loading selected filters: $e');
      // Hata durumunda storage'ı temizle
      _storage.remove(_selectedFiltersKey);
    }
  }
}
