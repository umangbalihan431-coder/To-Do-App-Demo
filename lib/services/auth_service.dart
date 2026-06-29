import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static Box get _box => Hive.box('myBox');

  static const String _accessKey = "ACCESS_TOKEN";
  static const String _refreshKey = "REFRESH_TOKEN";

  static Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessKey);
  }

  static Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshKey);
  }

  static String? getEmail() {
    return _box.get("EMAIL");
  }

  static Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    await _secureStorage.write(key: _accessKey, value: accessToken);
    await _secureStorage.write(key: _refreshKey, value: refreshToken);
    await _box.put("EMAIL", email);
  }

  static Future<bool> register({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiService.registerUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password.trim(),
      }),
    );

    return response.statusCode == 201;
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    final response = await http.post(
      Uri.parse(ApiService.loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": cleanEmail,
        "password": password.trim(),
      }),
    );

    if (response.statusCode != 200) return false;

    final data = jsonDecode(response.body);

    final accessToken = data["access"]?.toString();
    final refreshToken = data["refresh"]?.toString();
    final savedEmail = data["email"]?.toString() ?? cleanEmail;

    if (accessToken == null || refreshToken == null) return false;

    await saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      email: savedEmail,
    );

    await saveFcmToken();
    return true;
  }

  static Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiService.refreshTokenUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refreshToken}),
      );

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body);
      final newAccessToken = data["access"]?.toString();

      if (newAccessToken == null || newAccessToken.isEmpty) return false;

      await _secureStorage.write(key: _accessKey, value: newAccessToken);

      if (data["refresh"] != null) {
        await _secureStorage.write(
          key: _refreshKey,
          value: data["refresh"].toString(),
        );
      }

      await saveFcmToken();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveFcmToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return;

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    await http.post(
      Uri.parse(ApiService.saveFcmTokenUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode({"fcm_token": fcmToken}),
    );
  }

  static Future<void> logout() async {
    await _secureStorage.delete(key: _accessKey);
    await _secureStorage.delete(key: _refreshKey);
    await _box.delete("EMAIL");
    await _box.put("NOTIFICATION_COUNT", 0);
  }
}