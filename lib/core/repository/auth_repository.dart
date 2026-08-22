import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/user_model.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  Future<UserModel> login(String username, String password) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.login,
      method: RequestType.post,
      body: {'username': username, 'password': password},
    );

    final data = response['data'];
    final user = UserModel.fromJson(data);

    await _storageService.saveSession(
      token: user.accessToken,
      username: user.username,
      role: user.role,
      userId: user.userId,
      memberId: user.memberId,
    );

    return user;
  }

  Future<void> logout() async {
    await _storageService.clearSession();
  }

  bool isLoggedIn() => _storageService.hasSession();
  String? getUsername() => _storageService.getUsername();
  String? getRole() => _storageService.getRole();
  bool isAdmin() => _storageService.isAdmin();
  int? getMemberId() => _storageService.getMemberId();
}
