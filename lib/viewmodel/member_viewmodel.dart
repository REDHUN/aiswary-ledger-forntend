import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/member_repository.dart';
import '../core/model/member_model.dart';
import '../core/model/member_account_model.dart';
import '../core/model/financial_transaction_model.dart';

class MemberViewModel extends ChangeNotifier {
  final MemberRepository _memberRepository;
  final LoadState loadState = LoadState();
  final LoadState actionState = LoadState();

  List<MemberModel> _members = [];
  List<MemberModel> get members => _members;

  MemberModel? _selectedMember;
  MemberModel? get selectedMember => _selectedMember;

  List<MemberAccountModel> _accounts = [];
  List<MemberAccountModel> get accounts => _accounts;

  List<FinancialTransactionModel> _transactions = [];
  List<FinancialTransactionModel> get transactions => _transactions;

  MemberViewModel(this._memberRepository);

  Future<void> fetchMembers() async {
    loadState.loading();
    notifyListeners();

    try {
      _members = await _memberRepository.getMembers();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMemberDetail(int memberId) async {
    loadState.loading();
    notifyListeners();

    try {
      _selectedMember = await _memberRepository.getMemberById(memberId);
      _accounts = await _memberRepository.getMemberAccounts(memberId);
      _transactions = await _memberRepository.getMemberTransactions(memberId);
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createMember({
    required String memberNumber,
    required String fullName,
    required String username,
    required String password,
    String? phone,
    String? address,
    String? joiningDate,
  }) async {
    actionState.loading();
    notifyListeners();

    try {
      await _memberRepository.createMember(
        memberNumber: memberNumber,
        fullName: fullName,
        username: username,
        password: password,
        phone: phone,
        address: address,
        joiningDate: joiningDate,
      );
      actionState.success("Member created successfully");
      fetchMembers();
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> issueLoan(int memberId, double amount, {int? meetingId, String? description}) async {
    actionState.loading();
    notifyListeners();

    try {
      await _memberRepository.issueLoan(memberId, amount, meetingId: meetingId, description: description);
      actionState.success("Loan issued successfully");
      loadMemberDetail(memberId);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }


  Future<bool> addDeposit(int memberId, double amount, {int? meetingId, String? description}) async {
    actionState.loading();
    notifyListeners();

    try {
      await _memberRepository.addDeposit(memberId, amount, meetingId: meetingId, description: description);
      actionState.success("Deposit recorded successfully");
      loadMemberDetail(memberId);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }


  Future<bool> addFine(int memberId, double amount, {int? meetingId, String? description}) async {
    actionState.loading();
    notifyListeners();
    try {
      await _memberRepository.addFine(memberId, amount, meetingId: meetingId, description: description);
      actionState.success("Fine recorded successfully");
      loadMemberDetail(memberId);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> addContribution(int memberId, double amount, {int? meetingId, String? description}) async {
    actionState.loading();
    notifyListeners();
    try {
      await _memberRepository.addContribution(memberId, amount, meetingId: meetingId, description: description);
      actionState.success("Monthly contribution recorded successfully");
      loadMemberDetail(memberId);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> addFinancialAid(int memberId, double amount, {int? meetingId, String? description}) async {
    actionState.loading();
    notifyListeners();
    try {
      await _memberRepository.addFinancialAid(memberId, amount, meetingId: meetingId, description: description);
      actionState.success("Financial aid recorded successfully");
      loadMemberDetail(memberId);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> calculateInterest(int memberId, String interestPeriod, {int? meetingId}) async {
    actionState.loading();
    notifyListeners();

    try {
      await _memberRepository.calculateInterest(memberId, interestPeriod, meetingId: meetingId);
      actionState.success("Monthly interest calculated successfully");
      loadMemberDetail(memberId);
      return true;
    } catch (e) {
      actionState.error(e.toString());
      notifyListeners();
      return false;
    }
  }
}
