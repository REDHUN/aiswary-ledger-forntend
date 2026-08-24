import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/dashboard_repository.dart';
import '../core/model/dashboard_summary_model.dart';
import '../core/model/financial_transaction_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;
  final LoadState loadState = LoadState();
  final LoadState actionState = LoadState();

  DashboardSummaryModel? _summary;
  DashboardSummaryModel? get summary => _summary;

  List<FinancialTransactionModel> _recentTransactions = [];
  List<FinancialTransactionModel> get recentTransactions => _recentTransactions;

  DashboardViewModel(this._dashboardRepository);

  Future<void> fetchDashboardSummary() async {
    loadState.loading();
    notifyListeners();

    try {
      _summary = await _dashboardRepository.getDashboardSummary();
      _recentTransactions = await _dashboardRepository.getRecentTransactions();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> reverseTransaction(int txId, String reason) async {
    actionState.loading();
    notifyListeners();

    try {
      await _dashboardRepository.reverseTransaction(txId, reason);
      actionState.success("Transaction #$txId reversed successfully!");
      fetchDashboardSummary();
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }
}
