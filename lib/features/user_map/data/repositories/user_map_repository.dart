import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tbcheck_app/features/user_map/data/models/faskes_model.dart';

import '../datasources/user_map_datasource.dart';

final userMapRepositoryProvider = Provider<UserMapRepository>((ref) {
  final datasource = ref.watch(userMapDatasourceProvider);
  return UserMapRepository(datasource);
});

class UserMapRepository {
  final UserMapDatasource _datasource;

  UserMapRepository(this._datasource);

  Future<List<Faskes>> getFaskesForMap() async {
    try {
      final summaries = await _datasource.getFaskesList();
      final faskes = summaries.map(Faskes.fromMapItem).toList();
      faskes.sort((left, right) => left.nama.compareTo(right.nama));
      return faskes;
    } catch (e) {
      throw Exception('Gagal memuat faskes untuk peta: ${e.toString()}');
    }
  }
}
