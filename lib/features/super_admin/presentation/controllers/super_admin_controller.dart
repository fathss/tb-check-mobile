import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/super_admin_dashboard_model.dart';
import '../../data/models/super_admin_model.dart';
import '../../data/repositories/super_admin_repository.dart';

final superAdminDashboardProvider =
    FutureProvider.autoDispose<SuperAdminDashboardModel>((ref) async {
      final repository = ref.watch(superAdminDashboardRepositoryProvider);
      return repository.fetchDashboard();
    });

final superAdminProfileProvider = FutureProvider.autoDispose
    .family<SuperAdminModel, String>((ref, id) async {
      final repository = ref.watch(superAdminDashboardRepositoryProvider);
      return repository.fetchSuperAdminById(id);
    });

final superAdminControllerProvider = Provider<SuperAdminController>((ref) {
  return SuperAdminController(ref);
});

class SuperAdminController {
  SuperAdminController(this._ref);

  final Ref _ref;

  Future<SuperAdminModel> fetchProfile(String id) async {
    final repository = _ref.read(superAdminDashboardRepositoryProvider);
    return repository.fetchSuperAdminById(id);
  }

  Future<void> updateProfile(
    String id,
    String username,
    String email,
    String? password,
  ) async {
    final repository = _ref.read(superAdminDashboardRepositoryProvider);
    await repository.updateSuperAdminProfile(id, username, email, password);
    _ref.invalidate(superAdminProfileProvider(id));
    _ref.invalidate(superAdminDashboardProvider);
  }
}
