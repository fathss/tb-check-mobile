import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/data/models/create_admin_model.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/admin_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/faskes_management_controller.dart';

class FaskesDetailAdminFormCard extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final String faskesId;

  const FaskesDetailAdminFormCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.faskesId,
  });

  @override
  ConsumerState<FaskesDetailAdminFormCard> createState() =>
      _FaskesDetailAdminFormCardState();
}

class _FaskesDetailAdminFormCardState
    extends ConsumerState<FaskesDetailAdminFormCard> {
  bool _isCreating = false;

  Widget _buildAdminTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.third,
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.cardStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.cardStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    if (widget.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap tidak boleh kosong.')),
      );
      return;
    }

    if (widget.emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email tidak boleh kosong.')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final controller = ref.read(adminManagementActionProvider);
      await controller.createAdmin(
        CreateAdminModel(
          username: widget.nameController.text.trim(),
          email: widget.emailController.text.trim(),
          faskesProfileId: widget.faskesId,
        ),
      );

      ref.invalidate(faskesDetailProvider(widget.faskesId));
      ref.invalidate(faskesManagementProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun admin berhasil dibuat.')),
      );

      widget.nameController.clear();
      widget.emailController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.third,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.cardStroke),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Akun Admin Baru',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                Form(
                  key: widget.formKey,
                  child: Column(
                    children: [
                      _buildAdminTextField(
                        controller: widget.nameController,
                        hint: 'Nama Lengkap Petugas',
                      ),
                      const SizedBox(height: 16),
                      _buildAdminTextField(
                        controller: widget.emailController,
                        hint: 'Email Admin',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            "Password default otomatis: ",
                            style: TextStyle(
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            "admin1234",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isCreating ? null : _submit,
                          icon: _isCreating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1_outlined),
                          label: Text(
                            _isCreating
                                ? 'Menyimpan...'
                                : 'Buat Akun Admin Baru',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
