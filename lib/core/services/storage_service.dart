import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'jwt_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUsername = 'username';
  static const String _keyRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyMemberId = 'member_id';
  static const String _keyFcmToken = 'fcm_token';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveSession({
    required String token,
    String? refreshToken,
    required String username,
    required String role,
    required int userId,
    int? memberId,
  }) async {
    await _prefs.setString(_keyToken, token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString(_keyRefreshToken, refreshToken);
    } else {
      await _prefs.remove(_keyRefreshToken);
    }
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyRole, role);
    await _prefs.setInt(_keyUserId, userId);
    if (memberId != null) {
      await _prefs.setInt(_keyMemberId, memberId);
    } else {
      await _prefs.remove(_keyMemberId);
    }
  }

  String? getToken() => _prefs.getString(_keyToken);
  String? getRefreshToken() => _prefs.getString(_keyRefreshToken);
  Future<void> saveToken(String token) async => await _prefs.setString(_keyToken, token);
  Future<void> saveRefreshToken(String token) async => await _prefs.setString(_keyRefreshToken, token);
  String? getUsername() => _prefs.getString(_keyUsername);
  String? getRole() => _prefs.getString(_keyRole);
  int? getUserId() => _prefs.getInt(_keyUserId);
  int? getMemberId() => _prefs.getInt(_keyMemberId);
  bool isAdmin() => getRole() == 'ADMIN';

  Future<void> saveFcmToken(String token) async {
    await _prefs.setString(_keyFcmToken, token);
  }

  String? getFcmToken() => _prefs.getString(_keyFcmToken);

  Future<void> clearFcmToken() async {
    await _prefs.remove(_keyFcmToken);
  }

  bool hasSession() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyMemberId);
    await _prefs.remove(_keyFcmToken);
  }
}

