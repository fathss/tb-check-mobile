import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/custom_text_field.dart';
import 'package:tbcheck_app/features/auth/auth_page.dart';
import 'package:tbcheck_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/controllers/super_admin_controller.dart';
import 'package:tbcheck_app/features/super_admin/presentation/widgets/custom_button.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';

class SuperAdminProfilePage extends ConsumerStatefulWidget {
  const SuperAdminProfilePage({super.key, required this.superAdminId});

  final String superAdminId;

  @override
  ConsumerState<SuperAdminProfilePage> createState() =>
      _SuperAdminProfilePageState();
}

class _SuperAdminProfilePageState extends ConsumerState<SuperAdminProfilePage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _seededForm = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userIdAsync = ref.watch(sessionUserIdProvider);

    if (userIdAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userIdAsync.hasError) {
      return Center(child: Text('Gagal memuat session'));
    }

    final sessionId = userIdAsync.value;
    if (sessionId == null || sessionId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
        );
      });
      return const SizedBox.shrink();
    }

    final profileAsync = ref.watch(superAdminProfileProvider(sessionId));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          titleSpacing: 20,
          title: const Text(
            'Profil Saya',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await ref.read(authControllerProvider).logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              color: AppColors.error,
            ),
          ],
        ),
        body: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Gagal memuat profil super admin',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (profile) {
            if (!_seededForm) {
              _usernameController.text = profile.username;
              _emailController.text = profile.email;
              _seededForm = true;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardStroke,
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.primaryBg,
                          child: Text(
                            profile.username.isNotEmpty
                                ? profile.username[0].toUpperCase()
                                : 'S',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        CustomTextField(
                          label: 'Nama Administrator',
                          controller: _usernameController,
                        ),
                        CustomTextField(
                          label: 'Email Sistem',
                          subLabel: '(tidak dapat dirubah)',
                          controller: _emailController,
                          readOnly: true,
                        ),
                        CustomTextField(
                          label: 'Ganti Kata Sandi',
                          hintText: 'Masukkan kata sandi baru...',
                          controller: _passwordController,
                          footerNote:
                              'Biarkan kosong jika tidak ingin merubah kata sandi',
                          obscureText: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        label: 'Simpan Perubahan',
                        onPressed: () async {
                          await ref
                              .read(superAdminControllerProvider)
                              .updateProfile(
                                widget.superAdminId,
                                _usernameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text.trim().isEmpty
                                    ? null
                                    : _passwordController.text.trim(),
                              );

                          if (!mounted) return;
                          final refreshedProfile = await ref.refresh(
                            superAdminProfileProvider(
                              widget.superAdminId,
                            ).future,
                          );
                          if (!mounted) return;
                          setState(() {
                            _usernameController.text =
                                refreshedProfile.username;
                            _emailController.text = refreshedProfile.email;
                            _seededForm = true;
                          });
                          _passwordController.clear();

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profil super admin berhasil diperbarui',
                              ),
                            ),
                          );
                        },
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
