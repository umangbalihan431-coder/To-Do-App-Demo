import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isChecking = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final hasRefresh = await AuthService.hasRefreshToken();

    if (!hasRefresh) {
      if (!mounted) return;

      setState(() {
        isLoggedIn = false;
        isChecking = false;
      });
      return;
    }

    final refreshed = await AuthService.refreshAccessToken();

    if (!mounted) return;

    setState(() {
      isLoggedIn = refreshed;
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return isLoggedIn ? HomePage() : const LoginPage();
  }
}