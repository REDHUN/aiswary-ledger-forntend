import 'package:ashgledger/core/network/api_client.dart';
import 'package:ashgledger/core/network/api_endpoints.dart';
import 'package:ashgledger/core/model/member_model.dart';
import 'package:ashgledger/core/model/member_account_model.dart';
import 'package:ashgledger/core/model/financial_transaction_model.dart';

class MemberRepository {
  final ApiClient _apiClient;

  MemberRepository(this._apiClient);

  Future<List<MemberModel>> getMembers({int page = 0, int size = 100, String? query}) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.members(page: page, size: size, query: query),
      method: RequestType.get,
    );

    List rawList = [];
    if (response['data'] is List) {
      rawList = response['data'];
    } else if (response['data'] is Map && response['data']['content'] is List) {
      rawList = response['data']['content'];
    }

    return rawList.map((m) => MemberModel.fromJson(m)).toList();
  }

  Future<MemberModel> createMember({
    required String memberNumber,
    required String fullName,
    required String username,
    required String password,
    String? phone,
    String? address,
    String? joiningDate,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.membersPath,
      method: RequestType.post,
      body: {
        'memberNumber': memberNumber,
        'fullName': fullName,
        'username': username,
        'password': password,
        'phone': phone,
        'address': address,
        'joiningDate': joiningDate,
      },
    );
    return MemberModel.fromJson(response['data']);
  }

  Future<MemberModel> updateMember(
    int id, {
    String? fullName,
    String? phone,
    String? address,
    bool? isActive,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.memberDetails(id),
      method: RequestType.put,
      body: {
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'isActive': isActive,
      }..removeWhere((key, value) => value == null),
    );
    return MemberModel.fromJson(response['data']);
  }

  Future<MemberModel> getMemberById(int id) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.memberDetails(id),
      method: RequestType.get,
    );
    return MemberModel.fromJson(response['data']);
  }

  Future<List<MemberAccountModel>> getMemberAccounts(int id) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.memberAccounts(id),
      method: RequestType.get,
    );
    final data = response['data'] as List? ?? [];
    return data.map((a) => MemberAccountModel.fromJson(a)).toList();
  }

  Future<List<FinancialTransactionModel>> getMemberTransactions(int id, {int page = 0, int size = 50}) async {
    final response = await _apiClient.request(
      path: '${ApiEndpoints.memberTransactions(id)}?page=$page&size=$size',
      method: RequestType.get,
    );

    List rawList = [];
    if (response['data'] is List) {
      rawList = response['data'];
    } else if (response['data'] is Map && response['data']['content'] is List) {
      rawList = response['data']['content'];
    }

    return rawList.map((t) => FinancialTransactionModel.fromJson(t)).toList();
  }

  Future<void> issueLoan(int memberId, double amount, {int? meetingId, int? specialLoanTypeId, String? description, String? transactionDate}) async {
    await _apiClient.request(
      path: ApiEndpoints.memberLoans(memberId),
      method: RequestType.post,
      body: {
        'amount': amount,
        'meetingId': specialLoanTypeId != null ? null : meetingId,
        'specialLoanTypeId': specialLoanTypeId,
        'description': description,
        'transactionDate': transactionDate,
      },
    );
  }


  Future<void> addDeposit(int memberId, double amount, {int? meetingId, String? description, String? transactionDate}) async {
    await _apiClient.request(
      path: ApiEndpoints.memberDeposits(memberId),
      method: RequestType.post,
      body: {
        'amount': amount,
        'meetingId': meetingId,
        'description': description,
        'transactionDate': transactionDate,
      },
    );
  }


  Future<void> addFine(int memberId, double amount, {int? meetingId, String? description, String? transactionDate}) async {
    await _apiClient.request(
      path: ApiEndpoints.memberFines(memberId),
      method: RequestType.post,
      body: {
        'amount': amount,
        'meetingId': null,
        'description': description,
        'transactionDate': transactionDate,
      },
    );
  }
  Future<void> addContribution(int memberId, double amount, {int? meetingId, String? description, String? transactionDate}) async {
    await _apiClient.request(
      path: ApiEndpoints.memberContributions(memberId),
      method: RequestType.post,
      body: {'amount': amount, 'meetingId': meetingId, 'description': description},
    );
  }

  Future<void> addFinancialAid(int memberId, double amount, {int? meetingId, String? description, String? transactionDate}) async {
    await _apiClient.request(
      path: ApiEndpoints.memberFinancialAid(memberId),
      method: RequestType.post,
      body: {'amount': amount, 'meetingId': meetingId, 'description': description},
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

  Future<void> reverseTransaction(int txId, String reason) async {
    await _apiClient.request(
      path: ApiEndpoints.reverseTransaction(txId),
      method: RequestType.post,
      body: {'reason': reason},
    );
  }
}
