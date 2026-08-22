import 'package:flutter/foundation.dart';
import '../core/state/load_state.dart';
import '../core/repository/auth_repository.dart';
import '../core/model/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final LoadState loadState = LoadState();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthViewModel(this._authRepository);

  bool get isLoggedIn => _authRepository.isLoggedIn();
  String? get username => _authRepository.getUsername();
  String? get role => _authRepository.getRole();
  bool get isAdmin => _authRepository.isAdmin();
  int? get memberId => _authRepository.getMemberId();

  Future<bool> login(String username, String password) async {
    loadState.loading();
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(username, password);
      loadState.success("Login successful");
      notifyListeners();
      return true;
    } catch (e) {
      loadState.error(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    loadState.clear();
    notifyListeners();
  }
}
