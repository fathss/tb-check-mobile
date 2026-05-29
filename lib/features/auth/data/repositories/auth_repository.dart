import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/utils/jwt_utils.dart';
import '../datasources/auth_datasource.dart';
import '../datasources/auth_storage.dart';
import '../models/auth_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(authDatasourceProvider);
  final storage = ref.watch(authStorageProvider);
  return AuthRepository(datasource, storage);
});

class AuthRepository {
  final AuthDatasource _datasource;
  final AuthStorage _storage;

  AuthRepository(this._datasource, this._storage);

  Future<AuthModel> login(String email, String password) async {
    try {
      final data = await _datasource.login(email, password);
      final authModel = AuthModel.fromJson(data);
      final token = authModel.token;
      final decodedUserId = JwtUtils.userId(token);
      final decodedEmail = JwtUtils.email(token);
      final decodedRole = JwtUtils.role(token);

      await _storage.saveToken(token);
      if (decodedUserId != null && decodedUserId.isNotEmpty) {
        await _storage.saveUserId(decodedUserId);
      }
      if (decodedEmail != null && decodedEmail.isNotEmpty) {
        await _storage.saveEmail(decodedEmail);
      }
      if (decodedRole != null && decodedRole.isNotEmpty) {
        await _storage.saveRole(decodedRole);
      }

      return authModel;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      await _datasource.register(username, email, password);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    await _storage.clearSession();
  }
}
