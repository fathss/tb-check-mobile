import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/user_profile_datasource.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final datasource = ref.watch(userProfileDatasourceProvider);
  return UserProfileRepository(datasource);
});

class UserProfileRepository {
  final UserProfileDatasource _datasource;

  UserProfileRepository(this._datasource);

  Future<bool> hasProfile(String userId) async {
    return _datasource.hasProfile(userId);
  }

  Future<void> completeProfile({
    required String userId,
    required String fullName,
    required String nik,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    await _datasource.completeProfile(
      userId: userId,
      fullName: fullName,
      nik: nik,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
  }
}
