import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../app/app_colors.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete_rounded,
              backgroundColor: AppColors.danger,
              borderRadius: BorderRadius.circular(22),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: taskCompleted ? AppColors.card.withValues(alpha: 0.55) : AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Checkbox(
                value: taskCompleted,
                onChanged: onChanged,
                activeColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  taskName,
                  style: TextStyle(
                    color: taskCompleted ? AppColors.muted : AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration:
                        taskCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}