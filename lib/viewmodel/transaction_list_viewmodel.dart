import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/dashboard_repository.dart';
import '../core/model/financial_transaction_model.dart';

class TransactionListViewModel extends ChangeNotifier {
  final DashboardRepository _repository;
  final LoadState loadState = LoadState();
  final LoadState actionState = LoadState();

  List<FinancialTransactionModel> _transactions = [];
  List<FinancialTransactionModel> get transactions => _transactions;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalElements = 0;
  int get totalElements => _totalElements;

  // Search & Filter State
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _selectedAccountType;
  String? get selectedAccountType => _selectedAccountType;

  String? _selectedTransactionType;
  String? get selectedTransactionType => _selectedTransactionType;

  bool? _isReversed;
  bool? get isReversed => _isReversed;

  String? _startDate;
  String? get startDate => _startDate;

  String? _endDate;
  String? get endDate => _endDate;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedAccountType != null ||
      _selectedTransactionType != null ||
      _isReversed != null ||
      _startDate != null ||
      _endDate != null;

  TransactionListViewModel(this._repository);

  Future<void> fetchTransactions({int page = 0, int size = 20}) async {
    loadState.loading();
    notifyListeners();

    try {
      final res = await _repository.getAllTransactions(
        page: page,
        size: size,
        query: _searchQuery,
        accountType: _selectedAccountType,
        transactionType: _selectedTransactionType,
        isReversed: _isReversed,
        startDate: _startDate,
        endDate: _endDate,
      );
      _transactions = res['items'] as List<FinancialTransactionModel>;
      _currentPage = res['page'] as int;
      _totalPages = res['totalPages'] as int;
      _totalElements = res['totalElements'] as int;
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  void setSearchQuery(String q) {
    if (_searchQuery != q) {
      _searchQuery = q;
      fetchTransactions(page: 0);
    }
  }

  void setAccountTypeFilter(String? type) {
    if (_selectedAccountType != type) {
      _selectedAccountType = type;
      fetchTransactions(page: 0);
    }
  }

  void setReversedFilter(bool? reversed) {
    if (_isReversed != reversed) {
      _isReversed = reversed;
      fetchTransactions(page: 0);
    }
  }

  void setDateRange(String? start, String? end) {
    _startDate = start;
    _endDate = end;
    fetchTransactions(page: 0);
  }

  void clearAllFilters() {
    _searchQuery = '';
    _selectedAccountType = null;
    _selectedTransactionType = null;
    _isReversed = null;
    _startDate = null;
    _endDate = null;
    fetchTransactions(page: 0);
  }

  Future<void> nextPage() async {
    if (_currentPage < _totalPages - 1) {
      await fetchTransactions(page: _currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 0) {
      await fetchTransactions(page: _currentPage - 1);
    }
  }

  Future<bool> reverseTransaction(int txId, String reason) async {
    actionState.loading();
    notifyListeners();

    try {
      await _repository.reverseTransaction(txId, reason);
      actionState.success("Transaction #$txId reversed successfully!");
      fetchTransactions(page: _currentPage);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }
}
