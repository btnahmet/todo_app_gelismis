import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Login UI',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
