import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'Utils/todo_tile.dart';
import 'Utils/dialog_box.dart';
import 'Utils/login_page.dart';

class HomePage extends StatefulWidget {
  final TextEditingController _controller = TextEditingController();

  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> toDoList = [
    ['Make Tutorials', false],
    ['Do Exercise', false],
  ];

  String getTokenPreview() {
    final box = Hive.box('myBox');
    final token = box.get("TOKEN");

    if (token == null) {
      return "No JWT token found";
    }

    final tokenText = token.toString();

    if (tokenText.length > 45) {
      return "${tokenText.substring(0, 45)}...";
    }

    return tokenText;
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      toDoList[index][1] = value!;
    });
  }

  void saveNewTask() {
    if (widget._controller.text.trim().isEmpty) return;

    setState(() {
      toDoList.add([widget._controller.text.trim(), false]);
      widget._controller.clear();
    });

    Navigator.of(context).pop();
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

  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
  }

  Future<void> logout() async {
    final box = Hive.box('myBox');
    await box.delete("TOKEN");
    await box.delete("REFRESH_TOKEN");
    await box.delete("EMAIL");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('myBox');
    final email = box.get("EMAIL") ?? "Unknown user";

    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text("TO DO"),
        backgroundColor: Colors.yellow[600],
        actions: [
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
          Expanded(
            child: ListView.builder(
              itemCount: toDoList.length,
              itemBuilder: (context, index) {
                return ToDoTile(
                  taskName: toDoList[index][0],
                  taskCompleted: toDoList[index][1],
                  onChanged: (value) => checkBoxChanged(value, index),
                  deleteFunction: (context) => deleteTask(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}