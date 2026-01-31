import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/screens/home_screen.dart';
import 'package:todo_app_gelismis/screens/register_screen.dart';
import 'package:todo_app_gelismis/services/hybrid_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kaydedilmiş kullanıcı bilgilerini yükle
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('saved_username');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (rememberMe && savedUsername != null && savedPassword != null) {
        setState(() {
          _usernameController.text = savedUsername;
          _passwordController.text = savedPassword;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Kaydedilmiş bilgiler yüklenirken hata: $e');
    }
  }

  // Kullanıcı bilgilerini kaydet
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString(
            'saved_username', _usernameController.text.trim());
        await prefs.setString('saved_password', _passwordController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      print('Bilgiler kaydedilirken hata: $e');
    }
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Hybrid service ile giriş yap
      final hybridService = HybridService();
      final response = await hybridService.login(username, password);

      // Kullanıcı bilgilerini kaydet
      await _saveCredentials();

      // Hangi modda çalıştığını göster
      final message = response['message'] ?? 'Giriş başarılı!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      // Kullanıcı ID'sini response'dan al veya varsayılan değer kullan
      final userId = response['user']?['id'] ?? 1;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: userId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                      SizedBox(
                          height: isLandscape ? height * 0.05 : height * 0.1),

                      // Logo Container
                      Container(
                        padding: EdgeInsets.all(isTablet ? 0 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius:
                              BorderRadius.circular(isTablet ? 20 : 16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icon.png',
                          width: isTablet ? 160 : 120,
                          height: isTablet ? 160 : 120,
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: isTablet ? 40 : 30),

                      // Welcome Text
                      Text(
                        'Hoşgeldiniz',
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
                                  borderSide:
                                      BorderSide(color: Colors.blueGrey),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 2),
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
                                  borderSide:
                                      BorderSide(color: Colors.blueGrey),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 2),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
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

                            SizedBox(height: isTablet ? 20 : 15),

                            // Beni Hatırla Switch
                            Row(
                              children: [
                                Transform.scale(
                                  scale: isTablet ? 1.2 : 1.0,
                                  child: Switch(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value;
                                      });
                                    },
                                    activeThumbColor: Colors.blueGrey,
                                    activeTrackColor:
                                        Colors.blueGrey.withOpacity(0.3),
                                  ),
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Text(
                                  'Beni Hatırla',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isTablet ? 30 : 25),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 20 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        isTablet ? 35 : 30),
                                  ),
                                  elevation: 4,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: isTablet ? 24 : 20,
                                        width: isTablet ? 24 : 20,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.blueGrey,
                                        ),
                                      )
                                    : Text(
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
                                      builder: (context) =>
                                          const RegisterScreen(),
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
                                    borderRadius: BorderRadius.circular(
                                        isTablet ? 35 : 30),
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

                      SizedBox(
                          height: isLandscape ? height * 0.05 : height * 0.1),
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
