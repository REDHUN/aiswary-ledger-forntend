import 'package:ashgledger/core/network/api_client.dart';
import 'package:ashgledger/core/network/api_endpoints.dart';
import 'package:ashgledger/core/model/dashboard_summary_model.dart';
import 'package:ashgledger/core/model/financial_transaction_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardSummaryModel> getDashboardSummary() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.dashboardSummary,
      method: RequestType.get,
    );
    return DashboardSummaryModel.fromJson(response['data']);
  }

  Future<List<FinancialTransactionModel>> getRecentTransactions() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.recentTransactions,
      method: RequestType.get,
    );
    List rawList = [];
    if (response['data'] is List) {
      rawList = response['data'];
    } else if (response['data'] is Map && response['data']['content'] is List) {
      rawList = response['data']['content'];
    }
    return rawList.map((x) => FinancialTransactionModel.fromJson(x)).toList();
  }

  Future<Map<String, dynamic>> getAllTransactions({
    int page = 0,
    int size = 20,
    String? query,
    String? accountType,
    String? transactionType,
    bool? isReversed,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.allTransactions(
        page: page,
        size: size,
        query: query,
        accountType: accountType,
        transactionType: transactionType,
        isReversed: isReversed,
        startDate: startDate,
        endDate: endDate,
      ),
      method: RequestType.get,
    );
    final data = response['data'];
    List rawList = [];
    int totalPages = 1;
    int totalElements = 0;
    int currentPage = page;

    if (data is Map) {
      if (data['content'] is List) {
        rawList = data['content'];
      }
      if (data['totalPages'] != null) {
        totalPages = (data['totalPages'] as num).toInt();
      } else if (data['page'] != null && data['page']['totalPages'] != null) {
        totalPages = (data['page']['totalPages'] as num).toInt();
      }

      if (data['totalElements'] != null) {
        totalElements = (data['totalElements'] as num).toInt();
      } else if (data['page'] != null && data['page']['totalElements'] != null) {
        totalElements = (data['page']['totalElements'] as num).toInt();
      }

      if (data['number'] != null) {
        currentPage = (data['number'] as num).toInt();
      } else if (data['page'] != null && data['page']['number'] != null) {
        currentPage = (data['page']['number'] as num).toInt();
      }
    } else if (data is List) {
      rawList = data;
    }

    final items = rawList.map((x) => FinancialTransactionModel.fromJson(x)).toList();
    return {
      'items': items,
      'page': currentPage,
      'totalPages': totalPages,
      'totalElements': totalElements,
    };
  }

  Future<void> reverseTransaction(int txId, String reason) async {
    await _apiClient.request(
      path: ApiEndpoints.reverseTransaction(txId),
      method: RequestType.post,
      body: {'reason': reason},
    );
  }
}
