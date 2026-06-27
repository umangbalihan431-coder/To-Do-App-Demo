import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Utils/login_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('myBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('myBox');
    final token = box.get('TOKEN');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.yellow,
      ),
      home: token == null ? const LoginPage() : HomePage(),
    );
  }
}