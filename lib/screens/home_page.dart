import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'gallery_screen.dart';
import 'documents_screen.dart';
import '../app/app_colors.dart';
import '../models/todo_model.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';
import '../widgets/dialog_box.dart';
import '../widgets/todo_tile.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final TextEditingController _controller = TextEditingController();

  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoModel> toDoList = [];
  bool isLoading = false;
  String errorMessage = "";

  String getEmail() {
    return AuthService.getEmail() ?? "User";
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

  Future<void> fetchTodos() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final todos = await TodoService.fetchTodos();

      if (!mounted) return;

      setState(() {
        toDoList = todos;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not load tasks";
        isLoading = false;
      });
    }
  }

  Future<void> saveNewTask() async {
    final taskName = widget._controller.text.trim();

    if (taskName.isEmpty) return;

    Navigator.of(context).pop();

    try {
      await TodoService.addTodo(taskName);
      widget._controller.clear();
      await fetchTodos();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = "Could not add task";
      });
    }
  }

  Future<void> checkBoxChanged(bool? value, int index) async {
    final todo = toDoList[index];
    final newValue = value ?? false;

    setState(() {
      toDoList[index] = todo.copyWith(completed: newValue);
    });

    try {
      await TodoService.updateTodo(
        todoId: todo.id,
        completed: newValue,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        toDoList[index] = todo;
        errorMessage = "Could not update task";
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

    setState(() {
      toDoList.removeAt(index);
      errorMessage = "";
    });

    try {
      await TodoService.deleteTodo(todo.id);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        toDoList.insert(index, todo);
        errorMessage = "Could not delete task";
      });
    }
  }

  Future<void> logout() async {
    await AuthService.logout();

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
              icon: const Icon(Icons.notifications_rounded),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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

  int get completedCount {
    return toDoList.where((todo) => todo.completed).length;
  }

  int get pendingCount {
    return toDoList.length - completedCount;
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.cardSoft,
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = getEmail();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text("Tasks"),
        actions: [
          notificationBell(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const GalleryScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.photo_library_rounded),
          ),

          IconButton(
            tooltip: "Documents",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DocumentsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.description_rounded),
          ),
          IconButton(
            onPressed: fetchTodos,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createNewTask,
        icon: const Icon(Icons.add_rounded),
        label: const Text("New"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchTodos,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2E7D32),
                          Color(0xFF66BB6A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.18),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome back",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      statCard(
                        title: "Pending",
                        value: pendingCount.toString(),
                        icon: Icons.pending_actions_rounded,
                      ),
                      const SizedBox(width: 12),
                      statCard(
                        title: "Done",
                        value: completedCount.toString(),
                        icon: Icons.task_alt_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              if (errorMessage.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ),
                ),
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              if (toDoList.isEmpty && !isLoading)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.task_alt_rounded,
                          color: AppColors.muted,
                          size: 62,
                        ),
                        SizedBox(height: 14),
                        Text(
                          "No tasks yet",
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap New to create your first task.",
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
  sliver: SliverGrid(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final todo = toDoList[index];

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: ToDoTile(
            key: ValueKey(todo.id),
            taskName: todo.taskName,
            taskCompleted: todo.completed,
            createdAt: todo.createdAt,
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          ),
        );
      },
      childCount: toDoList.length,
    ),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.0,
    ),
  ),
),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}