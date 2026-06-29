import 'package:flutter/material.dart';

import '../app/app_colors.dart';

class DialogBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const DialogBox({
    super.key,
    required this.controller,
    this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      title: const Text(
        "New task",
        style: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          hintText: "What do you need to do?",
          hintStyle: const TextStyle(color: AppColors.muted),
          filled: true,
          fillColor: AppColors.bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: onSave,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }
}