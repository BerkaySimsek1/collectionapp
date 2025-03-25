import 'package:collectionapp/pages/loginPages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:collectionapp/pages/loginPages/login_page.dart';
import 'package:collectionapp/pages/loginPages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // 0: onboarding, 1: login, 2: register
  int currentPage = 0;

  void showLoginPage() {
    setState(() {
      currentPage = 1;
    });
  }

  void showRegisterPage() {
    setState(() {
      currentPage = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentPage == 0) {
      return OnboardingPage(
        showLoginPage: showLoginPage,
      );
    } else if (currentPage == 1) {
      return LoginPage(
        showRegisterPage: showRegisterPage,
      );
    } else {
      return RegisterPage(
        showLoginPage: showLoginPage,
      );
    }
  }
}
