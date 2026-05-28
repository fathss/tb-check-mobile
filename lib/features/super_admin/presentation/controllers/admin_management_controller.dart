import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/create_admin_model.dart';
import '../../data/models/user_detail_model.dart';
import '../../data/repositories/admin_management_repository.dart';
import 'super_admin_controller.dart';

final adminDetailProvider = FutureProvider.autoDispose
    .family<UserDetailModel, String>((ref, adminId) async {
      final repository = ref.watch(adminManagementRepositoryProvider);
      return await repository.getAdminById(adminId);
    });

final adminManagementActionProvider = Provider<AdminManagementActionController>(
  (ref) {
    return AdminManagementActionController(ref);
  },
);

class AdminManagementActionController {
  AdminManagementActionController(this._ref);

  final Ref _ref;

  Future<void> createAdmin(CreateAdminModel createAdminModel) async {
    final repository = _ref.read(adminManagementRepositoryProvider);
    await repository.createAdmin(createAdminModel);
    // refresh dashboard stats after creating admin
    _ref.invalidate(superAdminDashboardProvider);
  }

  Future<void> resetPassword(String adminId) async {
    final repository = _ref.read(adminManagementRepositoryProvider);
    await repository.resetPassword(adminId);
  }

  Future<void> activateAdmin(String adminId) async {
    final repository = _ref.read(adminManagementRepositoryProvider);
    await repository.activateAdmin(adminId);
    // refresh dashboard stats after status change
    _ref.invalidate(superAdminDashboardProvider);
  }

  Future<void> suspendAdmin(String adminId) async {
    final repository = _ref.read(adminManagementRepositoryProvider);
    await repository.suspendAdmin(adminId);
    // refresh dashboard stats after status change
    _ref.invalidate(superAdminDashboardProvider);
  }

  Future<void> deleteAdmin(String adminId) async {
    final repository = _ref.read(adminManagementRepositoryProvider);
    await repository.deleteAdmin(adminId);
    // refresh dashboard stats after deletion
    _ref.invalidate(superAdminDashboardProvider);
  }
}
