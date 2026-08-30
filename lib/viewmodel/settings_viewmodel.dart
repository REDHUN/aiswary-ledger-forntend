import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/settings_repository.dart';
import '../core/model/special_loan_type_model.dart';

class SettingsViewModel extends ChangeNotifier {
  double _surplusAmount = 0.0;
  double get surplusAmount => _surplusAmount;

  Future<void> fetchSurplusAmount() async {
    try {
      _surplusAmount = await _settingsRepository.getSurplusAmount();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching surplus amount: $e");
    }
  }

  Future<bool> updateSurplusAmount(double amount, {String? description, int? meetingId}) async {
    loadState.loading();
    notifyListeners();

    try {
      _surplusAmount = await _settingsRepository.updateSurplusAmount(
        amount,
        description: description,
        meetingId: meetingId,
      );
      loadState.success("Surplus amount updated successfully");
      return true;
    } catch (e) {
      loadState.error(e.toString());
      return false;
    } finally {
      notifyListeners();
    }
  }
  final SettingsRepository _settingsRepository;
  final LoadState loadState = LoadState();

  List<SpecialLoanTypeModel> _specialLoanTypes = [];
  List<SpecialLoanTypeModel> get specialLoanTypes => _specialLoanTypes;

  SettingsViewModel(this._settingsRepository);

  Future<void> fetchSpecialLoanTypes() async {
    loadState.loading();
    notifyListeners();

    try {
      _specialLoanTypes = await _settingsRepository.getSpecialLoanTypes(activeOnly: false);
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createSpecialLoanType(String name, String? description) async {
    try {
      await _settingsRepository.createSpecialLoanType(name: name, description: description);
      await fetchSpecialLoanTypes();
      return true;
    } catch (e) {
      loadState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleSpecialLoanType(SpecialLoanTypeModel item) async {
    try {
      await _settingsRepository.updateSpecialLoanType(
        id: item.id,
        name: item.name,
        description: item.description,
        isActive: !item.isActive,
      );
      await fetchSpecialLoanTypes();
      return true;
    } catch (e) {
      loadState.error(e.toString());
      notifyListeners();
      return false;
    }
  }
}
