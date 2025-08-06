import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Uygulaması',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: child!,
        );
      },
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9C4),
      ),
      home: const LoginScreen(),
    );
  }
}
