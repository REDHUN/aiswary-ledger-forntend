import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/group_profit_model.dart';

class GroupProfitRepository {
  final ApiClient _apiClient;

  GroupProfitRepository(this._apiClient);

  Future<List<GroupProfitModel>> getGroupProfits() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.groupProfits,
      method: RequestType.get,
    );
    final data = response['data'];
    if (data is List) {
      return data.map((x) => GroupProfitModel.fromJson(x)).toList();
    }
    return [];
  }

  Future<GroupProfitModel> createGroupProfit({
    required String title,
    required double amount,
    required String profitDate,
    String? description,
    int? meetingId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'amount': amount,
      'profitDate': profitDate,
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (meetingId != null) {
      body['meetingId'] = meetingId;
    }

    final response = await _apiClient.request(
      path: ApiEndpoints.groupProfits,
      method: RequestType.post,
      body: body,
    );
    return GroupProfitModel.fromJson(response['data']);
  }

  Future<GroupProfitModel> updateGroupProfit({
    required int id,
    required String title,
    required double amount,
    required String profitDate,
    String? description,
    int? meetingId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'amount': amount,
      'profitDate': profitDate,
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    if (meetingId != null) {
      body['meetingId'] = meetingId;
    }

    final response = await _apiClient.request(
      path: ApiEndpoints.groupProfitDetails(id),
      method: RequestType.put,
      body: body,
    );
    return GroupProfitModel.fromJson(response['data']);
  }

  Future<void> deleteGroupProfit(int id) async {
    await _apiClient.request(
      path: ApiEndpoints.groupProfitDetails(id),
      method: RequestType.delete,
    );
  }
}