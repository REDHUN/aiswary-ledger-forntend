import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/group_profit_repository.dart';
import '../core/model/group_profit_model.dart';

class GroupProfitViewModel extends ChangeNotifier {
  final GroupProfitRepository _repository;
  final LoadState loadState = LoadState();
  final LoadState actionState = LoadState();

  List<GroupProfitModel> _groupProfits = [];
  List<GroupProfitModel> get groupProfits => _groupProfits;

  GroupProfitViewModel(this._repository);

  Future<void> fetchGroupProfits() async {
    loadState.loading();
    notifyListeners();

    try {
      _groupProfits = await _repository.getGroupProfits();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> recordGroupProfit({
    required String title,
    required double amount,
    required String profitDate,
    String? description,
    int? meetingId,
  }) async {
    actionState.loading();
    notifyListeners();

    try {
      await _repository.createGroupProfit(
        title: title,
        amount: amount,
        profitDate: profitDate,
        description: description,
        meetingId: meetingId,
      );
      actionState.success("Profit recorded successfully!");
      fetchGroupProfits();
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }
}
