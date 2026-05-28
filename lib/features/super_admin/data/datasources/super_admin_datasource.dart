import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/network/api_client.dart'; // Sesuaikan path ApiClient Anda
import 'package:dio/dio.dart';
import 'package:tbcheck_app/features/super_admin/data/models/super_admin_model.dart';
import '../models/super_admin_dashboard_model.dart';

final superAdminDashboardDatasourceProvider =
    Provider<SuperAdminDashboardDatasource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return SuperAdminDashboardDatasource(apiClient);
    });

class SuperAdminDashboardDatasource {
  final ApiClient _apiClient;

  SuperAdminDashboardDatasource(this._apiClient);

  Future<SuperAdminDashboardModel> getDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/dashboard/super-admin');
      return SuperAdminDashboardModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil data dashboard');
    } catch (e) {
      throw Exception('Terjadi kesalahan format data');
    }
  }

  Future<SuperAdminModel> getSuperAdminById(String id) async {
    try {
      final response = await _apiClient.dio.get('/profile/super-admin/$id');
      return SuperAdminModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal mengambil data super admin');
    } catch (e) {
      throw Exception('Terjadi kesalahan format data');
    }
  }

  Future<void> updateSuperAdminProfile(
    String id,
    String username,
    String email,
    String? password,
  ) async {
    try {
      await _apiClient.dio.put(
        '/profile/super-admin/$id',
        data: {'username': username, 'email': email, 'password': password},
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Gagal memperbarui profil super admin');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memperbarui profil');
    }
  }
}
