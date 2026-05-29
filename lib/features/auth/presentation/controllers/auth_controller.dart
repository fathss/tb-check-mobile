import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

// Provider untuk mengakses AuthController di sisi UI
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  Future<void> login(String email, String password) async {
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.login(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.register(username, email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final repository = _ref.read(authRepositoryProvider);
      await repository.logout();
    } catch (e) {
      rethrow;
    }
  }
}
