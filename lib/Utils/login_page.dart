import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String tokenStatus = "No token yet";

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
      tokenStatus = "Registering user...";
    });

    try {
      final response = await http.post(
        Uri.parse(ApiService.registerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        setState(() {
          tokenStatus = "User registered. Now login.";
        });
      } else {
        setState(() {
          tokenStatus = "Register failed: ${response.body}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        tokenStatus = "Connection error: $e";
      });
    }
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      tokenStatus = "Logging in...";
    });

    try {
      final response = await http.post(
        Uri.parse(ApiService.loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final accessToken = data["access"];
        final refreshToken = data["refresh"];
        final email = data["email"];

        final box = Hive.box('myBox');
        await box.put("TOKEN", accessToken);
        await box.put("REFRESH_TOKEN", refreshToken);
        await box.put("EMAIL", email);

        if (!mounted) return;

        setState(() {
          tokenStatus =
              "JWT Token saved:\n${accessToken.toString().substring(0, 40)}...";
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        setState(() {
          tokenStatus = "Login failed: ${response.body}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        tokenStatus = "Connection error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: const Text("JWT Login / Register"),
        backgroundColor: Colors.yellow[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: isLoading ? null : loginUser,
              child: const Text("Login with JWT"),
            ),
            TextButton(
              onPressed: isLoading ? null : registerUser,
              child: const Text("Register New User"),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              tokenStatus,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}