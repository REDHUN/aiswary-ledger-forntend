import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/member_processing_repository.dart';
import '../core/model/member_processing_data_model.dart';

class MemberProcessingViewModel extends ChangeNotifier {
  final MemberProcessingRepository _repository;
  final LoadState loadState = LoadState();
  final LoadState submitState = LoadState();

  MemberProcessingDataModel? _formData;
  MemberProcessingDataModel? get formData => _formData;

  MemberProcessingViewModel(this._repository);

  Future<void> fetchProcessingForm(int meetingId, int memberId) async {
    loadState.loading();
    notifyListeners();

    try {
      _formData = await _repository.getProcessingForm(meetingId, memberId);
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> submitProcessing({
    required int meetingId,
    required int memberId,
    required double loanRepayment,
    required double interestPayment,
    required double depositAddition,
    required double finePayment,
    required double financialAidPayment,
    required double monthlyContributionAddition,
    String? notes,
    List<Map<String, dynamic>>? specialLoanRepayments,
    String? transactionDate,
    bool isUpdate = false,
    String? interestPeriod,
  }) async {
    submitState.loading();
    notifyListeners();

    final idempotencyKey = 'tx-$meetingId-$memberId-${DateTime.now().millisecondsSinceEpoch}';

    try {
      await _repository.processMember(
        meetingId: meetingId,
        memberId: memberId,
        loanRepayment: loanRepayment,
        interestPayment: interestPayment,
        depositAddition: depositAddition,
        finePayment: finePayment,
        financialAidPayment: financialAidPayment,
        monthlyContributionAddition: monthlyContributionAddition,
        specialLoanRepayments: specialLoanRepayments,
        notes: notes,
        transactionDate: transactionDate,
        interestPeriod: interestPeriod,
        isUpdate: isUpdate,
        idempotencyKey: idempotencyKey,
      );
      submitState.success("Member payments processed successfully!");
      notifyListeners();
      return true;
    } catch (e) {
      submitState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> calculateInterest(int memberId, String interestPeriod, {int? meetingId}) async {
    submitState.loading();
    notifyListeners();

    try {
      await _repository.calculateInterest(memberId, interestPeriod, meetingId: meetingId);
      submitState.success("Interest calculated successfully");
      notifyListeners();
      return true;
    } catch (e) {
      submitState.error(e.toString());
      notifyListeners();
      return false;
    }
  }
}

