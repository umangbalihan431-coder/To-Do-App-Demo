import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../app/app_colors.dart';

class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final String createdAt;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.createdAt,
    required this.onChanged,
    required this.deleteFunction,
  });

  String formatDate(String value) {
    if (value.isEmpty) return "No date";

    try {
      final date = DateTime.parse(value).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return "$day/$month • $hour:$minute";
    } catch (_) {
      return value.length > 10 ? value.substring(0, 10) : value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: taskCompleted
              ? AppColors.cardSoft
              : AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.07 * 255).round()),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    SizedBox(
      width: 34,
      height: 34,
      child: Checkbox(
        value: taskCompleted,
        onChanged: onChanged,
        activeColor: AppColors.accent,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        taskName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.text,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          height: 1.2,
          decoration: taskCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
    ),
  ],
),

const Spacer(),

Align(
  alignment: Alignment.bottomLeft,
  child: Text(
    formatDate(createdAt),
    style: const TextStyle(
      fontSize: 11,
      color: AppColors.muted,
    ),
  ),
),
            const SizedBox(height: 8),
            Text(
              formatDate(createdAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}