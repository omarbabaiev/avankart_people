import 'package:get/get.dart';

class FilterController extends GetxController {
  var filterCategories = [
    {
      "header": "Kart növləri",
      "items": [
        {"title": "Yemək", "isSelected": false},
        {"title": "Hediyyə", "isSelected": false},
        {"title": "Yanacaq", "isSelected": false},
        {"title": "Geyim", "isSelected": false},
        {"title": "Market", "isSelected": false},
        {"title": "Elektronika", "isSelected": false}
      ]
    },
    {
      "header": "Qida",
      "items": [
        {"title": "Restoranlar", "isSelected": false},
        {"title": "Kafe", "isSelected": false},
        {"title": "Kofe Shop", "isSelected": false},
        {"title": "PUB", "isSelected": false},
        {"title": "Fast Food", "isSelected": false},
        {"title": "Çay evi", "isSelected": false},
        {"title": "Şirniyyat", "isSelected": false},
        {"title": "Dönər", "isSelected": false}
      ]
    },
    {
      "header": "İdman və əyləncə",
      "items": [
        {"title": "Kinoteatrlar", "isSelected": false},
        {"title": "Peyntbol", "isSelected": false},
        {"title": "Bouling", "isSelected": false},
        {"title": "Fitnes", "isSelected": false},
        {"title": "Hovuz", "isSelected": false},
        {"title": "Oyun mərkəzləri", "isSelected": false}
      ]
    },
    {
      "header": "Gözəllik",
      "items": [
        {"title": "Saç ustası", "isSelected": false},
        {"title": "Kosmetologiya", "isSelected": false},
        {"title": "Spa mərkəzi", "isSelected": false},
        {"title": "Manikür və pedikür", "isSelected": false},
        {"title": "Masaj", "isSelected": false}
      ]
    },
    {
      "header": "Alış-veriş",
      "items": [
        {"title": "Geyim mağazaları", "isSelected": false},
        {"title": "Elektronika mağazaları", "isSelected": false},
        {"title": "Ətriyyat", "isSelected": false},
        {"title": "Kitab mağazaları", "isSelected": false},
        {"title": "Mebel mağazaları", "isSelected": false},
        {"title": "İdman malları", "isSelected": false}
      ]
    },
    {
      "header": "Təhsil",
      "items": [
        {"title": "Dil kursları", "isSelected": false},
        {"title": "Kompüter kursları", "isSelected": false},
        {"title": "Musiqi məktəbləri", "isSelected": false},
        {"title": "Sürücülük kursları", "isSelected": false},
        {"title": "Təlim mərkəzləri", "isSelected": false}
      ]
    }
  ].obs;

  bool get hasSelectedFilters {
    for (var category in filterCategories) {
      final items = category['items'] as List;
      if (items.any((item) => item['isSelected'] as bool)) {
        return true;
      }
    }
    return false;
  }

  void clearFilters() {
    for (var category in filterCategories) {
      final items = category['items'] as List;
      for (var item in items) {
        item['isSelected'] = false;
      }
    }
    filterCategories.refresh();
  }

  void toggleSelection(int categoryIndex, int itemIndex) {
    final items = filterCategories[categoryIndex]?['items'] as List?;
    if (items != null) {
      final item = items[itemIndex] as Map<String, dynamic>;
      item['isSelected'] = !(item['isSelected'] as bool);
      filterCategories.refresh();
    }
  }
}
