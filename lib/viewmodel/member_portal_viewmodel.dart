import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/model/member_model.dart';
import '../core/model/financial_transaction_model.dart';
import '../core/model/member_personal_report_model.dart';

class MemberPortalViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final LoadState loadState = LoadState();

  MemberModel? _memberProfile;
  MemberModel? get memberProfile => _memberProfile;

  List<FinancialTransactionModel> _myTransactions = [];
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  List<FinancialTransactionModel> get myTransactions => _myTransactions;

  MemberPersonalReportModel? _myReport;
  MemberPersonalReportModel? get myReport => _myReport;

  MemberPortalViewModel(this._apiClient);

  Future<void> fetchMyData() async {
    loadState.loading();
    notifyListeners();

    try {
      final profileResp = await _apiClient.request(
        path: ApiEndpoints.myProfile,
        method: RequestType.get,
      );
      _memberProfile = MemberModel.fromJson(profileResp['data']);

      final txResp = await _apiClient.request(
        path: ApiEndpoints.myTransactions(page: 0, size: 20),
        method: RequestType.get,
      );
      final txData = txResp['data'];
      final List content = txData['content'] as List? ?? [];
      _myTransactions = content.map((x) => FinancialTransactionModel.fromJson(x)).toList();
      _currentPage = txData['number'] ?? 0;
      _totalPages = txData['totalPages'] ?? 1;
      _totalElements = txData['totalElements'] ?? _myTransactions.length;

      final reportResp = await _apiClient.request(
        path: ApiEndpoints.myReport(null),
        method: RequestType.get,
      );
      _myReport = MemberPersonalReportModel.fromJson(reportResp['data']);

      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMyTransactionsPage(int page) async {
    loadState.loading();
    notifyListeners();
    try {
      final txResp = await _apiClient.request(
        path: ApiEndpoints.myTransactions(page: page, size: 20),
        method: RequestType.get,
      );
      final txData = txResp['data'];
      final List content = txData['content'] as List? ?? [];
      _myTransactions = content.map((x) => FinancialTransactionModel.fromJson(x)).toList();
      _currentPage = txData['number'] ?? page;
      _totalPages = txData['totalPages'] ?? 1;
      _totalElements = txData['totalElements'] ?? _myTransactions.length;
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMyReport(String yearMonth) async {
    try {
      final reportResp = await _apiClient.request(
        path: ApiEndpoints.myReport(yearMonth),
        method: RequestType.get,
      );
      _myReport = MemberPersonalReportModel.fromJson(reportResp['data']);
      notifyListeners();
    } catch (_) {}
  }
}
