import 'package:flutter/foundation.dart';
import '../core/model/expense_type_model.dart';
import '../core/model/group_expense_model.dart';
import '../core/repository/expense_repository.dart';
import '../core/state/load_state.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;
  final LoadState loadState = LoadState();

  ExpenseViewModel(this._repository);

  List<ExpenseTypeModel> _expenseTypes = [];
  List<GroupExpenseModel> _groupExpenses = [];

  List<ExpenseTypeModel> get expenseTypes => _expenseTypes;
  List<GroupExpenseModel> get groupExpenses => _groupExpenses;

  Future<void> fetchExpenseTypes() async {
    loadState.loading();
    notifyListeners();
    try {
      _expenseTypes = await _repository.getExpenseTypes();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    }
    notifyListeners();
  }

  Future<bool> createExpenseType(String name, {String? description}) async {
    try {
      await _repository.createExpenseType(name, description: description);
      await fetchExpenseTypes();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteExpenseType(int id) async {
    try {
      await _repository.deleteExpenseType(id);
      await fetchExpenseTypes();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchGroupExpenses() async {
    loadState.loading();
    notifyListeners();
    try {
      _groupExpenses = await _repository.getGroupExpenses();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    }
    notifyListeners();
  }

  Future<bool> createGroupExpense({
    required int expenseTypeId,
    required double amount,
    String? expenseDate,
    String? description,
    int? meetingId,
  }) async {
    try {
      await _repository.createGroupExpense(
        expenseTypeId: expenseTypeId,
        amount: amount,
        expenseDate: expenseDate,
        description: description,
        meetingId: meetingId,
      );
      await fetchGroupExpenses();
      return true;
    } catch (e) {
      return false;
    }
  }
}
