import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/faskes_management_datasource.dart';
import '../models/faskes_model.dart';
import '../models/faskes_detail_model.dart';
import '../models/faskes_upsert_request.dart';

final faskesManagementRepositoryProvider = Provider<FaskesManagementRepository>(
  (ref) {
    final datasource = ref.watch(faskesManagementDatasourceProvider);
    return FaskesManagementRepository(datasource);
  },
);

class FaskesManagementRepository {
  final FaskesManagementDatasource _datasource;

  FaskesManagementRepository(this._datasource);

  Future<List<FaskesModel>> getAllFaskes() async {
    try {
      return await _datasource.getAllFaskes();
    } catch (e) {
      throw Exception('Gagal memuat data faskes: ${e.toString()}');
    }
  }

  Future<FaskesDetailModel> getFaskesById(String faskesId) async {
    try {
      return await _datasource.getFaskesById(faskesId);
    } catch (e) {
      throw Exception('Gagal memuat detail faskes: ${e.toString()}');
    }
  }

  Future<FaskesMutationResult> createFaskes(FaskesUpsertRequest request) async {
    try {
      return await _datasource.createFaskes(request);
    } catch (e) {
      throw Exception('Gagal membuat faskes baru: ${e.toString()}');
    }
  }

  Future<FaskesMutationResult> updateFaskes(
    String faskesId,
    FaskesUpsertRequest request,
  ) async {
    try {
      return await _datasource.updateFaskes(faskesId, request);
    } catch (e) {
      throw Exception('Gagal memperbarui faskes: ${e.toString()}');
    }
  }
}
