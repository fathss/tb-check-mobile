import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoginPage = true;

  @override
  Widget build(BuildContext context) {
    if (_isLoginPage) {
      return LoginPage(
        onSignUpTap: () {
          setState(() {
            _isLoginPage = false;
          });
        },
      );
    } else {
      return RegisterPage(
        onSignInTap: () {
          setState(() {
            _isLoginPage = true;
          });
        },
      );
    }
  }
}
