import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbcheck_app/features/user_map/data/models/faskes_model.dart';

import '../../data/repositories/user_map_repository.dart';

final userMapProvider = FutureProvider.autoDispose<List<Faskes>>((ref) async {
  final repository = ref.watch(userMapRepositoryProvider);
  return repository.getFaskesForMap();
});
