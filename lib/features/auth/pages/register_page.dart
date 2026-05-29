import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/form_widget.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onSignInTap;

  const RegisterPage({super.key, required this.onSignInTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _usernameController;

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
        onButtonPressed: () {
          // TODO: Implement sign up navigation
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
}
