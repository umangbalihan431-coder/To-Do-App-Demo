import 'dart:convert';

import '../models/todo_model.dart';
import 'api_service.dart';

class TodoService {
  static Future<List<TodoModel>> fetchTodos() async {
    final response = await ApiService.get(ApiService.todosUrl);

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch todos");
    }

    final List data = jsonDecode(response.body);

    return data
        .map<TodoModel>((item) => TodoModel.fromJson(item))
        .toList();
  }

  static Future<void> addTodo(String taskName) async {
    final response = await ApiService.post(
      ApiService.todosUrl,
      body: {"task_name": taskName},
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add todo");
    }
  }

  static Future<void> updateTodo({
    required String todoId,
    required bool completed,
  }) async {
    final response = await ApiService.put(
      ApiService.todoDetailUrl(todoId),
      body: {"completed": completed},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update todo");
    }
  }

  static Future<void> deleteTodo(String todoId) async {
    final response = await ApiService.delete(
      ApiService.todoDetailUrl(todoId),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete todo");
    }
  }
}