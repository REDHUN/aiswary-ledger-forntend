import '../model/category_report_model.dart';
import '../model/meeting_report_model.dart';
import '../model/monthly_ledger_report_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/member_balance_report_model.dart';

import '../model/completed_meeting_register_model.dart';
import '../model/member_personal_report_model.dart';

class ReportsRepository {
  Future<CompletedMeetingRegisterModel> getCompletedMeetingRegister(
    int meetingId,
  ) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.meetingRegisterBook(meetingId),
      method: RequestType.get,
    );
    return CompletedMeetingRegisterModel.fromJson(response['data']);
  }

  Future<MonthlyLedgerReportModel> getMonthlyLedgerReport(
    String yearMonth,
  ) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.reportMonthlyLedger(yearMonth),
      method: RequestType.get,
    );
    return MonthlyLedgerReportModel.fromJson(response['data']);
  }

  Future<List<MeetingReportModel>> getAllMeetingReports() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.reportMeetingsList,
      method: RequestType.get,
    );
    final data = response['data'] as List? ?? [];
    return data.map((x) => MeetingReportModel.fromJson(x)).toList();
  }

  Future<MeetingReportModel> getMeetingReport(int meetingId) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.reportMeetingDetails(meetingId),
      method: RequestType.get,
    );
    return MeetingReportModel.fromJson(response['data']);
  }

  final ApiClient _apiClient;

  ReportsRepository(this._apiClient);

  Future<List<MemberBalanceReportModel>> getMemberBalancesReport() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.reportMemberBalances,
      method: RequestType.get,
    );
    final data = response['data'] as List? ?? [];
    return data.map((x) => MemberBalanceReportModel.fromJson(x)).toList();
  }

  Future<CategoryReportModel> getCategoryReport() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.reportCategory,
      method: RequestType.get,
    );
    return CategoryReportModel.fromJson(response['data']);
  }

  Future<MemberPersonalReportModel> getMemberPersonalReport(
    int memberId,
    String? yearMonth,
  ) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.memberReport(memberId, yearMonth),
      method: RequestType.get,
    );
    return MemberPersonalReportModel.fromJson(response['data']);
  }
}
