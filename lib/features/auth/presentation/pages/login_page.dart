import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import 'package:tbcheck_app/core/navigation/main_page.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/utils/jwt_utils.dart';
import 'package:tbcheck_app/features/admin_faskes/navigation/admin_main_navigation.dart';
import 'package:tbcheck_app/features/auth/data/datasources/auth_storage.dart';
import 'package:tbcheck_app/core/widgets/form_widget.dart';
import 'package:tbcheck_app/features/super_admin/presentation/navigation/super_admin_main_page.dart';
import 'package:tbcheck_app/features/user_profile/pages/complete_profile_page.dart';
import 'package:tbcheck_app/features/user_profile/presentation/controllers/user_profile_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onSignUpTap;

  const LoginPage({super.key, required this.onSignUpTap});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormWidget(
        titleText: 'Login to Your Account',
        fields: [
          AuthInputField(
            hintText: 'Email',
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
          ),
          AuthInputField(
            hintText: 'Password',
            prefixIcon: Icons.lock_outlined,
            isPasswordField: true,
            controller: _passwordController,
          ),
        ],
        buttonText: 'Sign In',
        onButtonPressed: _isLoading
            ? null
            : () async {
                final email = _emailController.text.trim();
                final password = _passwordController.text;

                // Basic validation
                final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                if (email.isEmpty || !emailRegex.hasMatch(email)) {
                  _showSnack(
                    'Please enter a valid email',
                    backgroundColor: AppColors.error,
                  );
                  return;
                }
                if (password.isEmpty || password.length < 6) {
                  _showSnack(
                    'Password must be at least 6 characters',
                    backgroundColor: AppColors.error,
                  );
                  return;
                }

                setState(() => _isLoading = true);
                try {
                  final controller = ref.read(authControllerProvider);
                  await controller.login(email, password);
                  if (!mounted) return;
                  await _navigateAfterLogin();
                } catch (e) {
                  _showSnack(
                    _messageFromError(e),
                    backgroundColor: AppColors.error,
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
        footer: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: const TextStyle(color: AppColors.textSecondary),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: _createSignUpGestureRecognizer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureRecognizer _createSignUpGestureRecognizer() {
    return TapGestureRecognizer()
      ..onTap = () {
        // TODO: Navigate to register page
        widget.onSignUpTap();
      };
  }

  void _showSnack(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  String _messageFromError(Object error) {
    final text = error.toString();
    return text.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _navigateAfterLogin() async {
    final storage = ref.read(authStorageProvider);
    final token = await storage.getToken();

    if (token == null || token.isEmpty) {
      _showSnack(
        'Login failed: token not found',
        backgroundColor: AppColors.error,
      );
      return;
    }

    final normalizedRole =
        JwtUtils.role(
          token,
        )?.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim() ??
        '';

    Widget? destination;

    if (normalizedRole == 'patient') {
      final userId = await storage.getUserId();
      if (userId == null || userId.isEmpty) {
        _showSnack('User ID tidak ditemukan', backgroundColor: AppColors.error);
        return;
      }

      final userProfileController = ref.read(userProfileControllerProvider);
      final hasProfile = await userProfileController.hasProfile(userId);
      destination = hasProfile ? const MainPage() : const CompleteProfilePage();
    } else if (normalizedRole == 'admin') {
      destination = const AdminMainNavigation();
    } else if (normalizedRole == 'super admin') {
      destination = const SuperAdminMainPage();
    }

    if (destination == null) {
      _showSnack('Unknown user role', backgroundColor: AppColors.error);
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination!),
      (route) => false,
    );
  }
}
