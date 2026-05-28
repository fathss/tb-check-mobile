import 'package:flutter/material.dart';

class ProfileController {
  late TextEditingController nikController;

  late TextEditingController nameController;

  late TextEditingController emailController;

  late TextEditingController passwordController;

  late TextEditingController birthDateController;

  bool isMale = true;

  bool obscurePassword = true;

  void init({
    required String nik,
    required String fullName,
    required String email,
    required String password,
    required String birthDate,
    required bool gender,
  }) {
    nikController = TextEditingController(text: nik);

    nameController = TextEditingController(text: fullName);

    emailController = TextEditingController(text: email);

    passwordController = TextEditingController(text: password);

    birthDateController = TextEditingController(text: birthDate);

    isMale = gender;
  }

  void dispose() {
    nikController.dispose();

    nameController.dispose();

    emailController.dispose();

    passwordController.dispose();

    birthDateController.dispose();
  }

  void toggleGender(bool value) {
    isMale = value;
  }

  void togglePassword() {
    obscurePassword = !obscurePassword;
  }
}
