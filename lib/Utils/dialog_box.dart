import 'package:flutter/material.dart';
import 'my_button.dart';

class DialogBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const DialogBox({super.key, required this.controller, this.onSave, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 244, 220, 2),
      content: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

          //user input
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Add a new task...',
              filled: true,
              fillColor: Colors.yellow[100],
            ),
          ),
          //buttons -> save + cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //save button
              MyButton (text: 'Save', onPressed: onSave ?? () {}),
              const SizedBox(width: 10),
              //cancel button
              MyButton(text: 'Cancel', onPressed: onCancel ?? () { Navigator.of(context).pop(); }),
            ],
          )
        ])
      )
    );
  }
}