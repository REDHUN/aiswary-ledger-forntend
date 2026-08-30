import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/group_repository.dart';
import '../core/model/member_group_model.dart';
import '../core/model/group_loan_summary_model.dart';

class GroupViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final LoadState loadState = LoadState();
  final LoadState actionState = LoadState();

  List<MemberGroupModel> _groups = [];
  List<MemberGroupModel> get groups => _groups;

  List<GroupLoanSummaryModel> _loanHistory = [];
  List<GroupLoanSummaryModel> get loanHistory => _loanHistory;

  GroupViewModel(this._groupRepository);

  Future<void> fetchGroups() async {
    loadState.loading();
    notifyListeners();

    try {
      _groups = await _groupRepository.getGroups();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchLoanHistory() async {
    try {
      _loanHistory = await _groupRepository.getGroupLoansHistory();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching group loans history: $e");
    }
  }

  Future<bool> createGroup(String name, String? description, List<int> memberIds) async {
    actionState.loading();
    notifyListeners();

    try {
      await _groupRepository.createGroup(name: name, description: description, memberIds: memberIds);
      await fetchGroups();
      actionState.success("Group created successfully");
      return true;
    } catch (e) {
      actionState.error(e.toString());
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateGroup(int id, String name, String? description, bool isActive, List<int> memberIds) async {
    actionState.loading();
    notifyListeners();

    try {
      await _groupRepository.updateGroup(id: id, name: name, description: description, isActive: isActive, memberIds: memberIds);
      await fetchGroups();
      actionState.success("Group updated successfully");
      return true;
    } catch (e) {
      actionState.error(e.toString());
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> issueGroupLoan({
    int? groupId,
    int? meetingId,
    required List<int> memberIds,
    int? specialLoanTypeId,
    required double totalAmount,
    String? notes,
    String? transactionDate,
  }) async {
    actionState.loading();
    notifyListeners();

    try {
      await _groupRepository.issueGroupLoan(
        groupId: groupId,
        meetingId: meetingId,
        memberIds: memberIds,
        specialLoanTypeId: specialLoanTypeId,
        totalAmount: totalAmount,
        notes: notes,
        transactionDate: transactionDate,
      );
      await fetchLoanHistory();
      actionState.success("Group loan issued successfully!");
      return true;
    } catch (e) {
      actionState.error(e.toString());
      return false;
    } finally {
      notifyListeners();
    }
  }
}
