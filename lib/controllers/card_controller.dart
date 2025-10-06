import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/cards_service.dart';
import 'home_controller.dart';

class CardController extends GetxController with SingleGetTickerProviderMixin {
  final CardsService _cardsService = CardsService();

  final RxList transactions = [].obs;
  final RxBool isBottomSheetExpanded = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isTransactionLoading = false.obs; // Transaction loading state

  final RxInt selectedIndex = 0.obs;
  late PageController pageController;

  // Kartlar - API'den yüklenecek
  final RxList<Map<String, dynamic>> cards = <Map<String, dynamic>>[].obs;

  // Transaction durumu için flag'ler
  final RxBool hasTransactions = true.obs; // Transaction var mı?
  final RxString emptyTransactionMessage = ''.obs; // Boş transaction mesajı

  late DraggableScrollableController dragController;
  late AnimationController animationController;
  late Animation<double> sizeAnimation;
  late Animation<double> textSizeAnimation;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController();
    dragController = DraggableScrollableController();
    dragController.addListener(_onDragUpdate);

    // Hot reload sırasında selectedIndex'i sıfırla
    selectedIndex.value = 0;

    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    sizeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    textSizeAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );
    fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    // API'den verileri yükle - MainScreen'de My Cards sekmesine tıklandığında çağrılacak
  }

  void _onDragUpdate() {
    final bool shouldExpand = dragController.size > 0.75;
    isBottomSheetExpanded.value = shouldExpand;

    if (shouldExpand) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  void addTransaction(Map<String, dynamic> transaction) {
    transactions.insert(0, transaction);
  }

  // API'den kullanıcının kartlarını yükle
  Future<void> loadMyCards({String? sirketId}) async {
    try {
      isLoading.value = true;

      // Eğer sirketId verilmemişse, HomeController'dan al
      String? finalSirketId = sirketId;
      if (finalSirketId == null && Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        finalSirketId = homeController.user?.sirketId?.id;
      }

      print('[CARD CONTROLLER] Loading cards with sirketId: $finalSirketId');

      final response = await _cardsService.getMyCards(sirketId: finalSirketId);

      if (response?.success == true && response?.cards != null) {
        // API'den gelen kartları mevcut format'a dönüştür
        final apiCards = response!.cards!.map((card) {
          final parsedColor = _parseColor(card.backgroundColor);
          final iconPath = _getIconPath(card.icon);

          print('[CARD CONTROLLER] ===== CARD DATA DEBUG =====');
          print('[CARD CONTROLLER] Card Name: ${card.name}');
          print('[CARD CONTROLLER] Card Icon: ${card.icon} -> $iconPath');
          print(
              '[CARD CONTROLLER] Card Color: ${card.backgroundColor} -> $parsedColor');
          print('[CARD CONTROLLER] Card Balance: ${card.balance}');
          print('[CARD CONTROLLER] ===========================');

          return {
            'title': card.name,
            'icon': iconPath, // API'den gelen icon
            'color': parsedColor, // API'den gelen renk
            'balance': card.balance ?? 0.0, // API'den gelen balance
            'cardId': card.id,
            'status': card.currentStatus,
          };
        }).toList();

        // API'den gelen kartları güncelle
        cards.value = apiCards;

        // İlk kartın işlemlerini yükle - build tamamlandıktan sonra
        if (apiCards.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            loadCardTransactions(cardId: apiCards[0]['cardId'] as String?);
          });
        }
      }
    } catch (e) {
      // 404 hatası durumunda özel mesaj göster
      if (e.toString().contains('404') ||
          e.toString().contains('user_not_found')) {
        cards.value = []; // Kartları temizle
        SnackbarUtils.showErrorSnackbar(
          'Hiçbir üyeliğiniz bulunamadı',
          textColor: Colors.white,
        );
      } else {
        // Diğer hatalar için genel mesaj
        SnackbarUtils.showErrorSnackbar(
          'Kartlar yüklenirken hata oluştu: ${e.toString()}',
          textColor: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // API'den kart işlemlerini yükle
  Future<void> loadCardTransactions({String? cardId}) async {
    try {
      // Eğer cardId verilmezse, seçili kartın ID'sini kullan
      final currentCardId = cardId ??
          (cards.isNotEmpty
              ? cards[selectedIndex.value]['cardId'] as String?
              : null);

      print('[CARD CONTROLLER] ===== LOAD TRANSACTIONS DEBUG =====');
      print('[CARD CONTROLLER] Requested cardId: $cardId');
      print('[CARD CONTROLLER] Current selectedIndex: ${selectedIndex.value}');
      print('[CARD CONTROLLER] Cards length: ${cards.length}');
      print('[CARD CONTROLLER] Final currentCardId: $currentCardId');
      print('[CARD CONTROLLER] ====================================');

      if (currentCardId == null) {
        print(
            '[CARD CONTROLLER] No cardId available, skipping transaction load');
        return;
      }

      isTransactionLoading.value = true;
      final response =
          await _cardsService.getCardTransactions(cardId: currentCardId);

      if (response?.success == true && response?.transactions != null) {
        print('[CARD CONTROLLER] ===== TRANSACTIONS API RESPONSE =====');
        print('[CARD CONTROLLER] Success: ${response!.success}');
        print('[CARD CONTROLLER] Page: ${response.page}');
        print('[CARD CONTROLLER] Skip: ${response.skip}');
        print('[CARD CONTROLLER] Limit: ${response.limit}');
        print(
            '[CARD CONTROLLER] Transactions count: ${response.transactions!.length}');

        // Her transaction için debug bilgisi
        for (int i = 0; i < response.transactions!.length; i++) {
          final transaction = response.transactions![i];
          print('[CARD CONTROLLER] Transaction $i:');
          print('[CARD CONTROLLER]   ID: ${transaction.id}');
          print('[CARD CONTROLLER]   Amount: ${transaction.amount}');
          print('[CARD CONTROLLER]   Status: ${transaction.status}');
          print(
              '[CARD CONTROLLER]   Muessise Name: ${transaction.muessiseName}');
          print(
              '[CARD CONTROLLER]   Muessise Category: ${transaction.muessiseCategory}');
          print('[CARD CONTROLLER]   Category: ${transaction.category}');
          print('[CARD CONTROLLER]   Created At: ${transaction.createdAt}');
        }
        print('[CARD CONTROLLER] ======================================');

        // API'den gelen işlemleri mevcut format'a dönüştür
        final apiTransactions = response.transactions!
            .map((transaction) => {
                  'type': transaction.category,
                  'title': transaction.muessiseName ?? 'İşlem',
                  'subtitle': transaction.muessiseCategory ?? 'Genel',
                  'amount': transaction.amount.toStringAsFixed(2),
                  'date': _formatDate(transaction.createdAt),
                  'icon': _getTransactionIcon(
                      transaction.category), // Kategoriye göre icon
                  'isPositive': transaction.amount > 0,
                  'transactionId': transaction.id,
                  'status': transaction.status,
                })
            .toList();

        print('[CARD CONTROLLER] ===== TRANSACTIONS CONVERTED =====');
        print(
            '[CARD CONTROLLER] Converted transactions count: ${apiTransactions.length}');
        print('[CARD CONTROLLER] ==================================');

        // Eğer API'den işlem gelmezse, mevcut işlemleri koru
        if (apiTransactions.isNotEmpty) {
          transactions.value = apiTransactions;
          hasTransactions.value = true;
          emptyTransactionMessage.value = '';
          print('[CARD CONTROLLER] Transactions updated successfully');
        } else {
          // Boş transaction durumu
          hasTransactions.value = false;
          emptyTransactionMessage.value = 'Bu kart için henüz işlem bulunmuyor';
          transactions.value = []; // Boş liste
          print('[CARD CONTROLLER] No transactions found for this card');
        }
      } else {
        // API response başarısız
        hasTransactions.value = false;
        emptyTransactionMessage.value = 'İşlemler yüklenemedi';
        transactions.value = []; // Boş liste

        print(
            '[CARD CONTROLLER] Failed to load transactions - API response: ${response?.success}');
      }
    } catch (e) {
      // Hata durumunda boş transaction mesajı göster
      hasTransactions.value = false;
      emptyTransactionMessage.value = 'İşlemler yüklenirken hata oluştu';
      transactions.value = []; // Boş liste

      print('[CARD CONTROLLER] Error loading transactions: $e');

      // Toast göster
      SnackbarUtils.showErrorSnackbar(
        'İşlemler yüklenirken hata oluştu: ${e.toString()}',
        textColor: Colors.white,
      );
    } finally {
      isTransactionLoading.value = false;
    }
  }

  // Kart değiştiğinde işlemleri yeniden yükle
  void onCardChanged(int index) {
    print('[CARD CONTROLLER] ===== CARD CHANGED DEBUG =====');
    print('[CARD CONTROLLER] Method called with index: $index');
    print('[CARD CONTROLLER] Current selectedIndex: ${selectedIndex.value}');
    print('[CARD CONTROLLER] Cards length: ${cards.length}');

    // Index'in geçerli olduğundan emin ol
    if (index >= 0 && index < cards.length) {
      // selectedIndex'i güncelle (eğer henüz güncellenmemişse)
      if (selectedIndex.value != index) {
        selectedIndex.value = index;
        print('[CARD CONTROLLER] Updated selectedIndex to: $index');
      }

      animationController.forward(from: 0);

      // Yeni kartın işlemlerini yükle
      final newCardId = cards[index]['cardId'] as String?;
      print('[CARD CONTROLLER] New card ID: $newCardId');
      print('[CARD CONTROLLER] Card title: ${cards[index]['title']}');

      if (newCardId != null) {
        print('[CARD CONTROLLER] Loading transactions for card: $newCardId');
        loadCardTransactions(cardId: newCardId);
      } else {
        print('[CARD CONTROLLER] No cardId found for index $index');
      }
    } else {
      print(
          '[CARD CONTROLLER] Invalid index: $index (cards length: ${cards.length})');
    }
    print('[CARD CONTROLLER] =============================');
  }

  // Tarihi formatla
  String _formatDate(DateTime? date) {
    if (date == null) return 'Bilinmeyen';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Bu gün';
    } else if (transactionDate == yesterday) {
      return 'Dünən';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // API'den gelen icon string'ini asset path'e çevir
  String _getIconPath(String iconName) {
    // Icon mapping - API'den gelen icon isimlerini asset path'lere çevir
    final iconMap = {
      'gear': 'assets/images/Silver.png',
      'card': 'assets/images/Silver.png',
      'wallet': 'assets/images/Silver.png',
      'credit': 'assets/images/Silver.png',
      'debit': 'assets/images/Silver.png',
      'gift': 'assets/images/Silver.png',
      'fuel': 'assets/images/Silver.png',
      'food': 'assets/images/Silver.png',
      'shopping': 'assets/images/Silver.png',
      'transport': 'assets/images/Silver.png',
    };

    return iconMap[iconName.toLowerCase()] ?? 'assets/images/Silver.png';
  }

  // API'den gelen hex color string'ini Color objesine çevir
  Color _parseColor(String colorString) {
    print('[CARD CONTROLLER] ===== COLOR PARSING DEBUG =====');
    print('[CARD CONTROLLER] Input color string: "$colorString"');
    print('[CARD CONTROLLER] Color string type: ${colorString.runtimeType}');

    try {
      // Hex color string'ini temizle (# işareti varsa kaldır)
      String cleanColor = colorString.replaceAll('#', '');
      print('[CARD CONTROLLER] Cleaned color: "$cleanColor"');
      print('[CARD CONTROLLER] Cleaned color length: ${cleanColor.length}');

      Color resultColor;

      // 6 karakter hex color'u parse et
      if (cleanColor.length == 6) {
        final hexValue = int.parse('FF$cleanColor', radix: 16);
        resultColor = Color(hexValue);
        print(
            '[CARD CONTROLLER] Parsed as 6-char hex: $hexValue -> $resultColor');

        // Test: Manuel hex değerleri
        if (cleanColor.toUpperCase() == '42A5FC') {
          print('[CARD CONTROLLER] TEST: #42A5FC should be light blue');
          print('[CARD CONTROLLER] Expected: Color(0xFF42A5FC)');
          print('[CARD CONTROLLER] Actual: $resultColor');
        } else if (cleanColor.toUpperCase() == '32B5AC') {
          print('[CARD CONTROLLER] TEST: #32B5AC should be turquoise');
          print('[CARD CONTROLLER] Expected: Color(0xFF32B5AC)');
          print('[CARD CONTROLLER] Actual: $resultColor');
        }
      }
      // 8 karakter hex color'u parse et (alpha dahil)
      else if (cleanColor.length == 8) {
        final hexValue = int.parse(cleanColor, radix: 16);
        resultColor = Color(hexValue);
        print(
            '[CARD CONTROLLER] Parsed as 8-char hex: $hexValue -> $resultColor');
      }
      // Geçersiz format durumunda varsayılan renk
      else {
        resultColor = const Color(0xFF42A5FC); // Mavi
        print(
            '[CARD CONTROLLER] Invalid length, using default color: $resultColor');
      }

      print('[CARD CONTROLLER] Final result color: $resultColor');
      print('[CARD CONTROLLER] ===============================');
      return resultColor;
    } catch (e) {
      print('[CARD CONTROLLER] Error parsing color: $colorString, error: $e');
      print(
          '[CARD CONTROLLER] Using default color: ${const Color(0xFF42A5FC)}');
      print('[CARD CONTROLLER] ===============================');
      return const Color(0xFF42A5FC); // Varsayılan mavi
    }
  }

  // Transaction kategorisine göre icon path döndür
  String _getTransactionIcon(String category) {
    final iconMap = {
      'transaction': 'assets/images/Silver.png',
      'food': 'assets/images/Silver.png',
      'fuel': 'assets/images/Silver.png',
      'shopping': 'assets/images/Silver.png',
      'transport': 'assets/images/Silver.png',
      'entertainment': 'assets/images/Silver.png',
      'health': 'assets/images/Silver.png',
      'education': 'assets/images/Silver.png',
      'travel': 'assets/images/Silver.png',
      'gift': 'assets/images/Silver.png',
      'topup': 'assets/images/Silver.png',
      'withdrawal': 'assets/images/Silver.png',
    };

    return iconMap[category.toLowerCase()] ?? 'assets/images/Silver.png';
  }

  @override
  void onClose() {
    pageController.dispose();
    dragController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
