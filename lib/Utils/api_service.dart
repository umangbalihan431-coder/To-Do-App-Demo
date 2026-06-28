class ApiService {
  static const String baseUrl = "https://to-do-app-demo-ygvm.onrender.com";

  static String loginUrl = "$baseUrl/api/login/";
  static String registerUrl = "$baseUrl/api/register/";
  static String protectedUrl = "$baseUrl/api/protected/";
  static String todosUrl = "$baseUrl/api/todos/";
  static String saveFcmTokenUrl = "$baseUrl/api/save-fcm-token/";

  static String todoDetailUrl(String id) {
    return "$baseUrl/api/todos/$id/";
  }
}