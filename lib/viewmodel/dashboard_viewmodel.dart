import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/dashboard_repository.dart';
import '../core/model/dashboard_summary_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _dashboardRepository;
  final LoadState loadState = LoadState();

  DashboardSummaryModel? _summary;
  DashboardSummaryModel? get summary => _summary;

  DashboardViewModel(this._dashboardRepository);

  Future<void> fetchSummary() async {
    loadState.loading();
    notifyListeners();

    try {
      _summary = await _dashboardRepository.getSummary();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
