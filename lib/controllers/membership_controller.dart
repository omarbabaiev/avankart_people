import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MembershipController extends GetxController {
  final RxList<Map<String, dynamic>> memberships = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // Kategori detayları için Map
  final Rx<Map<String, dynamic>> selectedMembershipDetails =
      Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    fetchMemberships();
  }

  // API'dan üyelik bilgilerini çekmek (şimdilik mock veri)
  Future<void> fetchMemberships() async {
    isLoading.value = true;

    try {
      // Burada gerçek API çağrısı yapılabilir
      // Şimdilik mock veri kullanıyoruz
      await Future.delayed(
          Duration(milliseconds: 800)); // API gecikmesi simülasyonu

      // API'dan alınacak JSON formatında veri örneği
      memberships.value = [
        {
          'id': '1',
          'name': 'Veysəloğlu MMC',
          'imageLink':
              'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png',
          'startDate': '14.08.2024',
          'endDate': null,
          'isEnd': false,
          'totalSpending': 3235.00,
          'categories': [
            {
              'id': '1',
              'name': 'Yemək',
              'colorHex': 0xFFFFD700,
              'iconPath': 'assets/icons/food.png',
              'spending': 100.0,
            },
            {
              'id': '2',
              'name': 'Market',
              'colorHex': 0xFF00FF62,
              'iconPath': 'assets/icons/market.png',
              'spending': 2000.0,
            },
            {
              'id': '3',
              'name': 'Texnika',
              'colorHex': 0xFFFF00D0,
              'iconPath': 'assets/icons/tech.png',
              'spending': 400.0,
            },
            {
              'id': '4',
              'name': 'Digər',
              'colorHex': 0xFFFF2600,
              'iconPath': 'assets/icons/other.png',
              'spending': 72.0,
            },
          ]
        },
        {
          'id': '2',
          'name': 'Azersun Holding',
          'imageLink':
              'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png',
          'startDate': '05.03.2023',
          'endDate': '01.06.2024',
          'isEnd': true,
          'totalSpending': 1500.00,
          'categories': [
            {
              'id': '1',
              'name': 'Yemək',
              'colorHex': 0xFFFFD700,
              'iconPath': 'assets/icons/food.png',
              'spending': 500.0,
            },
            {
              'id': '2',
              'name': 'Market',
              'colorHex': 0xFF00FF62,
              'iconPath': 'assets/icons/market.png',
              'spending': 750.0,
            },
            {
              'id': '3',
              'name': 'Texnika',
              'colorHex': 0xFFFF00D0,
              'iconPath': 'assets/icons/tech.png',
              'spending': 250.0,
            },
          ]
        },
        {
          'id': '3',
          'name': 'Bakı Tekstil Fabriki',
          'imageLink':
              'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png',
          'startDate': '10.01.2022',
          'endDate': '10.01.2024',
          'isEnd': true,
          'totalSpending': 2750.00,
          'categories': [
            {
              'id': '1',
              'name': 'Yemək',
              'colorHex': 0xFFFFD700,
              'iconPath': 'assets/icons/food.png',
              'spending': 650.0,
            },
            {
              'id': '2',
              'name': 'Texnika',
              'colorHex': 0xFFFF00D0,
              'iconPath': 'assets/icons/tech.png',
              'spending': 2100.0,
            },
          ]
        },
        {
          'id': '4',
          'name': 'Bakı Ağ Şəhər',
          'imageLink':
              'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-File.png',
          'startDate': '22.05.2024',
          'endDate': null,
          'isEnd': false,
          'totalSpending': 800.00,
          'categories': [
            {
              'id': '1',
              'name': 'Yemək',
              'colorHex': 0xFFFFD700,
              'iconPath': 'assets/icons/food.png',
              'spending': 300.0,
            },
            {
              'id': '2',
              'name': 'Market',
              'colorHex': 0xFF00FF62,
              'iconPath': 'assets/icons/market.png',
              'spending': 500.0,
            },
          ]
        }
      ];
    } catch (error) {
      print('Error fetching memberships: $error');
    } finally {
      isLoading.value = false;
    }
  }

  // Üyelik detaylarını getir
  Map<String, dynamic>? getMembershipDetails(String id) {
    return memberships.firstWhereOrNull((membership) => membership['id'] == id);
  }

  // Belirli bir üyeliğin detaylarını ayarla
  void setSelectedMembership(Map<String, dynamic> membership) {
    selectedMembershipDetails.value = membership;
  }
}
