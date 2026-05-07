import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tbcheck_app/core/theme/app_colors.dart';
import 'package:tbcheck_app/core/widgets/form_widget.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSignUpTap;

  const LoginPage({super.key, required this.onSignUpTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

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
        onButtonPressed: () {
          // TODO: Implement sign in navigation
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
}
