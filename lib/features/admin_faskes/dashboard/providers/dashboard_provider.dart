import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart'; // Sesuaikan path import jika perlu
import '../models/dashboard_model.dart';

class DashboardProvider with ChangeNotifier {
  DashboardModel? _data;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Mengambil base URL dan ID Faskes dari file global
      final String url = '${AppConstants.baseUrl}/Dashboard/admin?faskesId=${AppConstants.defaultFaskesId}';
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _data = DashboardModel.fromJson(responseData);
      } else {
        _errorMessage = 'Gagal memuat data statistik.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}