import 'package:ashgledger/core/network/api_client.dart';
import 'package:ashgledger/core/network/api_endpoints.dart';
import 'package:ashgledger/core/model/expense_type_model.dart';
import 'package:ashgledger/core/model/group_expense_model.dart';

class ExpenseRepository {
  final ApiClient _apiClient;

  ExpenseRepository(this._apiClient);

  Future<List<ExpenseTypeModel>> getExpenseTypes() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.expenseTypes,
      method: RequestType.get,
    );
    final data = response['data'] as List? ?? [];
    return data.map((item) => ExpenseTypeModel.fromJson(item)).toList();
  }

  Future<ExpenseTypeModel> createExpenseType(String name, {String? description}) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.expenseTypes,
      method: RequestType.post,
      body: {
        'name': name,
        'description': description,
      },
    );
    return ExpenseTypeModel.fromJson(response['data']);
  }

  Future<void> deleteExpenseType(int id) async {
    await _apiClient.request(
      path: '${ApiEndpoints.expenseTypes}/$id',
      method: RequestType.delete,
    );
  }

  Future<List<GroupExpenseModel>> getGroupExpenses() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.groupExpenses,
      method: RequestType.get,
    );
    final data = response['data'] as List? ?? [];
    return data.map((item) => GroupExpenseModel.fromJson(item)).toList();
  }

  Future<GroupExpenseModel> createGroupExpense({
    required int expenseTypeId,
    required double amount,
    String? expenseDate,
    String? description,
    int? meetingId,
  }) async {
    final Map<String, dynamic> body = {
      'expenseTypeId': expenseTypeId,
      'amount': amount,
    };
    if (expenseDate != null) body['expenseDate'] = expenseDate;
    if (description != null) body['description'] = description;
    if (meetingId != null) body['meetingId'] = meetingId;

    final response = await _apiClient.request(
      path: ApiEndpoints.groupExpenses,
      method: RequestType.post,
      body: body,
    );
    return GroupExpenseModel.fromJson(response['data']);
  }
}
