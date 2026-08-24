import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/member_group_model.dart';
import '../model/group_loan_summary_model.dart';

class GroupRepository {
  final ApiClient _apiClient;

  GroupRepository(this._apiClient);

  Future<List<MemberGroupModel>> getGroups() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.groups,
      method: RequestType.get,
    );
    final List data = response['data'] as List? ?? [];
    return data.map((x) => MemberGroupModel.fromJson(x)).toList();
  }

  Future<MemberGroupModel> getGroupById(int id) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.groupDetails(id),
      method: RequestType.get,
    );
    return MemberGroupModel.fromJson(response['data']);
  }

  Future<MemberGroupModel> createGroup({
    required String name,
    String? description,
    List<int>? memberIds,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.groups,
      method: RequestType.post,
      body: {
        'name': name,
        'description': description,
        'isActive': true,
        'memberIds': memberIds,
      },
    );
    return MemberGroupModel.fromJson(response['data']);
  }

  Future<MemberGroupModel> updateGroup({
    required int id,
    required String name,
    String? description,
    required bool isActive,
    List<int>? memberIds,
  }) async {
    final response = await _apiClient.request(
      path: '${ApiEndpoints.groups}/$id',
      method: RequestType.put,
      body: {
        'name': name,
        'description': description,
        'isActive': isActive,
        'memberIds': memberIds,
      },
    );
    return MemberGroupModel.fromJson(response['data']);
  }

  Future<void> deleteGroup(int id) async {
    await _apiClient.request(
      path: '${ApiEndpoints.groups}/$id',
      method: RequestType.delete,
    );
  }

  Future<GroupLoanSummaryModel> issueGroupLoan({
    int? groupId,
    required List<int> memberIds,
    int? specialLoanTypeId,
    required double totalAmount,
    String? notes,
    String? transactionDate,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.issueGroupLoan,
      method: RequestType.post,
      body: {
        'groupId': groupId,
        'memberIds': memberIds,
        'specialLoanTypeId': specialLoanTypeId,
        'totalAmount': totalAmount,
        'notes': notes,
        'transactionDate': transactionDate,
      },
    );
    return GroupLoanSummaryModel.fromJson(response['data']);
  }

  Future<List<GroupLoanSummaryModel>> getGroupLoansHistory() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.groupLoans,
      method: RequestType.get,
    );
    final List data = response['data'] as List? ?? [];
    return data.map((x) => GroupLoanSummaryModel.fromJson(x)).toList();
  }
}
