import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileController {
  final nikController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final birthDateController = TextEditingController();

  bool isMale = true;
  bool obscurePassword = true;
  bool isLoading = false; // Tambahkan ini

  // Fungsi untuk memasukkan data dari API ke controller
  void populateData(Map<String, dynamic> data) {
    nikController.text = data['nik'] ?? "";
    nameController.text = data['fullName'] ?? "";
    // Email/Password mungkin perlu logika khusus dari API
    
    // Format tanggal: "2001-05-15T00:00:00" -> "15/05/2001"
    if (data['dateOfBirth'] != null) {
      DateTime dob = DateTime.parse(data['dateOfBirth']);
      birthDateController.text = DateFormat('dd/MM/yyyy').format(dob);
    }
    
    isMale = data['gender'] == "Laki-Laki" || data['gender'] == true;
  }

  void dispose() {
    nikController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    birthDateController.dispose();
  }

  void toggleGender(bool value) => isMale = value;
  void togglePassword() => obscurePassword = !obscurePassword;
}