import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/super_admin_datasource.dart';
import '../models/super_admin_dashboard_model.dart';
import '../models/super_admin_model.dart';

// Provider untuk Repository
final superAdminDashboardRepositoryProvider =
    Provider<SuperAdminDashboardRepository>((ref) {
      final datasource = ref.watch(superAdminDashboardDatasourceProvider);
      return SuperAdminDashboardRepository(datasource);
    });

class SuperAdminDashboardRepository {
  final SuperAdminDashboardDatasource _datasource;

  SuperAdminDashboardRepository(this._datasource);

  Future<SuperAdminDashboardModel> fetchDashboard() async {
    try {
      return await _datasource.getDashboardData();
    } catch (e) {
      throw Exception('Gagal memuat dashboard: ${e.toString()}');
    }
  }

  Future<SuperAdminModel> fetchSuperAdminById(String id) async {
    try {
      return await _datasource.getSuperAdminById(id);
    } catch (e) {
      throw Exception('Gagal memuat data super admin: ${e.toString()}');
    }
  }

  Future<void> updateSuperAdminProfile(
    String id,
    String username,
    String email,
    String? password,
  ) async {
    try {
      await _datasource.updateSuperAdminProfile(id, username, email, password);
    } catch (e) {
      throw Exception('Gagal memperbarui profil super admin: ${e.toString()}');
    }
  }
}
