import '../../../core/network/api_client.dart';

class MedicineApiService {
  final ApiClient apiClient;

  MedicineApiService(this.apiClient);

  Future<List<dynamic>> getMedicines(String patientId) async {
    final response = await apiClient.dio.get(
      '/Medicines',
      queryParameters: {'patientId': patientId},
    );

    return response.data;
  }

  Future<void> createMedicine(Map<String, dynamic> data) async {
    await apiClient.dio.post('/Medicines', data: data);
  }

  Future<void> updateMedicine(String id, Map<String, dynamic> data) async {
    await apiClient.dio.put('/Medicines/$id', data: data);
  }

  Future<void> deleteMedicine(String id) async {
    await apiClient.dio.delete('/Medicines/$id');
  }

  Future<void> decreaseStock(String id) async {
    await apiClient.dio.put('/Medicines/$id/decrease-stock');
  }
}
