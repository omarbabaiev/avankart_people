import 'package:avankart_people/utils/snackbar_utils.dart';
import 'package:avankart_people/utils/vibration_util.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/cards_service.dart';
import '../routes/app_routes.dart';
import '../utils/api_response_parser.dart';
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

  // Pagination state
  final RxInt currentPage = 1.obs; // Mevcut sayfa
  final RxInt limit = 10.obs; // Sayfa başına kayıt sayısı
  final RxBool hasMore = true.obs; // Daha fazla transaction var mı?
  final RxBool isLoadingMore = false.obs; // Daha fazla yükleniyor mu?

  late DraggableScrollableController dragController;
  late AnimationController animationController;
  late Animation<double> sizeAnimation;
  late Animation<double> textSizeAnimation;
  late Animation<double> fadeAnimation;
  double bottomSheetMinSize = 0.65; // Dynamic olarak güncellenecek

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
    // Bottom sheet yukarı kaydırıldığında (minimum size'dan büyükse) butonları gizle
    final bool shouldHideButtons = dragController.size > bottomSheetMinSize + 0.01;
    isBottomSheetExpanded.value = shouldHideButtons;

    if (shouldHideButtons) {
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

      debugPrint(
          '[CARD CONTROLLER] Loading cards with sirketId: $finalSirketId');

      final response = await _cardsService.getMyCards(sirketId: finalSirketId);

      if (response?.success == true && response?.cards != null) {
        // API'den gelen kartları mevcut format'a dönüştür
        final apiCards = response!.cards!.map((card) {
          final parsedColor = _parseColor(card.backgroundColor);
          final iconPath = _getIconPath(card.icon);

          debugPrint('[CARD CONTROLLER] ===== CARD DATA DEBUG =====');
          debugPrint('[CARD CONTROLLER] Card Name: ${card.name}');
          debugPrint('[CARD CONTROLLER] Card Icon: ${card.icon} -> $iconPath');
          debugPrint(
              '[CARD CONTROLLER] Card Color: ${card.backgroundColor} -> $parsedColor');
          debugPrint('[CARD CONTROLLER] Card Balance: ${card.balance}');
          debugPrint('[CARD CONTROLLER] ===========================');

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
            debugPrint(
                '[CARD CONTROLLER] Fixed invalid selectedCardIndex, set to 0');
          }

          // Seçili kartın işlemlerini yükle - build tamamlandıktan sonra
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final cardIndex =
                selectedCardIndex.value.clamp(0, apiCards.length - 1);
            loadCardTransactions(
                cardId: apiCards[cardIndex]['cardId'] as String?,
                refresh: true);
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
  Future<void> loadCardTransactions(
      {String? cardId, bool refresh = false}) async {
    try {
      // Eğer cardId verilmezse, seçili kartın ID'sini kullan
      final currentCardId = cardId ??
          (cards.isNotEmpty
              ? cards[selectedCardIndex.value]['cardId'] as String?
              : null);

      debugPrint('[CARD CONTROLLER] ===== LOAD TRANSACTIONS DEBUG =====');
      debugPrint('[CARD CONTROLLER] Requested cardId: $cardId');
      debugPrint('[CARD CONTROLLER] Refresh: $refresh');
      debugPrint(
          '[CARD CONTROLLER] Current selectedCardIndex: ${selectedCardIndex.value}');
      debugPrint('[CARD CONTROLLER] Cards length: ${cards.length}');
      debugPrint('[CARD CONTROLLER] Final currentCardId: $currentCardId');
      debugPrint('[CARD CONTROLLER] ====================================');

      if (currentCardId == null) {
        debugPrint(
            '[CARD CONTROLLER] No cardId available, skipping transaction load');
        return;
      }

      // Refresh ise pagination state'i sıfırla
      if (refresh) {
        currentPage.value = 1;
        hasMore.value = true;
        transactions.value = [];
      }

      // Eğer daha fazla veri yoksa ve refresh değilse, yükleme yapma
      if (!hasMore.value && !refresh) {
        debugPrint('[CARD CONTROLLER] No more transactions to load');
        return;
      }

      // Refresh ise normal loading, değilse loading more
      if (refresh) {
      isTransactionLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final response = await _cardsService.getCardTransactions(
        cardId: currentCardId,
        page: currentPage.value,
        limit: limit.value,
      );

      if (response?.success == true && response?.transactions != null) {
        debugPrint('[CARD CONTROLLER] ===== TRANSACTIONS API RESPONSE =====');
        debugPrint('[CARD CONTROLLER] Success: ${response!.success}');
        debugPrint('[CARD CONTROLLER] Page: ${response.page}');
        debugPrint('[CARD CONTROLLER] Skip: ${response.skip}');
        debugPrint('[CARD CONTROLLER] Limit: ${response.limit}');
        debugPrint(
            '[CARD CONTROLLER] Transactions count: ${response.transactions!.length}');

        // Her transaction için debug bilgisi
        for (int i = 0; i < response.transactions!.length; i++) {
          final transaction = response.transactions![i];
          debugPrint('[CARD CONTROLLER] Transaction $i:');
          debugPrint('[CARD CONTROLLER]   ID: ${transaction.id}');
          debugPrint('[CARD CONTROLLER]   Amount: ${transaction.amount}');
          debugPrint('[CARD CONTROLLER]   Status: ${transaction.status}');
          debugPrint(
              '[CARD CONTROLLER]   Muessise Name: ${transaction.muessiseName}');
          debugPrint(
              '[CARD CONTROLLER]   Muessise Category: ${transaction.muessiseCategory}');
          debugPrint('[CARD CONTROLLER]   Category: ${transaction.category}');
          debugPrint(
              '[CARD CONTROLLER]   Created At: ${transaction.createdAt}');
        }
        debugPrint('[CARD CONTROLLER] ======================================');

        // API'den gelen işlemleri mevcut format'a dönüştür
        final apiTransactions = response.transactions!
            .map((transaction) => {
                  'type': transaction.category,
                  'title': transaction.muessiseName ?? 'no_available'.tr,
                  'subtitle': transaction.muessiseCategory ?? '',
                  'amount': transaction.amount.toStringAsFixed(2),
                  'date': _formatDate(transaction.createdAt),
                  'icon': _getTransactionIcon(
                      transaction.category), // Kategoriye göre icon
                  'transactionId': transaction.id,
                  'status': transaction.status,
                  'category': transaction.category, // Detail için gerekli
                })
            .toList();

        debugPrint('[CARD CONTROLLER] ===== TRANSACTIONS CONVERTED =====');
        debugPrint(
            '[CARD CONTROLLER] Converted transactions count: ${apiTransactions.length}');
        debugPrint('[CARD CONTROLLER] ==================================');

        // Pagination kontrolü
        final totalTransactions = response.total ?? 0;
        // Refresh durumunda transactions.length 0 olacak, bu yüzden doğru hesaplama yapıyoruz
        final currentLoadedCount = refresh
            ? apiTransactions.length
            : transactions.length + apiTransactions.length;
        hasMore.value = currentLoadedCount < totalTransactions;

        // Eğer API'den işlem gelirse
        if (apiTransactions.isNotEmpty) {
          // Refresh ise değiştir, değilse ekle
          if (refresh) {
          transactions.value = apiTransactions;
          } else {
            transactions.addAll(apiTransactions);
          }

          // Eğer daha fazla sayfa varsa, page'i artır
          if (hasMore.value) {
            currentPage.value++;
          }

          hasTransactions.value = true;
          emptyTransactionMessage.value = '';
          debugPrint('[CARD CONTROLLER] Transactions updated successfully');
          debugPrint(
              '[CARD CONTROLLER] Total: $totalTransactions, Loaded: $currentLoadedCount, Has More: ${hasMore.value}');
        } else {
          // İlk yüklemede boş transaction durumu
          if (refresh || transactions.isEmpty) {
          hasTransactions.value = false;
          emptyTransactionMessage.value = 'no_transactions_found'.tr;
          transactions.value = []; // Boş liste
          debugPrint('[CARD CONTROLLER] No transactions found for this card');
          }
          hasMore.value = false;
        }
      } else {
        // API response başarısız
        hasTransactions.value = false;
        emptyTransactionMessage.value = 'transactions_load_error'.tr;
        transactions.value = []; // Boş liste

        debugPrint(
            '[CARD CONTROLLER] Failed to load transactions - API response: ${response?.success}');
      }
    } catch (e) {
      // Hata durumunda boş transaction mesajı göster
      hasTransactions.value = false;
      emptyTransactionMessage.value = 'transactions_load_error'.tr;
      transactions.value = []; // Boş liste

      debugPrint('[CARD CONTROLLER] Error loading transactions: $e');

      // Toast göster
      SnackbarUtils.showErrorSnackbar('transactions_load_error'.tr);
    } finally {
      isTransactionLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Daha fazla transaction yükle (pagination)
  Future<void> loadMoreTransactions() async {
    if (hasMore.value && !isLoadingMore.value && !isTransactionLoading.value) {
      debugPrint('[CARD CONTROLLER] Loading more transactions...');
      await loadCardTransactions(refresh: false);
    }
  }

  // Transaction listesini yenile
  Future<void> refreshTransactions() async {
    final currentCardId = cards.isNotEmpty
        ? cards[selectedCardIndex.value]['cardId'] as String?
        : null;
    if (currentCardId != null) {
      await loadCardTransactions(cardId: currentCardId, refresh: true);
    }
  }

  // Kart değiştiğinde işlemleri yeniden yükle
  void onCardChanged(int index) {
    // Kart değişimi - haptic feedback
    VibrationUtil.selectionVibrate();

    debugPrint('[CARD CONTROLLER] ===== CARD CHANGED DEBUG =====');
    debugPrint('[CARD CONTROLLER] Method called with index: $index');
    debugPrint(
        '[CARD CONTROLLER] Current selectedCardIndex: ${selectedCardIndex.value}');
    debugPrint('[CARD CONTROLLER] Cards length: ${cards.length}');

    // Index'in geçerli olduğundan emin ol
    if (index >= 0 && index < cards.length) {
      // selectedCardIndex'i güncelle (eğer henüz güncellenmemişse)
      if (selectedCardIndex.value != index) {
        selectedCardIndex.value = index;
        debugPrint('[CARD CONTROLLER] Updated selectedCardIndex to: $index');
      }

      // Animasyonu kaldırdık - butonlar artık slide ederken kaybolmayacak
      // animationController.forward(from: 0);

      // Yeni kartın işlemlerini yükle (refresh ile)
      final newCardId = cards[index]['cardId'] as String?;
      debugPrint('[CARD CONTROLLER] New card ID: $newCardId');
      debugPrint('[CARD CONTROLLER] Card title: ${cards[index]['title']}');

      if (newCardId != null) {
        debugPrint(
            '[CARD CONTROLLER] Loading transactions for card: $newCardId');
        loadCardTransactions(cardId: newCardId, refresh: true);
      } else {
        debugPrint('[CARD CONTROLLER] No cardId found for index $index');
      }
    } else {
      debugPrint(
          '[CARD CONTROLLER] Invalid index: $index (cards length: ${cards.length})');
    }
    debugPrint('[CARD CONTROLLER] =============================');
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

  // Transaction detail yükle ve detail screen'e git
  Future<void> loadTransactionDetailAndNavigate(
      String transactionId, String category) async {
    try {
      debugPrint(
          '[CARD CONTROLLER] Loading transaction detail: $transactionId, category: $category');

      final response = await _cardsService.getCardTransactionDetails(
        transactionId: transactionId,
        category: category,
      );

      if (response?.success == true && response?.transactionDetails != null) {
        debugPrint('[CARD CONTROLLER] Transaction detail loaded successfully');

        // Seçili kartın bilgilerini al
        final currentCard =
            cards.isNotEmpty && selectedCardIndex.value < cards.length
                ? cards[selectedCardIndex.value]
                : null;

        // Navigation'dan önce loading state'ini false yap (skeletonizer'ın enabled olmaması için)
        isTransactionLoading.value = false;

        // Transaction detail screen'e git
        Get.toNamed(AppRoutes.transactionDetail, arguments: {
          'transactionDetail': response!.transactionDetails,
          'heroTag': 'card_header',
          'cardColor': currentCard?['color'],
          'cardTitle': currentCard?['title'],
          'cardIcon': currentCard?['icon'],
          'cardDescription': currentCard?['description'],
        });
      } else {
        SnackbarUtils.showErrorSnackbar(
            response?.message ?? 'transaction_detail_load_error'.tr);
      }
    } catch (e) {
      debugPrint('[CARD CONTROLLER] Error loading transaction detail: $e');
      final errorMessage = ApiResponseParser.parseDioError(e);
      SnackbarUtils.showErrorSnackbar(errorMessage);
    } finally {
      // Navigation sonrası da false yap (güvenlik için)
      isTransactionLoading.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    dragController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
