import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/model/special_loan_type_model.dart';

class SpecialLoanTypeViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final LoadState loadState = LoadState();

  List<SpecialLoanTypeModel> _specialLoanTypes = [];
  List<SpecialLoanTypeModel> get specialLoanTypes => _specialLoanTypes;

  SpecialLoanTypeViewModel(this._apiClient);

  Future<void> fetchSpecialLoanTypes({bool activeOnly = false}) async {
    loadState.loading();
    notifyListeners();

    try {
      final response = await _apiClient.request(
        path: '${ApiEndpoints.specialLoanTypes}?activeOnly=$activeOnly',
        method: RequestType.get,
      );
      final List list = response['data'] as List? ?? [];
      _specialLoanTypes = list.map((e) => SpecialLoanTypeModel.fromJson(e)).toList();
      loadState.success();
    } catch (e) {
      loadState.error(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createSpecialLoanType(String name, String? description) async {
    try {
      await _apiClient.request(
        path: ApiEndpoints.specialLoanTypes,
        method: RequestType.post,
        body: {'name': name, 'description': description},
      );
      await fetchSpecialLoanTypes();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleActive(int id, bool currentActive) async {
    try {
      await _apiClient.request(
        path: '${ApiEndpoints.specialLoanTypes}/$id',
        method: RequestType.put,
        body: {'isActive': !currentActive},
      );
      await fetchSpecialLoanTypes();
      return true;
    } catch (e) {
      return false;
    }
  }
}
