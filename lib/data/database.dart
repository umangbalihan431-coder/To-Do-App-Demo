import 'package:hive_flutter/hive_flutter.dart';

class ToDoDatabase {
  List toDoList = [];

  //reference the box
  final Box myBox = Hive.box('myBox');

  //run this method if this is the 1st time ever opening this app
  void createInitialData() {
    toDoList = [
      ["Make tutorial", false],
      ["Do exercise", false],
    ];
  }

  //load the data from database
  void loadData() {
    toDoList = myBox.get("TODOLIST");
  }

  //update the database
  void updateDatabase() {
    myBox.put("TODOLIST", toDoList);
  }
}