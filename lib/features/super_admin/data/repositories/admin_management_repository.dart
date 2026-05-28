import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/admin_management_datasource.dart';
import '../models/create_admin_model.dart';
import '../models/user_detail_model.dart';

final adminManagementRepositoryProvider = Provider<AdminManagementRepository>((
  ref,
) {
  final datasource = ref.watch(adminManagementDatasourceProvider);
  return AdminManagementRepository(datasource);
});

class AdminManagementRepository {
  final AdminManagementDatasource _datasource;

  AdminManagementRepository(this._datasource);

  Future<void> createAdmin(CreateAdminModel createAdminModel) async {
    try {
      await _datasource.createAdmin(createAdminModel);
    } catch (e) {
      throw Exception('Gagal membuat akun admin');
    }
  }

  Future<void> resetPassword(String adminId) async {
    try {
      await _datasource.resetPassword(adminId);
    } catch (e) {
      throw Exception('Gagal mereset password admin');
    }
  }

  Future<void> activateAdmin(String adminId) async {
    try {
      await _datasource.activateAdmin(adminId);
    } catch (e) {
      throw Exception('Gagal mengaktifkan akun admin');
    }
  }

  Future<void> suspendAdmin(String adminId) async {
    try {
      await _datasource.suspendAdmin(adminId);
    } catch (e) {
      throw Exception('Gagal menonaktifkan akun admin');
    }
  }

  Future<void> deleteAdmin(String adminId) async {
    try {
      await _datasource.deleteAdmin(adminId);
    } catch (e) {
      throw Exception('Gagal menghapus akun admin');
    }
  }

  Future<UserDetailModel> getAdminById(String adminId) async {
    try {
      final data = await _datasource.getAdminById(adminId);
      return UserDetailModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal memuat detail admin');
    }
  }
}
