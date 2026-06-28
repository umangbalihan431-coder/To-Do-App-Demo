import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'Utils/api_service.dart';
import 'Utils/dialog_box.dart';
import 'Utils/login_page.dart';
import 'Utils/todo_tile.dart';

class HomePage extends StatefulWidget {
  final TextEditingController _controller = TextEditingController();

  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> toDoList = [];

  bool isLoading = false;
  String errorMessage = "";

  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  String? getToken() {
    final box = Hive.box('myBox');
    return box.get("TOKEN");
  }

  String getEmail() {
    final box = Hive.box('myBox');
    return box.get("EMAIL") ?? "Unknown user";
  }

  String getTokenPreview() {
    final token = getToken();

    if (token == null) return "No JWT token found";
    if (token.length > 45) return "${token.substring(0, 45)}...";
    return token;
  }

  Map<String, String> authHeaders() {
    final token = getToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> resetNotificationCount() async {
    final box = Hive.box('myBox');
    await box.put("NOTIFICATION_COUNT", 0);
  }

  Future<void> openCamera() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
      });
    } catch (e) {
      setState(() {
        errorMessage = "Camera error: $e";
      });
    }
  }

  Future<void> fetchTodos() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.get(
        Uri.parse(ApiService.todosUrl),
        headers: authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          toDoList = data.map((item) {
            return {
              "_id": item["_id"],
              "task_name": item["task_name"],
              "completed": item["completed"],
            };
          }).toList();

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load todos: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Connection error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> saveNewTask() async {
    final taskName = widget._controller.text.trim();

    if (taskName.isEmpty) return;

    Navigator.of(context).pop();

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse(ApiService.todosUrl),
        headers: authHeaders(),
        body: jsonEncode({"task_name": taskName}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        widget._controller.clear();
        await fetchTodos();
      } else {
        setState(() {
          errorMessage = "Failed to add todo: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Connection error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> checkBoxChanged(bool? value, int index) async {
    final todo = toDoList[index];
    final todoId = todo["_id"];

    setState(() {
      toDoList[index]["completed"] = value ?? false;
    });

    try {
      final response = await http.put(
        Uri.parse(ApiService.todoDetailUrl(todoId)),
        headers: authHeaders(),
        body: jsonEncode({"completed": value ?? false}),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = "Failed to update todo: ${response.body}";
          toDoList[index]["completed"] = !(value ?? false);
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Connection error: $e";
        toDoList[index]["completed"] = !(value ?? false);
      });
    }
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: widget._controller,
          onSave: saveNewTask,
          onCancel: () {
            widget._controller.clear();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> deleteTask(int index) async {
    final todo = toDoList[index];
    final todoId = todo["_id"];

    final removedTodo = toDoList[index];

    setState(() {
      toDoList.removeAt(index);
      errorMessage = "";
    });

    try {
      final response = await http.delete(
        Uri.parse(ApiService.todoDetailUrl(todoId)),
        headers: authHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          toDoList.insert(index, removedTodo);
          errorMessage = "Failed to delete todo: ${response.body}";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        toDoList.insert(index, removedTodo);
        errorMessage = "Connection error: $e";
      });
    }
  }

  Future<void> logout() async {
    final box = Hive.box('myBox');
    await box.delete("TOKEN");
    await box.delete("REFRESH_TOKEN");
    await box.delete("EMAIL");
    await box.put("NOTIFICATION_COUNT", 0);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget notificationBell() {
    final box = Hive.box('myBox');

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: ["NOTIFICATION_COUNT"]),
      builder: (context, Box box, _) {
        final count = box.get("NOTIFICATION_COUNT", defaultValue: 0);

        return Stack(
          children: [
            IconButton(
              onPressed: resetNotificationCount,
              icon: const Icon(Icons.notifications),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = getEmail();

    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text("TO DO"),
        backgroundColor: Colors.yellow[600],
        actions: [
          notificationBell(),
          IconButton(
            onPressed: openCamera,
            icon: const Icon(Icons.camera_alt),
          ),
          IconButton(
            onPressed: fetchTodos,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              "JWT Status: Logged in\nEmail: $email\nToken: ${getTokenPreview()}",
            ),
          ),

          if (selectedImage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedImage = null;
                      });
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Remove Photo"),
                  ),
                ],
              ),
            ),

          if (errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),

          Expanded(
            child: toDoList.isEmpty && !isLoading
                ? const Center(
                    child: Text(
                      "No todos yet. Tap + to add one.",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchTodos,
                    child: ListView.builder(
                      itemCount: toDoList.length,
                      itemBuilder: (context, index) {
                        final todo = toDoList[index];

                        return ToDoTile(
                          taskName: todo["task_name"] ?? "",
                          taskCompleted: todo["completed"] ?? false,
                          onChanged: (value) => checkBoxChanged(value, index),
                          deleteFunction: (context) => deleteTask(index),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}