import '../entities/user_entity.dart';

abstract class AuthRepository {
  UserEntity? get currentUser;
  bool get isAuthenticated;
  Future<bool> login(String emailOrPhone, String password);
  Future<void> logout();
  Future<bool> register({
    required String name,
    required String phone,
    required String pin,
    required String role,
    String? grade,
    String? subject,
  });
}
