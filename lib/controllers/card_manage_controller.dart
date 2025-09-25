import 'package:get/get.dart';
import '../services/cards_service.dart';
import '../models/card_models.dart';
import '../utils/debug_logger.dart';
import '../utils/auth_utils.dart';
import '../utils/api_response_parser.dart';

class CardManageController extends GetxController {
  final CardsService _cardsService = CardsService();

  // Observable variables
  final RxList<Card> _myCards = <Card>[].obs;
  final RxList<Card> _allCards = <Card>[].obs;
  final RxBool _isLoadingMyCards = false.obs;
  final RxBool _isLoadingAllCards = false.obs;
  final RxBool _isLoadingTransactions = false.obs;
  final RxString _errorMessage = ''.obs;

  // Retry functionality
  final RxBool _showRetryButton = false.obs;
  final RxString _retryMessage = ''.obs;

  // Pagination variables
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCards = 0.obs;
  final RxBool _hasMoreCards = true.obs;

  // Selected cards for management
  final RxMap<String, bool> _selectedCards = <String, bool>{}.obs;

  // Getters
  List<Card> get myCards => _myCards;
  List<Card> get allCards => _allCards;
  bool get isLoadingMyCards => _isLoadingMyCards.value;
  bool get isLoadingAllCards => _isLoadingAllCards.value;
  bool get isLoadingTransactions => _isLoadingTransactions.value;
  String get errorMessage => _errorMessage.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCards => _totalCards.value;
  bool get hasMoreCards => _hasMoreCards.value;
  Map<String, bool> get selectedCards => _selectedCards;

  // Retry getters
  bool get showRetryButton => _showRetryButton.value;
  String get retryMessage => _retryMessage.value;

  // Check if any card is selected
  bool get isAnyCardSelected => _selectedCards.values.any((value) => value);

  // Get selected cards count
  int get selectedCardsCount =>
      _selectedCards.values.where((value) => value).length;

  @override
  void onInit() {
    super.onInit();
    DebugLogger.debug(
        LogCategory.controller, 'CardManageController initialized');
  }

  /// Load user's cards
  Future<void> loadMyCards() async {
    try {
      _isLoadingMyCards.value = true;
      _errorMessage.value = '';
      _showRetryButton.value = false;
      _retryMessage.value = '';

      DebugLogger.debug(LogCategory.controller, 'Loading my cards...');

      final response = await _cardsService.getMyCards();

      // Eğer null döndüyse (token geçersiz veya logout gerekli), logout yap
      if (response == null) {
        DebugLogger.debug(
            LogCategory.controller, 'Token invalid or logout required');
        await AuthUtils.logout();
        return;
      }

      if (response.success) {
        _myCards.value = response.cards ?? [];
        DebugLogger.debug(LogCategory.controller,
            'My cards loaded: ${_myCards.length} cards');

        // Initialize selected cards map
        for (var card in _myCards) {
          _selectedCards[card.id] = false;
        }
      } else {
        _errorMessage.value = response.message ?? 'Failed to load cards';
        _showRetryButton.value = true;
        _retryMessage.value = response.message ?? 'Failed to load cards';
        DebugLogger.error(LogCategory.controller,
            'Failed to load my cards: ${response.message}');
      }
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      _errorMessage.value = errorMessage;
      _showRetryButton.value = true;
      _retryMessage.value = errorMessage;
      DebugLogger.error(LogCategory.controller, 'Error loading my cards',
          error: e);
    } finally {
      _isLoadingMyCards.value = false;
    }
  }

  /// Load all cards with pagination
  Future<void> loadAllCards({
    int page = 1,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _allCards.clear();
        _hasMoreCards.value = true;
      }

      if (!_hasMoreCards.value) return;

      _isLoadingAllCards.value = true;
      _errorMessage.value = '';
      _showRetryButton.value = false;
      _retryMessage.value = '';

      DebugLogger.debug(
          LogCategory.controller, 'Loading all cards, page: $page');

      final response = await _cardsService.getAllCards(
        page: page,
        limit: 20,
      );

      // Eğer null döndüyse (token geçersiz veya logout gerekli), logout yap
      if (response == null) {
        DebugLogger.debug(
            LogCategory.controller, 'Token invalid or logout required');
        await AuthUtils.logout();
        return;
      }

      if (response.success) {
        final newCards = response.cards ?? [];

        if (refresh) {
          _allCards.value = newCards;
        } else {
          _allCards.addAll(newCards);
        }

        _currentPage.value = page;
        _totalPages.value = response.totalPages ?? 1;
        _totalCards.value = response.total ?? 0;
        _hasMoreCards.value = page < (_totalPages.value);

        DebugLogger.debug(LogCategory.controller,
            'All cards loaded: ${_allCards.length} cards, page: $page, total: $_totalCards');

        // Initialize selected cards map for new cards
        for (var card in newCards) {
          if (!_selectedCards.containsKey(card.id)) {
            _selectedCards[card.id] = false;
          }
        }
      } else {
        _errorMessage.value = response.message ?? 'Failed to load cards';
        _showRetryButton.value = true;
        _retryMessage.value = response.message ?? 'Failed to load cards';
        DebugLogger.error(LogCategory.controller,
            'Failed to load all cards: ${response.message}');
      }
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      _errorMessage.value = errorMessage;
      _showRetryButton.value = true;
      _retryMessage.value = errorMessage;
      DebugLogger.error(LogCategory.controller, 'Error loading all cards',
          error: e);
    } finally {
      _isLoadingAllCards.value = false;
    }
  }

  /// Load more cards (pagination)
  Future<void> loadMoreCards() async {
    if (_hasMoreCards.value && !_isLoadingAllCards.value) {
      await loadAllCards(
        page: _currentPage.value + 1,
        refresh: false,
      );
    }
  }

  /// Load card transactions
  Future<List<CardTransaction>?> loadCardTransactions({
    required String cardId,
    int page = 1,
  }) async {
    try {
      _isLoadingTransactions.value = true;
      _errorMessage.value = '';

      DebugLogger.debug(
          LogCategory.controller, 'Loading transactions for card: $cardId');

      final response = await _cardsService.getCardTransactions(
        cardId: cardId,
        page: page,
        limit: 10,
      );

      // Eğer null döndüyse (token geçersiz veya logout gerekli), logout yap
      if (response == null) {
        DebugLogger.debug(
            LogCategory.controller, 'Token invalid or logout required');
        await AuthUtils.logout();
        return null;
      }

      if (response.success) {
        DebugLogger.debug(LogCategory.controller,
            'Transactions loaded: ${response.transactions?.length ?? 0} transactions');
        return response.transactions;
      } else {
        _errorMessage.value = response.message ?? 'Failed to load transactions';
        DebugLogger.error(LogCategory.controller,
            'Failed to load transactions: ${response.message}');
        return null;
      }
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      _errorMessage.value = errorMessage;
      DebugLogger.error(LogCategory.controller, 'Error loading transactions',
          error: e);
      return null;
    } finally {
      _isLoadingTransactions.value = false;
    }
  }

  /// Load card transaction details
  Future<CardTransactionDetails?> loadCardTransactionDetails({
    required String transactionId,
    String category = 'transaction',
  }) async {
    try {
      _isLoadingTransactions.value = true;
      _errorMessage.value = '';

      DebugLogger.debug(LogCategory.controller,
          'Loading transaction details: $transactionId');

      final response = await _cardsService.getCardTransactionDetails(
        transactionId: transactionId,
        category: category,
      );

      // Eğer null döndüyse (token geçersiz veya logout gerekli), logout yap
      if (response == null) {
        DebugLogger.debug(
            LogCategory.controller, 'Token invalid or logout required');
        await AuthUtils.logout();
        return null;
      }

      if (response.success) {
        DebugLogger.debug(
            LogCategory.controller, 'Transaction details loaded successfully');
        return response.transactionDetails;
      } else {
        _errorMessage.value =
            response.message ?? 'Failed to load transaction details';
        DebugLogger.error(LogCategory.controller,
            'Failed to load transaction details: ${response.message}');
        return null;
      }
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      _errorMessage.value = errorMessage;
      DebugLogger.error(
          LogCategory.controller, 'Error loading transaction details',
          error: e);
      return null;
    } finally {
      _isLoadingTransactions.value = false;
    }
  }

  /// Toggle card selection
  void toggleCardSelection(String cardId) {
    if (_selectedCards.containsKey(cardId)) {
      _selectedCards[cardId] = !(_selectedCards[cardId] ?? false);
      DebugLogger.debug(LogCategory.controller,
          'Card selection toggled: $cardId = ${_selectedCards[cardId]}');
    }
  }

  /// Select all cards
  void selectAllCards() {
    for (var cardId in _selectedCards.keys) {
      _selectedCards[cardId] = true;
    }
    DebugLogger.debug(LogCategory.controller, 'All cards selected');
  }

  /// Deselect all cards
  void deselectAllCards() {
    for (var cardId in _selectedCards.keys) {
      _selectedCards[cardId] = false;
    }
    DebugLogger.debug(LogCategory.controller, 'All cards deselected');
  }

  /// Get selected card IDs
  List<String> getSelectedCardIds() {
    return _selectedCards.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get selected cards
  List<Card> getSelectedCardsList() {
    final selectedIds = getSelectedCardIds();
    return _myCards.where((card) => selectedIds.contains(card.id)).toList();
  }

  /// Request change card status
  Future<bool> requestChangeCardStatus({
    required String cardId,
    required String status,
    List<String>? reasonIds,
  }) async {
    try {
      _errorMessage.value = '';

      DebugLogger.debug(LogCategory.controller,
          'Requesting card status change: $cardId to $status');

      final response = await _cardsService.requestChangeCardStatus(
        cardId: cardId,
        status: status,
        reasonIds: reasonIds,
      );

      if (response != null) {
        DebugLogger.debug(LogCategory.controller,
            'Card status change requested successfully: ${response['message']}');

        // Refresh cards to get updated status
        await loadAllCards(refresh: true);

        return true;
      } else {
        _errorMessage.value = 'Failed to request card status change';
        DebugLogger.error(LogCategory.controller,
            'Failed to request card status change: No response');
        return false;
      }
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      _errorMessage.value = errorMessage;
      DebugLogger.error(
          LogCategory.controller, 'Error requesting card status change',
          error: e);
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage.value = '';
  }

  /// Refresh all data
  Future<void> refreshData() async {
    DebugLogger.debug(LogCategory.controller, 'Refreshing card data...');
    await Future.wait([
      loadMyCards(),
      loadAllCards(refresh: true),
    ]);
  }

  @override
  void onClose() {
    DebugLogger.debug(LogCategory.controller, 'CardManageController disposed');
    super.onClose();
  }
}
