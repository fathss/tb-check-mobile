import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_detail_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_management_repository.dart';

final userManagementProvider = FutureProvider.autoDispose<List<UserModel>>((
  ref,
) async {
  final repository = ref.watch(userManagementRepositoryProvider);

  return await repository.getAllUsers();
});

final userDetailProvider = FutureProvider.autoDispose
    .family<UserDetailModel, String>((ref, userId) async {
      final repository = ref.watch(userManagementRepositoryProvider);
      return await repository.getUserById(userId);
    });

final userManagementActionProvider = Provider<UserManagementActionController>((
  ref,
) {
  return UserManagementActionController(ref);
});

class UserManagementActionController {
  UserManagementActionController(this._ref);

  final Ref _ref;

  Future<void> activateUser(String userId) async {
    final repository = _ref.read(userManagementRepositoryProvider);
    await repository.activateUser(userId);
  }

  Future<void> suspendUser(String userId) async {
    final repository = _ref.read(userManagementRepositoryProvider);
    await repository.suspendUser(userId);
  }
}
