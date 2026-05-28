import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/user_management_datasoure.dart';
import '../models/user_detail_model.dart';
import '../models/user_model.dart';

final userManagementRepositoryProvider = Provider<UserManagementRepository>((
  ref,
) {
  final datasource = ref.watch(userManagementDatasourceProvider);
  return UserManagementRepository(datasource);
});

class UserManagementRepository {
  final UserManagementDatasource _datasource;

  UserManagementRepository(this._datasource);

  Future<List<UserModel>> getAllUsers() async {
    try {
      return await _datasource.getAllUsers();
    } catch (e) {
      throw Exception('Gagal memuat data pengguna: ${e.toString()}');
    }
  }

  Future<UserDetailModel> getUserById(String userId) async {
    try {
      return await _datasource.getUserById(userId);
    } catch (e) {
      throw Exception('Gagal memuat detail pengguna: ${e.toString()}');
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      await _datasource.activateUser(userId);
    } catch (e) {
      throw Exception('Gagal mengaktifkan akun pengguna: ${e.toString()}');
    }
  }

  Future<void> suspendUser(String userId) async {
    try {
      await _datasource.suspendUser(userId);
    } catch (e) {
      throw Exception('Gagal menonaktifkan akun pengguna: ${e.toString()}');
    }
  }
}
