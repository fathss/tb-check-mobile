import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/faskes_management_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/faskes_form_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/user_admin_management/admin_detail_page.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/widgets/faskes_detail_card.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/widgets/faskes_detail_admin_card.dart';
import 'package:tbcheck_app/features/super_admin/presentation/pages/faskes_management/widgets/faskes_detail_admin_form_card.dart';

class FaskesDetailPage extends ConsumerStatefulWidget {
  final String faskesId;

  const FaskesDetailPage({super.key, required this.faskesId});

  @override
  ConsumerState<FaskesDetailPage> createState() => _FaskesDetailPageState();
}

class _FaskesDetailPageState extends ConsumerState<FaskesDetailPage> {
  final _adminFormKey = GlobalKey<FormState>();
  final TextEditingController _adminNameController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();

  @override
  void dispose() {
    _adminNameController.dispose();
    _adminEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(faskesDetailProvider(widget.faskesId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Faskes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // 1. Confirm
              final confirm = await showDialog<bool?>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Hapus Faskes?', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Yakin ingin menghapus faskes ini? Tindakan ini tidak dapat dibatalkan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menghapus faskes...')));

              try {
                final mutation = ref.read(faskesMutationControllerProvider);
                final msg = await mutation.deleteFaskes(widget.faskesId);

                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));

                // Invalidate providers and go back
                ref.invalidate(faskesManagementProvider);
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                final errorMsg = e.toString();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
              }
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Gagal memuat detail faskes')),
        data: (detail) {
          final faskesCoordinate = LatLng(detail.latitude, detail.longitude);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              const SizedBox(height: 8),
              FaskesDetailCard(
                detail: detail,
                onEdit: () async {
                  final saved = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => FaskesFormPage(
                        pageTitle: 'Edit Faskes',
                        actionLabel: 'Simpan Perubahan',
                        faskesId: detail.id,
                        initialKategori: detail.type == 'PUSKESMAS'
                            ? 'Puskesmas'
                            : 'Rumah Sakit',
                        initialNama: detail.name,
                        initialCoordinate: faskesCoordinate,
                        initialAlamat: detail.address,
                        initialTelepon: detail.emergencyContact,
                      ),
                    ),
                  );

                  if (saved == true) {
                    ref.invalidate(faskesDetailProvider(widget.faskesId));
                    ref.invalidate(faskesManagementProvider);
                  }
                },
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Akun Admin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decorationThickness: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${detail.admins.length} Akun',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (detail.admins.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: AppColors.cardStroke),
                      ),
                      child: Column(
                        children: const [
                          Icon(
                            Icons.manage_accounts_outlined,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada akun admin untuk faskes ini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...detail.admins.map(
                      (admin) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FaskesDetailAdminCard(
                          admin: admin,
                          faskesId: detail.id,
                          onTap: () async {
                            final deleted = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => AdminDetailPage(
                                      admin: admin,
                                      faskesId: detail.id,
                                    ),
                                  ),
                                );

                            if (deleted == true) {
                              ref.invalidate(
                                faskesDetailProvider(widget.faskesId),
                              );
                              ref.invalidate(faskesManagementProvider);
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FaskesDetailAdminFormCard(
                formKey: _adminFormKey,
                nameController: _adminNameController,
                emailController: _adminEmailController,
                faskesId: detail.id,
              ),
              const SizedBox(height: 78),
            ],
          );
        },
      ),
    );
  }
}
