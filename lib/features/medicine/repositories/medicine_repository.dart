import '../models/medicine_model.dart';
import '../services/medicine_api_service.dart';

class MedicineRepository {
  final MedicineApiService api;

  MedicineRepository(this.api);

  Future<List<MedicineModel>> getMedicines(String patientId) async {
    final response = await api.getMedicines(patientId);

    return response
        .map<MedicineModel>((json) => MedicineModel.fromJson(json))
        .toList();
  }

  Future<void> createMedicine(MedicineModel medicine) async {
    await api.createMedicine(medicine.toJson());
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    await api.updateMedicine(medicine.id, medicine.toJson());
  }

  Future<void> deleteMedicine(String id) async {
    await api.deleteMedicine(id);
  }

  Future<void> decreaseStock(String id) async {
    await api.decreaseStock(id);
  }
}
