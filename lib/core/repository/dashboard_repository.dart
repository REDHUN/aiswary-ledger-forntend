import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/dashboard_summary_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardSummaryModel> getSummary() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.dashboardSummary,
      method: RequestType.get,
    );
    return DashboardSummaryModel.fromJson(response['data']);
  }
}
