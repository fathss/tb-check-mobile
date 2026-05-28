import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/data/models/user_detail_model.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/user_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/custom_action_button.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/confirm_action_dialog.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailPage({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  bool _isSubmitting = false;

  Future<void> _toggleActiveState(UserDetailModel detail) async {
    if (_isSubmitting) return;

    final isActive = _isActive(detail);

    final confirm = await showConfirmActionDialog(
      context,
      title: isActive ? 'Nonaktifkan Pengguna' : 'Aktifkan Pengguna',
      content: isActive
          ? 'Yakin ingin menonaktifkan pengguna ini?'
          : 'Yakin ingin mengaktifkan pengguna ini?',
      confirmLabel: isActive ? 'Nonaktifkan' : 'Aktifkan',
      cancelLabel: 'Batal',
      destructive: isActive,
    );

    if (confirm != true) return;

    setState(() {
      _isSubmitting = true;
    });

    final controller = ref.read(userManagementActionProvider);

    try {
      if (_isActive(detail)) {
        await controller.suspendUser(detail.id);
      } else {
        await controller.activateUser(detail.id);
      }

      if (!mounted) return;
      ref.invalidate(userDetailProvider(widget.userId));
      ref.invalidate(userManagementProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _isActive(UserDetailModel detail) {
    return detail.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(userDetailProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Pengguna',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: detailAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(child: Text('Gagal memuat detail pengguna')),
          ),
          data: (detail) {
            final isActive = _isActive(detail);

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: AppColors.cardStroke,
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primaryBg,
                          child: Text(
                            detail.fullName.isNotEmpty
                                ? detail.fullName[0].toUpperCase()
                                : '-',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          detail.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Informasi Sistem',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.third,
                      border: Border.all(color: AppColors.cardStroke),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Tanggal Bergabung',
                          detail.createdAt
                              .toLocal()
                              .toString()
                              .split(' ')
                              .first,
                        ),
                        _buildInfoRow('NIK', detail.nik),
                        _buildInfoRow(
                          'Status',
                          detail.isActive ? detail.status : 'Dibekukan',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomActionButton(
                        backgroundColor: isActive
                            ? AppColors.warningBg
                            : AppColors.successBg,
                        foregroundColor: isActive
                            ? AppColors.warning
                            : AppColors.success,
                        icon: isActive
                            ? Icons.pause_circle_outline
                            : Icons.check_circle,
                        label: isActive
                            ? 'Bekukan Akun (Suspend)'
                            : 'Aktifkan Akun (Activate)',
                        onPressed: _isSubmitting
                            ? null
                            : () => _toggleActiveState(detail),
                      ),
                      const SizedBox(height: 12),
                      CustomActionButton(
                        backgroundColor: AppColors.errorBg,
                        foregroundColor: AppColors.error,
                        icon: Icons.delete_outline,
                        label: 'Hapus Permanen Pengguna',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
