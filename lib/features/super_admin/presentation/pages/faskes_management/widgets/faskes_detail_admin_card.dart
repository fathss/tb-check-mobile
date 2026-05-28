import 'package:flutter/material.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/data/models/admin_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/admin_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/faskes_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/confirm_action_dialog.dart';

class FaskesDetailAdminCard extends ConsumerStatefulWidget {
  final AdminModel admin;
  final VoidCallback onTap;
  final String faskesId;

  const FaskesDetailAdminCard({
    super.key,
    required this.admin,
    required this.onTap,
    required this.faskesId,
  });

  @override
  ConsumerState<FaskesDetailAdminCard> createState() =>
      _FaskesDetailAdminCardState();
}

class _FaskesDetailAdminCardState extends ConsumerState<FaskesDetailAdminCard> {
  @override
  Widget build(BuildContext context) {
    final initial = widget.admin.fullName.isNotEmpty
        ? widget.admin.fullName[0].toUpperCase()
        : '-';

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.cardStroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.admin.fullName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (widget.admin.isActive != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.admin.isActive == true
                                    ? AppColors.successBg
                                    : AppColors.errorBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.admin.isActive == true
                                    ? 'Aktif'
                                    : 'Nonaktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.admin.isActive == true
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.admin.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);

                      final confirm = await showConfirmActionDialog(
                        context,
                        title: 'Reset Password',
                        content: 'Reset password to default for this admin?',
                        confirmLabel: 'Ya',
                        cancelLabel: 'Batal',
                        destructive: false,
                      );

                      if (confirm != true) return;

                      try {
                        await ref
                            .read(adminManagementActionProvider)
                            .resetPassword(widget.admin.id);

                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Password berhasil direset.'),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    icon: const Icon(Icons.key_outlined, size: 16),
                    label: const Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);

                      final confirm = await showConfirmActionDialog(
                        context,
                        title: 'Hapus Akun',
                        content:
                            'Yakin ingin menghapus akun admin ini? Tindakan ini tidak dapat dibatalkan.',
                        confirmLabel: 'Hapus',
                        cancelLabel: 'Batal',
                        destructive: true,
                      );

                      if (confirm != true) return;

                      try {
                        await ref
                            .read(adminManagementActionProvider)
                            .deleteAdmin(widget.admin.id);

                        if (!mounted) return;
                        ref.invalidate(faskesDetailProvider(widget.faskesId));
                        ref.invalidate(faskesManagementProvider);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Akun admin dihapus.')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text(
                      'Hapus Akun',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorBg,
                      foregroundColor: AppColors.error,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
