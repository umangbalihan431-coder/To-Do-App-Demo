class TodoModel {
  final String id;
  final String taskName;
  final bool completed;
  final String createdAt;

  const TodoModel({
    required this.id,
    required this.taskName,
    required this.completed,
    required this.createdAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json["_id"]?.toString() ?? "",
      taskName: json["task_name"]?.toString() ?? "",
      completed: json["completed"] == true,
      createdAt: json["created_at"]?.toString() ?? "",
    );
  }

  TodoModel copyWith({
    String? id,
    String? taskName,
    bool? completed,
    String? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}