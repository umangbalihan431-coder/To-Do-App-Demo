class TodoModel {
  final String id;
  final String taskName;
  final bool completed;

  const TodoModel({
    required this.id,
    required this.taskName,
    required this.completed,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json["_id"]?.toString() ?? "",
      taskName: json["task_name"]?.toString() ?? "",
      completed: json["completed"] == true,
    );
  }

  TodoModel copyWith({
    String? id,
    String? taskName,
    bool? completed,
  }) {
    return TodoModel(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      completed: completed ?? this.completed,
    );
  }
}