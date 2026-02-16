import 'package:flutter/foundation.dart';
import 'package:high_school/domain/entities/user_entity.dart';
import 'package:high_school/domain/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  UserEntity? get user => _authRepository.currentUser;
  bool get isAuthenticated => _authRepository.isAuthenticated;

  Future<bool> login(String emailOrPhone, String password) async {
    final ok = await _authRepository.login(emailOrPhone, password);
    if (ok) notifyListeners();
    return ok;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String pin,
    required String role,
    String? grade,
    String? subject,
  }) async {
    final ok = await _authRepository.register(name: name, phone: phone, pin: pin, role: role, grade: grade, subject: subject);
    if (ok) notifyListeners();
    return ok;
  }
}
