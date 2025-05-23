import 'package:get/get.dart';

class QueryController extends GetxController {
  final RxList<Map<String, dynamic>> queries = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQueries();
  }

  // API'dan sorguları çekmek (şimdilik mock veri)
  Future<void> fetchQueries() async {
    isLoading.value = true;

    try {
      // Burada gerçek API çağrısı yapılabilir
      // Şimdilik mock veri kullanıyoruz
      await Future.delayed(
          Duration(milliseconds: 800)); // API gecikmesi simülasyonu

      queries.value = [
        {
          'id': 'S-12345678',
          'title': 'İstifadəçinin ödəniş edə bilməməsi',
          'description':
              'Ödəniş zamanı "Kart məlumatları yanlışdır" xətası alıram. Kartımla başqa yerlərdə ödəniş edə bilirəm.',
          'date': '15.06.2023',
          'status': 'solved',
          'files': ['https://via.placeholder.com/150', 'avankart.pdf']
        },
        {
          'id': 'S-87654321',
          'title': 'Hesabımdan yanlış məbləğ çıxılıb',
          'description':
              '25 AZN ödəniş etdim, lakin hesabımdan 50 AZN çıxılıb. Lütfən, məsələni araşdırın.',
          'date': '12.06.2023',
          'status': 'solved',
          'files': [
            'assets/images/cards_backgrounds/card1.png',
          ]
        },
        {
          'id': 'S-55443322',
          'title': 'Tətbiqdə məlumatlarım görünmür',
          'description':
              'Son əməliyyat tarixçəm və balansım görünmür. Tətbiqi yenidən yükləməyimə baxmayaraq, problem davam edir.',
          'date': '08.06.2023',
          'status': 'pending',
          'files': [
            'assets/images/cards_backgrounds/card1.png',
          ]
        },
        {
          'id': 'S-98765432',
          'title': 'Bonus hesablanmır',
          'description':
              'Son 3 alış-verişimdən bonus hesablanmayıb. Şərtlərə uyğun alış-veriş etməyimə baxmayaraq.',
          'date': '05.06.2023',
          'status': 'draft',
          'files': [
            'assets/images/cards_backgrounds/card1.png',
          ]
        }
      ];
    } catch (error) {
      print('Error fetching queries: $error');
    } finally {
      isLoading.value = false;
    }
  }

  // Sorgu detaylarını getir
  Map<String, dynamic>? getQueryDetails(String id) {
    return queries.firstWhereOrNull((query) => query['id'] == id);
  }

  // Yeni sorgu ekle
  void addQuery(Map<String, dynamic> query) {
    queries.insert(0, query);
    // Gerçek uygulamada burada bir API çağrısı yapılabilir
  }
}
