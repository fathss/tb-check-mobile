import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../auth/data/datasources/auth_storage.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    final token = await AuthStorage().getToken();
    final url = '${AppConstants.baseUrl}/Notifications';

    final response = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final token = await AuthStorage().getToken();
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/Notifications/mark-read/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    fetchNotifications(); // Refresh data setelah diupdate
  }

  // Fungsi untuk menandai semua notifikasi milik user ini sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    try {
      final token = await AuthStorage().getToken();
      final url = '${AppConstants.baseUrl}/Notifications/mark-all-read';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Ubah semua status di lokal agar UI langsung update tanpa loading
        for (var n in _notifications) {
          // n.isRead = true; // Jika model kamu memungkinkan mutation
        }
        await fetchNotifications(); // Refresh data dari server
      }
    } catch (e) {
      print("Error mark all as read: $e");
    }
  }
}