import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/custom_action_button.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/confirm_action_dialog.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/admin_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/user_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/faskes_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/data/models/admin_model.dart';

class AdminDetailPage extends ConsumerStatefulWidget {
  final AdminModel admin;
  final String? faskesId;

  const AdminDetailPage({super.key, required this.admin, this.faskesId});

  @override
  ConsumerState<AdminDetailPage> createState() => _AdminDetailPageState();
}

class _AdminDetailPageState extends ConsumerState<AdminDetailPage> {
  bool _isSubmitting = false;
  bool? _localIsActive;

  Future<void> _handleResetPassword(String adminId) async {
    final confirm = await showConfirmActionDialog(
      context,
      title: 'Reset Password',
      content: 'Reset password ke default untuk akun admin ini?',
      confirmLabel: 'Ya',
      cancelLabel: 'Batal',
      destructive: false,
    );
    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(adminManagementActionProvider).resetPassword(adminId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil direset.')),
      );
      ref.invalidate(adminDetailProvider(adminId));
      ref.invalidate(userManagementProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleToggleActive(String adminId, bool isActive) async {
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

    setState(() => _isSubmitting = true);
    try {
      if (isActive) {
        await ref.read(adminManagementActionProvider).suspendAdmin(adminId);
      } else {
        await ref.read(adminManagementActionProvider).activateAdmin(adminId);
      }

      // update local UI state so page reflects change immediately
      if (mounted) {
        setState(() {
          _localIsActive = !(isActive);
        });
      }

      if (!mounted) return;
      ref.invalidate(adminDetailProvider(adminId));
      ref.invalidate(userManagementProvider);
      if (widget.faskesId != null) {
        ref.invalidate(faskesDetailProvider(widget.faskesId!));
        ref.invalidate(faskesManagementProvider);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleDelete(String adminId) async {
    final confirm = await showConfirmActionDialog(
      context,
      title: 'Hapus Permanen Pengguna',
      content:
          'Yakin ingin menghapus akun admin ini? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      destructive: true,
    );
    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(adminManagementActionProvider).deleteAdmin(adminId);
      if (!mounted) return;
      ref.invalidate(userManagementProvider);
      if (widget.faskesId != null) {
        ref.invalidate(faskesDetailProvider(widget.faskesId!));
        ref.invalidate(faskesManagementProvider);
      }
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Akun admin dihapus.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // prefer local override when available — construct a lightweight AdminModel
    final effectiveAdmin = AdminModel(
      id: widget.admin.id,
      email: widget.admin.email,
      fullName: widget.admin.fullName,
      isActive: _localIsActive ?? widget.admin.isActive,
      createdAt: widget.admin.createdAt,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Admin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _buildFromAdmin(effectiveAdmin),
    );
  }

  Widget _buildFromAdmin(AdminModel admin) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      children: [
        const SizedBox(height: 8),
        _AdminProfileCard(
          name: admin.fullName,
          email: admin.email,
          isActive: admin.isActive,
        ),
        const SizedBox(height: 24),
        const Text(
          'Aksi Administratif',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        CustomActionButton(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textPrimary,
          icon: Icons.lock_reset_outlined,
          label: 'Reset Password ke Default',
          onPressed: _isSubmitting
              ? null
              : () => _handleResetPassword(admin.id),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (ctx) {
            final bool active = admin.isActive ?? false;
            return CustomActionButton(
              backgroundColor: active
                  ? AppColors.warningBg
                  : AppColors.successBg,
              foregroundColor: active ? AppColors.warning : AppColors.success,
              icon: active
                  ? Icons.pause_circle_outline
                  : Icons.check_circle_outline,
              label: active ? 'Bekukan Akun (Suspend)' : 'Aktifkan Akun',
              onPressed: _isSubmitting
                  ? null
                  : () => _handleToggleActive(admin.id, active),
            );
          },
        ),
        const SizedBox(height: 12),
        CustomActionButton(
          backgroundColor: AppColors.errorBg,
          foregroundColor: AppColors.error,
          icon: Icons.delete_outline,
          label: 'Hapus Permanen Pengguna',
          onPressed: _isSubmitting ? null : () => _handleDelete(admin.id),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _AdminProfileCard extends StatelessWidget {
  const _AdminProfileCard({
    required this.name,
    required this.email,
    this.isActive,
  });

  final String name;
  final String email;
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.cardStroke, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryBg,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: _StatusChip(isActive: isActive),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({this.isActive});

  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    // If status unknown, show nothing
    if (isActive == null) {
      return const SizedBox.shrink();
    }

    final bg = isActive! ? AppColors.successBg : AppColors.errorBg;
    final fg = isActive! ? AppColors.success : AppColors.error;
    final label = isActive! ? 'Aktif' : 'Nonaktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
