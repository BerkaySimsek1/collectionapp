import 'package:collectionapp/screens/authScreens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:collectionapp/screens/authScreens/login_screen.dart';
import 'package:collectionapp/screens/authScreens/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 0: onboarding, 1: login, 2: register
  int currentPage = 0;

  void showLoginScreen() {
    setState(() {
      currentPage = 1;
    });
  }

  void showRegisterScreen() {
    setState(() {
      currentPage = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentPage == 0) {
      return OnboardingScreen(
        showLoginScreen: showLoginScreen,
      );
    } else if (currentPage == 1) {
      return LoginScreen(
        showRegisterScreen: showRegisterScreen,
      );
    } else {
      return RegisterScreen(
        showLoginScreen: showLoginScreen,
      );
    }
  }
}
