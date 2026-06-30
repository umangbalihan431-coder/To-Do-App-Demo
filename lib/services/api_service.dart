import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "https://to-do-app-demo-ygvm.onrender.com";

  static String loginUrl = "$baseUrl/api/login/";
  static String registerUrl = "$baseUrl/api/register/";
  static String refreshTokenUrl = "$baseUrl/api/token/refresh/";

  static String todosUrl = "$baseUrl/api/todos/";
  static String saveFcmTokenUrl = "$baseUrl/api/save-fcm-token/";

  static String uploadImageUrl = "$baseUrl/api/upload-image/";
  static String userImagesUrl = "$baseUrl/api/user-images/";

  static String uploadMediaUrl = "$baseUrl/api/upload-media/";
  static String userMediaUrl = "$baseUrl/api/user-media/";

  static String todoDetailUrl(String id) {
    return "$baseUrl/api/todos/$id/";
  }

  static String deleteImageUrl(String id) {
    return "$baseUrl/api/user-images/$id/";
  }

  static Future<Map<String, String>> jsonHeaders() async {
    final token = await AuthService.getAccessToken();

    final headers = {
      "Content-Type": "application/json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await AuthService.getAccessToken();

    if (token == null || token.isEmpty) {
      return {};
    }

    return {
      "Authorization": "Bearer $token",
    };
  }

  static Future<http.Response> get(String url) async {
    var response = await http.get(
      Uri.parse(url),
      headers: await jsonHeaders(),
    );

    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshAccessToken();

      if (refreshed) {
        response = await http.get(
          Uri.parse(url),
          headers: await jsonHeaders(),
        );
      }
    }

    return response;
  }

  static Future<http.Response> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    var response = await http.post(
      Uri.parse(url),
      headers: await jsonHeaders(),
      body: jsonEncode(body ?? {}),
    );

    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshAccessToken();

      if (refreshed) {
        response = await http.post(
          Uri.parse(url),
          headers: await jsonHeaders(),
          body: jsonEncode(body ?? {}),
        );
      }
    }

    return response;
  }

  static Future<http.Response> put(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    var response = await http.put(
      Uri.parse(url),
      headers: await jsonHeaders(),
      body: jsonEncode(body ?? {}),
    );

    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshAccessToken();

      if (refreshed) {
        response = await http.put(
          Uri.parse(url),
          headers: await jsonHeaders(),
          body: jsonEncode(body ?? {}),
        );
      }
    }

    return response;
  }

  static Future<http.Response> delete(String url) async {
    var response = await http.delete(
      Uri.parse(url),
      headers: await jsonHeaders(),
    );

    if (response.statusCode == 401) {
      final refreshed = await AuthService.refreshAccessToken();

      if (refreshed) {
        response = await http.delete(
          Uri.parse(url),
          headers: await jsonHeaders(),
        );
      }
    }

    return response;
  }

  static Future<http.Response> uploadImage(
  String url,
  File imageFile, {
  String fieldName = "image",
}) async {
  var response = await _uploadImageOnce(
    url,
    imageFile,
    fieldName: fieldName,
  );

  if (response.statusCode == 401) {
    final refreshed = await AuthService.refreshAccessToken();

    if (refreshed) {
      response = await _uploadImageOnce(
        url,
        imageFile,
        fieldName: fieldName,
      );
    }
  }

  return response;
}

static Future<http.Response> _uploadImageOnce(
  String url,
  File imageFile, {
  required String fieldName,
}) async {
  final request = http.MultipartRequest("POST", Uri.parse(url));

  request.headers.addAll(await authHeaders());

  request.files.add(
    await http.MultipartFile.fromPath(
      fieldName,
      imageFile.path,
    ),
  );

  final streamedResponse = await request.send();
  return http.Response.fromStream(streamedResponse);
  }
}