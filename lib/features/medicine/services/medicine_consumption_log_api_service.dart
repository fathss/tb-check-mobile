import '../../../core/network/api_client.dart';

class MedicineConsumptionLogApiService {
  final ApiClient apiClient;

  MedicineConsumptionLogApiService(this.apiClient);

  Future<void> createLog(Map<String, dynamic> data) async {
    await apiClient.dio.post('/MedicineConsumptionLogs', data: data);
  }

  Future<List<dynamic>> getLogs(String patientId) async {
    final response = await apiClient.dio.get(
      '/MedicineConsumptionLogs',
      queryParameters: {'patientId': patientId},
    );

    return response.data;
  }
}
