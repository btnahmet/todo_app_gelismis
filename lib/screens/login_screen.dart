import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/screens/home_screen.dart';
import 'package:todo_app_gelismis/screens/register_screen.dart';
import 'package:todo_app_gelismis/database/database_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı adı ve şifre boş olamaz!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserByUsername(username);

      if (user != null && user.password == password) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: user.id!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı adı veya şifre hatalı!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;
    final isLandscape = width > height;

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF176), Color(0xFFFFF59D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? width * 0.15 : width * 0.08,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isLandscape ? height * 0.05 : height * 0.1),
                      
                      // Logo Container
                      Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'To-do',
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 24,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 40 : 30),
                      
                      // Welcome Text
                      Text(
                        'Hoşgeldiniz !',
                        style: TextStyle(
                          fontSize: isTablet ? 32 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      
                      SizedBox(height: isTablet ? 50 : 40),
                      
                      // Form Container
                      Container(
                        width: isTablet ? width * 0.4 : double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 400 : double.infinity,
                        ),
                        child: Column(
                          children: [
                            // Username Field
                            TextField(
                              controller: _usernameController,
                              style: TextStyle(fontSize: isTablet ? 18 : 16),
                              decoration: InputDecoration(
                                labelText: 'Kullanıcı Adı',
                                labelStyle: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueGrey),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: isTablet ? 30 : 20),
                            
                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(fontSize: isTablet ? 18 : 16),
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                labelStyle: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueGrey),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.blueGrey,
                                    size: isTablet ? 28 : 24,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            
                            SizedBox(height: isTablet ? 50 : 40),
                            
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 20 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: isTablet ? 15 : 10),
                            
                            // Forgot Password Text
                            Text(
                              'Şifreni mi unuttun?',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                            
                            SizedBox(height: isTablet ? 40 : 30),
                            
                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 20 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'Hesap Oluştur',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isLandscape ? height * 0.05 : height * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
