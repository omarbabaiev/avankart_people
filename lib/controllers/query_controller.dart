import 'package:avankart_people/services/query_service.dart';
import 'package:avankart_people/utils/toast_utils.dart';
import 'package:get/get.dart';

class QueryController extends GetxController {
  final RxList<Map<String, dynamic>> queries = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasMoreData = true.obs;
  final RxString errorMessage = ''.obs;

  final QueryService _queryService = QueryService();

  @override
  void onInit() {
    super.onInit();
    fetchQueries();
  }

  // API'dan sorguları çekmek
  Future<void> fetchQueries({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (!hasMoreData.value && !isRefresh) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _queryService.getMyTickets(
        page: currentPage.value,
        limit: 10,
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];

        // Debug: Sorgu sayısını ve sıralamayı göster
        if (data.isNotEmpty) {
          print('==================== QUERY DEBUG ====================');
          print('Total queries fetched: ${data.length}');
          print('First query date: ${data.first['date']}');
          print('Last query date: ${data.last['date']}');
          print('=====================================================');
        }

        // API'den gelen data formatını UI'ya uygun formata çevir
        final List<Map<String, dynamic>> formattedQueries = data.map((item) {
          return {
            'id': item['ticket_id'] ?? item['_id'],
            'title': item['account_reason'] ??
                item['reason'] ??
                'Hesab problemi', // Account reason'u title olarak kullan
            'description': item['problem'] ??
                item['your_problem'] ??
                item['content'] ??
                '', // Problem'i description olarak kullan
            'date': item['date'] ?? item['createdAt'] ?? '',
            'status': item['status'] ?? '',
            'files': [], // API'de files field'ı yok gibi görünüyor
            'reason': [], // API'de reason field'ı yok gibi görünüyor
          };
        }).toList();

        // API'den gelen sırayla yükle, sıralama yapma

        if (isRefresh) {
          queries.value = formattedQueries;
        } else {
          queries.addAll(formattedQueries);
          // API'den gelen sırayla yükle, sıralama yapma
        }

        // Pagination bilgilerini güncelle
        totalPages.value = response['totalPages'] ?? 1;
        totalItems.value = response['total'] ?? 0;
        hasMoreData.value = currentPage.value < totalPages.value;

        if (hasMoreData.value) {
          currentPage.value++;
        }
      } else {
        // API'den başarısız response geldiğinde hata mesajı göster
        final errorMsg = response['message'] ?? 'error_occurred'.tr;
        errorMessage.value = errorMsg;
        ToastUtils.showErrorToast(errorMsg);
      }
    } catch (error) {
      print('Error fetching queries: $error');
      final errorMsg = error.toString();
      errorMessage.value = errorMsg;
      ToastUtils.showErrorToast('error_occurred'.tr);
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
  }

  // Load more data for pagination
  Future<void> loadMore() async {
    if (!isLoading.value && hasMoreData.value) {
      await fetchQueries();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await fetchQueries(isRefresh: true);
  }

  // Create new query
  Future<bool> createQuery({
    required String title,
    required String content,
    required String description,
    required String category,
    required List<String> reason,
    List<String>? files,
  }) async {
    try {
      final response = await _queryService.createTicket(
        title: title,
        content: content,
        description: description,
        category: category,
        reason: reason,
        files: files,
      );

      if (response['success'] == true) {
        ToastUtils.showSuccessToast('query_created_successfully'.tr);
        // Refresh the queries list
        await refresh();
        return true;
      } else {
        ToastUtils.showErrorToast(response['message'] ?? 'error_occurred'.tr);
        return false;
      }
    } catch (error) {
      print('Error creating query: $error');
      ToastUtils.showErrorToast('error_occurred'.tr);
      return false;
    }
  }
}
