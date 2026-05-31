import '../models/medicine_consumption_log_model.dart';
import '../services/medicine_consumption_log_api_service.dart';

class MedicineConsumptionLogRepository {
  final MedicineConsumptionLogApiService api;

  MedicineConsumptionLogRepository(this.api);

  Future<void> createLog(MedicineConsumptionLogModel log) async {
    await api.createLog(log.toJson());
  }

  Future<List<MedicineConsumptionLogModel>> getLogs(String patientId) async {
    final response = await api.getLogs(patientId);

    return response
        .map<MedicineConsumptionLogModel>(
          (e) => MedicineConsumptionLogModel.fromJson(e),
        )
        .toList();
  }
}
