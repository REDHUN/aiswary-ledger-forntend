import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/member_processing_data_model.dart';

class MemberProcessingRepository {
  final ApiClient _apiClient;

  MemberProcessingRepository(this._apiClient);

  Future<MemberProcessingDataModel> getProcessingForm(int meetingId, int memberId) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.memberProcessingForm(meetingId, memberId),
      method: RequestType.get,
    );
    return MemberProcessingDataModel.fromJson(response['data']);
  }

  Future<void> processMember({
    bool isUpdate = false,
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
    String? interestPeriod,
    required String idempotencyKey,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.processMember(meetingId, memberId, isUpdate: isUpdate),
      method: isUpdate ? RequestType.put : RequestType.post,
      headers: {'X-Idempotency-Key': idempotencyKey},
      body: {
        'loanRepayment': loanRepayment,
        'interestPayment': interestPayment,
        'depositAddition': depositAddition,
        'finePayment': finePayment,
        'financialAidPayment': financialAidPayment,
        'monthlyContributionAddition': monthlyContributionAddition,
        'specialLoanRepayments': specialLoanRepayments,
        'notes': notes,
        'isUpdate': isUpdate,
        'transactionDate': ?transactionDate,
        'interestPeriod': ?interestPeriod,
      },
    );
  }

  Future<void> calculateInterest(int memberId, String interestPeriod, {int? meetingId}) async {
    await _apiClient.request(
      path: ApiEndpoints.memberCalculateInterest(memberId),
      method: RequestType.post,
      body: {
        'interestPeriod': interestPeriod,
        'meetingId': meetingId,
      },
    );
  }
}

