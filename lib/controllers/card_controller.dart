import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:avankart_people/utils/vibration_util.dart';
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

  // Card screen için index (kartlar arasında gezinme)
  final RxInt selectedCardIndex = 0.obs;
  // Payment için index (ödeme için kart seçimi)
  final RxInt selectedPaymentIndex = (-1).obs; // -1 = hiçbir kart seçilmedi
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

    // Hot reload sırasında index'leri sıfırla
    selectedCardIndex.value = 0;
    selectedPaymentIndex.value = -1;

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

        // selectedCardIndex'i kontrol et ve düzelt
        if (apiCards.isNotEmpty) {
          // Eğer selectedCardIndex geçersizse (< 0 veya >= cards.length), ilk kartı seç
          if (selectedCardIndex.value < 0 ||
              selectedCardIndex.value >= apiCards.length) {
            selectedCardIndex.value = 0;
            print(
                '[CARD CONTROLLER] Fixed invalid selectedCardIndex, set to 0');
          }

          // Seçili kartın işlemlerini yükle - build tamamlandıktan sonra
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final cardIndex =
                selectedCardIndex.value.clamp(0, apiCards.length - 1);
            loadCardTransactions(
                cardId: apiCards[cardIndex]['cardId'] as String?);
          });
        }
      }
    } catch (e) {
      // 404 hatası durumunda özel mesaj göster
      if (e.toString().contains('404') ||
          e.toString().contains('user_not_found')) {
        cards.value = []; // Kartları temizle
        SnackbarUtils.showErrorSnackbar(
          'no_card_found'.tr,
          textColor: Colors.white,
        );
      } else {
        // Diğer hatalar için genel mesaj
        SnackbarUtils.showErrorSnackbar(
          'cards_load_error'.tr + ': ${e.toString()}',
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
              ? cards[selectedCardIndex.value]['cardId'] as String?
              : null);

      print('[CARD CONTROLLER] ===== LOAD TRANSACTIONS DEBUG =====');
      print('[CARD CONTROLLER] Requested cardId: $cardId');
      print(
          '[CARD CONTROLLER] Current selectedCardIndex: ${selectedCardIndex.value}');
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
          emptyTransactionMessage.value = 'no_transactions_found'.tr;
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
      SnackbarUtils.showErrorSnackbar('transactions_load_error'.tr);
    } finally {
      isTransactionLoading.value = false;
    }
  }

  // Kart değiştiğinde işlemleri yeniden yükle
  void onCardChanged(int index) {
    // Kart değişimi - haptic feedback
    VibrationUtil.selectionVibrate();

    print('[CARD CONTROLLER] ===== CARD CHANGED DEBUG =====');
    print('[CARD CONTROLLER] Method called with index: $index');
    print(
        '[CARD CONTROLLER] Current selectedCardIndex: ${selectedCardIndex.value}');
    print('[CARD CONTROLLER] Cards length: ${cards.length}');

    // Index'in geçerli olduğundan emin ol
    if (index >= 0 && index < cards.length) {
      // selectedCardIndex'i güncelle (eğer henüz güncellenmemişse)
      if (selectedCardIndex.value != index) {
        selectedCardIndex.value = index;
        print('[CARD CONTROLLER] Updated selectedCardIndex to: $index');
      }

      // Animasyonu kaldırdık - butonlar artık slide ederken kaybolmayacak
      // animationController.forward(from: 0);

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
    if (date == null) return 'unknown'.tr;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'today'.tr;
    } else if (transactionDate == yesterday) {
      return 'yesterday'.tr;
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

  Color _parseColor(String? colorString, {Color defaultColor = Colors.grey}) {
    if (colorString == null || colorString.isEmpty) {
      return defaultColor;
    }

    String hexColor = colorString.toUpperCase().replaceAll("#", "");

    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // şəffaflıq əlavə olunur
    }

    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (_) {
      // Əgər səhv formatda rəng gəlirsə, default rəng qaytar
      return defaultColor;
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
