import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isRegisterMode = false;
  bool obscurePassword = true;
  String message = "";

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final success = await AuthService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isRegisterMode = false;
        message = success
            ? "Account created. Please sign in."
            : "Registration failed";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => message = "Connection error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      message = "";
    });

    try {
      final success = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, _) => HomePage(),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        setState(() => message = "Invalid email or password");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => message = "Connection error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.cardSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 20),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 70,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isRegisterMode ? "Create account" : "Welcome back",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Manage tasks, photos, and reminders from one clean workspace.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDecoration(
                      label: "Email",
                      icon: Icons.email_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: inputDecoration(
                      label: "Password",
                      icon: Icons.lock_rounded,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed:
                        isLoading ? null : isRegisterMode ? registerUser : loginUser,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isLoading
                          ? const SizedBox(
                              key: ValueKey("loader"),
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              key: const ValueKey("text"),
                              isRegisterMode ? "Create account" : "Sign in",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              isRegisterMode = !isRegisterMode;
                              message = "";
                            });
                          },
                    child: Text(
                      isRegisterMode
                          ? "Already have an account? Sign in"
                          : "New here? Create an account",
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}