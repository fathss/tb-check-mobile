import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/user_profile_repository.dart';
import '../../models/home_summary_model.dart';

final userProfileControllerProvider = Provider<UserProfileController>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UserProfileController(repository);
});

final homeSummaryProvider = FutureProvider.family<HomeSummaryModel, String>((ref, userId) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  return repository.getHomeSummary(userId);
});

class UserProfileController {
  final UserProfileRepository _repository;

  UserProfileController(this._repository);

  Future<bool> hasProfile(String userId) async {
    return _repository.hasProfile(userId);
  }

  Future<void> completeProfile({
    required String userId,
    required String fullName,
    required String nik,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    await _repository.completeProfile(
      userId: userId,
      fullName: fullName,
      nik: nik,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
  }
}
