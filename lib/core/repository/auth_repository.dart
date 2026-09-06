import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../model/user_model.dart';
import '../services/storage_service.dart';
import '../services/fcm_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final FcmService _fcmService;

  AuthRepository(this._apiClient, this._storageService, this._fcmService);

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
      refreshToken: user.refreshToken,
      username: user.username,
      role: user.role,
      userId: user.userId,
      memberId: user.memberId,
    );

    // Get FCM token upon successful login
    try {
      await _fcmService.requestPermission();
      await _fcmService.getToken();
    } catch (_) {
      // Continue even if FCM fails
    }

    return user;
  }

  Future<void> logout() async {
    // Delete FCM token upon logout
    try {
      await _fcmService.deleteToken();
    } catch (_) {}

    await _storageService.clearSession();
  }

  bool isLoggedIn() => _storageService.hasSession();
  String? getToken() => _storageService.getToken();
  String? getRefreshToken() => _storageService.getRefreshToken();
  String? getUsername() => _storageService.getUsername();
  String? getRole() => _storageService.getRole();
  bool isAdmin() => _storageService.isAdmin();
  int? getMemberId() => _storageService.getMemberId();
}
