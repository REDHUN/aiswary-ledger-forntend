import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/special_loan_type_model.dart';

class SettingsRepository {
  Future<double> getSurplusAmount() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.surplusAmount,
      method: RequestType.get,
    );
    return (response['data'] ?? 0.0).toDouble();
  }

  Future<double> updateSurplusAmount(double amount, {String? description, int? meetingId}) async {
    final body = <String, dynamic>{'surplusAmount': amount};
    if (description != null && description.isNotEmpty) body['description'] = description;
    if (meetingId != null) body['meetingId'] = meetingId;
    final response = await _apiClient.request(
      path: ApiEndpoints.surplusAmount,
      method: RequestType.post,
      body: body,
    );
    return (response['data'] ?? 0.0).toDouble();
  }
  final ApiClient _apiClient;

  SettingsRepository(this._apiClient);

  Future<List<SpecialLoanTypeModel>> getSpecialLoanTypes({bool activeOnly = false}) async {
    final response = await _apiClient.request(
      path: '${ApiEndpoints.specialLoanTypes}?activeOnly=$activeOnly',
      method: RequestType.get,
    );
    final List data = response['data'] as List? ?? [];
    return data.map((x) => SpecialLoanTypeModel.fromJson(x)).toList();
  }

  Future<SpecialLoanTypeModel> createSpecialLoanType({
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.specialLoanTypes,
      method: RequestType.post,
      body: {
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
        'isActive': true,
      },
    );
    return SpecialLoanTypeModel.fromJson(response['data']);
  }

  Future<SpecialLoanTypeModel> updateSpecialLoanType({
    required int id,
    required String name,
    String? description,
    required bool isActive,
  }) async {
    final response = await _apiClient.request(
      path: '${ApiEndpoints.specialLoanTypes}/$id',
      method: RequestType.put,
      body: {
        'name': name,
        'description': description,
        'isActive': isActive,
      },
    );
    return SpecialLoanTypeModel.fromJson(response['data']);
  }
}
