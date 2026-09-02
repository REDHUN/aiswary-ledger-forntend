import '../core/model/category_report_model.dart';
import '../core/model/meeting_report_model.dart';
import '../core/model/monthly_ledger_report_model.dart';
import '../core/model/member_personal_report_model.dart';
import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/reports_repository.dart';
import '../core/model/member_balance_report_model.dart';

import '../core/model/completed_meeting_register_model.dart';

class ReportsViewModel extends ChangeNotifier {
  CompletedMeetingRegisterModel? _completedRegister;
  CompletedMeetingRegisterModel? get completedRegister => _completedRegister;
  final LoadState registerState = LoadState();

  Future<void> fetchCompletedMeetingRegister(int meetingId) async {
    registerState.loading();
    notifyListeners();
    try {
      _completedRegister = await _repository.getCompletedMeetingRegister(
        meetingId,
      );
      registerState.success();
    } catch (e) {
      registerState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMeetings() async {
    loadState.loading();
    notifyListeners();
    try {
      _meetingReports = await _repository.getAllMeetingReports();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  void selectMeetingReport(MeetingReportModel report) {
    _selectedMeetingReport = report;
    notifyListeners();
  }

  List<MeetingReportModel> _meetingReports = [];
  MonthlyLedgerReportModel? _monthlyLedgerReport;

  MonthlyLedgerReportModel? get monthlyLedgerReport => _monthlyLedgerReport;
  List<MeetingReportModel> get meetingReports => _meetingReports;

  MeetingReportModel? _selectedMeetingReport;
  MeetingReportModel? get selectedMeetingReport => _selectedMeetingReport;
  final ReportsRepository _repository;
  final LoadState loadState = LoadState();

  CategoryReportModel? _categoryReport;
  CategoryReportModel? get categoryReport => _categoryReport;

  List<MemberBalanceReportModel> _memberBalances = [];
  List<MemberBalanceReportModel> get memberBalances => _memberBalances;

  MemberPersonalReportModel? _memberPersonalReport;
  MemberPersonalReportModel? get memberPersonalReport => _memberPersonalReport;
  MemberBalanceReportModel? _selectedMemberForReport;
  MemberBalanceReportModel? get selectedMemberForReport => _selectedMemberForReport;
  final LoadState memberPersonalReportState = LoadState();

  String? _startDate;
  String? get startDate => _startDate;

  String? _endDate;
  String? get endDate => _endDate;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<MemberBalanceReportModel> get filteredMemberBalances {
    if (_searchQuery.isEmpty) return _memberBalances;
    final q = _searchQuery.toLowerCase();
    return _memberBalances
        .where(
          (m) =>
              m.fullName.toLowerCase().contains(q) ||
              m.memberNumber.toLowerCase().contains(q) ||
              (m.phone != null && m.phone!.contains(q)),
        )
        .toList();
  }

  ReportsViewModel(this._repository);

  Future<void> fetchAllReports() async {
    loadState.loading();
    notifyListeners();

    try {
      _memberBalances = await _repository.getMemberBalancesReport();
      _categoryReport = await _repository.getCategoryReport();
      _meetingReports = await _repository.getAllMeetingReports();
      if (_meetingReports.isNotEmpty && _selectedMeetingReport == null) {
        _selectedMeetingReport = _meetingReports.first;
      }
      if (_memberBalances.isNotEmpty && _selectedMemberForReport == null) {
        _selectedMemberForReport = _memberBalances.first;
        fetchMemberPersonalReport(_memberBalances.first.memberId);
      }
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMemberPersonalReport(int memberId, [String? yearMonth]) async {
    memberPersonalReportState.loading();
    notifyListeners();

    try {
      _memberPersonalReport = await _repository.getMemberPersonalReport(
        memberId,
        yearMonth,
      );
      memberPersonalReportState.success();
    } catch (e) {
      memberPersonalReportState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  void selectMemberForReport(MemberBalanceReportModel member, [String? yearMonth]) {
    _selectedMemberForReport = member;
    fetchMemberPersonalReport(member.memberId, yearMonth);
  }

  Future<void> fetchMonthlyLedgerReport(String yearMonth) async {
    try {
      _monthlyLedgerReport = await _repository.getMonthlyLedgerReport(
        yearMonth,
      );
      notifyListeners();
    } catch (e) {
      // keep existing
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
