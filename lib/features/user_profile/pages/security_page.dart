import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/primary_button.dart';
import 'package:tbcheck_app/core/widgets/app_snackbar.dart';
import 'package:tbcheck_app/features/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    // 1. Validasi lokal
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      AppSnackbar.showError(context, "Semua kolom kata sandi wajib diisi!");
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      AppSnackbar.showError(context, "Kata sandi baru tidak cocok!");
      return;
    }
    if (_newPasswordController.text.length < 6) {
      AppSnackbar.showError(context, "Kata sandi baru minimal 6 karakter!");
      return;
    }

    setState(() => _isLoading = true);

    // 2. Ambil ID dan panggil API
    final storage = ref.read(authStorageProvider);
    final userId = await storage.getUserId();

    if (userId != null) {
      final repo = ref.read(userProfileRepositoryProvider);
      bool success = await repo.changePassword(
        userId, 
        _oldPasswordController.text, 
        _newPasswordController.text
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          AppSnackbar.showSuccess(context, "Kata sandi berhasil diperbarui!");
          Navigator.pop(context); // Tutup halaman jika berhasil
        } else {
          // Jika false, kemungkinan besar password lama salah
          AppSnackbar.showError(context, "Gagal memperbarui. Pastikan kata sandi lama Anda benar.");
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Keamanan & Kata Sandi", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Perbarui Kata Sandi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Pastikan kata sandi baru Anda unik dan tidak mudah ditebak oleh orang lain.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.5),
              ),
              const SizedBox(height: 32),

              _buildPasswordField("Kata Sandi Lama", _oldPasswordController, _obscureOld, () {
                setState(() => _obscureOld = !_obscureOld);
              }),
              const SizedBox(height: 20),
              
              _buildPasswordField("Kata Sandi Baru", _newPasswordController, _obscureNew, () {
                setState(() => _obscureNew = !_obscureNew);
              }),
              const SizedBox(height: 20),

              _buildPasswordField("Konfirmasi Kata Sandi Baru", _confirmPasswordController, _obscureConfirm, () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              }),
              
              const SizedBox(height: 48),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: "Simpan Kata Sandi Baru",
                      onPressed: _updatePassword,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isObscured, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscured,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}