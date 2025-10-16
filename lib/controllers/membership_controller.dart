import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/membership_service.dart';
import '../models/membership_models.dart';
import '../utils/debug_logger.dart';
import '../utils/snackbar_utils.dart';
import '../services/auth_service.dart';
import '../utils/auth_utils.dart';
import '../utils/api_response_parser.dart';

class MembershipController extends GetxController {
  final MembershipService _membershipService = MembershipService();
  final AuthService _authService = AuthService();

  // Observable variables
  final RxList<Membership> _memberships = <Membership>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Selected membership details
  final Rx<MembershipDetail?> _selectedMembershipDetail =
      Rx<MembershipDetail?>(null);
  final RxBool _isLoadingDetails = false.obs;

  // Pagination variables
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalMemberships = 0.obs;
  final RxBool _hasMoreMemberships = true.obs;

  // Getters
  List<Membership> get memberships => _memberships;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  MembershipDetail? get selectedMembershipDetail =>
      _selectedMembershipDetail.value;
  bool get isLoadingDetails => _isLoadingDetails.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalMemberships => _totalMemberships.value;
  bool get hasMoreMemberships => _hasMoreMemberships.value;

  @override
  void onInit() {
    super.onInit();
    DebugLogger.debug(
        LogCategory.controller, 'MembershipController initialized');
  }

  /// Load user's memberships with pagination
  Future<void> fetchMemberships({
    int page = 1,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _memberships.clear();
        _hasMoreMemberships.value = true;
      }

      if (!_hasMoreMemberships.value) return;

      _isLoading.value = true;
      _errorMessage.value = '';

      DebugLogger.debug(
          LogCategory.controller, 'Loading memberships, page: $page');

      final response = await _membershipService.getMyMemberships(
        page: page,
        limit: 20,
      );

      // Eğer null döndüyse (token geçersiz veya logout gerekli), logout yap
      if (response == null) {
        DebugLogger.debug(
            LogCategory.controller, 'Token invalid or logout required');
        await AuthUtils.forceLogout();
        return;
      }

      if (response.success) {
        final newMemberships = response.memberships;

        if (refresh) {
          _memberships.value = newMemberships;
        } else {
          _memberships.addAll(newMemberships);
        }

        _currentPage.value = page;
        _hasMoreMemberships.value =
            newMemberships.length >= 20; // Limit kadar veri varsa devam eder

        DebugLogger.debug(LogCategory.controller,
            'Memberships loaded: ${_memberships.length} memberships, page: $page');
      } else {
        _errorMessage.value = response.message ?? 'Failed to load memberships';
        DebugLogger.error(LogCategory.controller,
            'Failed to load memberships: ${response.message}');
      }
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      _errorMessage.value = errorMessage;
      DebugLogger.error(LogCategory.controller, 'Error loading memberships',
          error: e);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load membership details by company ID
  Future<void> fetchMembershipDetails({
    required String sirketId,
  }) async {
    try {
      _isLoadingDetails.value = true;
      _errorMessage.value = '';

      DebugLogger.debug(LogCategory.controller,
          'Loading membership details for sirket: $sirketId');

      final response = await _membershipService.getMembershipDetails(
        sirketId: sirketId,
      );

      // Eğer null döndüyse (token geçersiz veya logout gerekli), logout yap
      if (response == null) {
        DebugLogger.debug(
            LogCategory.controller, 'Token invalid or logout required');
        await AuthUtils.forceLogout();
        return;
      }

      if (response.success) {
        _selectedMembershipDetail.value = response.membershipDetail;
        DebugLogger.debug(LogCategory.controller,
            'Membership details loaded for sirket: $sirketId');
      } else {
        _errorMessage.value =
            response.message ?? 'Failed to load membership details';
        DebugLogger.error(LogCategory.controller,
            'Failed to load membership details: ${response.message}');
      }
    } catch (e) {
      final errorMessage = ApiResponseParser.parseDioError(e);
      _errorMessage.value = errorMessage;
      DebugLogger.error(
          LogCategory.controller, 'Error loading membership details',
          error: e);
    } finally {
      _isLoadingDetails.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    DebugLogger.debug(LogCategory.controller, 'Refreshing membership data...');
    await Future.wait([
      fetchMemberships(refresh: true),
    ]);
  }

  /// Clear selected membership details
  void clearSelectedMembershipDetails() {
    _selectedMembershipDetail.value = null;
  }

  /// Get membership by ID
  Membership? getMembershipById(String id) {
    try {
      return _memberships.firstWhere((membership) => membership.id == id);
    } catch (e) {
      return null;
    }
  }
}
