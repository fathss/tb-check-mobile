import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/form_widget.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final VoidCallback onSignInTap;

  const RegisterPage({super.key, required this.onSignInTap});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _usernameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormWidget(
        titleText: 'Create New Account',
        fields: [
          AuthInputField(
            hintText: 'Username',
            prefixIcon: Icons.person_outline,
            controller: _usernameController,
          ),
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
          AuthInputField(
            hintText: 'Confirm Password',
            prefixIcon: Icons.lock_outlined,
            isPasswordField: true,
            controller: _confirmPasswordController,
          ),
        ],
        buttonText: 'Sign Up',
        onButtonPressed: _isLoading
            ? null
            : () async {
                final username = _usernameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                final confirm = _confirmPasswordController.text;

                final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                if (username.isEmpty || username.length < 3) {
                  _showSnack(
                    'Username must be at least 3 characters',
                    backgroundColor: AppColors.error,
                  );
                  return;
                }
                if (email.isEmpty || !emailRegex.hasMatch(email)) {
                  _showSnack(
                    'Please enter a valid email',
                    backgroundColor: AppColors.error,
                  );
                  return;
                }
                if (password.length < 6) {
                  _showSnack(
                    'Password must be at least 6 characters',
                    backgroundColor: AppColors.error,
                  );
                  return;
                }
                if (password != confirm) {
                  _showSnack(
                    'Passwords do not match',
                    backgroundColor: AppColors.error,
                  );
                  return;
                }

                setState(() => _isLoading = true);
                try {
                  final controller = ref.read(authControllerProvider);
                  await controller.register(username, email, password);
                  _showSnack(
                    'Account created successfully',
                    backgroundColor: AppColors.success,
                  );
                  widget.onSignInTap();
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
            text: 'Already have an account? ',
            style: const TextStyle(color: AppColors.textSecondary),
            children: [
              TextSpan(
                text: 'Sign In',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: _createSignInGestureRecognizer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureRecognizer _createSignInGestureRecognizer() {
    return TapGestureRecognizer()
      ..onTap = () {
        // TODO: Navigate to login page
        widget.onSignInTap();
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
}
