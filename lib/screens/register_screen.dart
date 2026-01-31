import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/screens/home_screen.dart';
import 'package:todo_app_gelismis/services/hybrid_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final hybridService = HybridService();

        // Hybrid service ile kayıt ol
        final response = await hybridService.register(
          _usernameController.text.trim(),
          '${_nameController.text.trim()}.${_surnameController.text.trim()}@example.com', // Email oluştur
          _passwordController.text,
        );

        // Hangi modda çalıştığını göster
        final message = response['message'] ?? 'Kayıt başarılı! Hoşgeldiniz.';
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
      }
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height:
                                isLandscape ? height * 0.03 : height * 0.05),

                        // Logo Container
                        Container(
                          padding: EdgeInsets.all(isTablet ? 24 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius:
                                BorderRadius.circular(isTablet ? 20 : 16),
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

                        // Title
                        Text(
                          'Hesap Oluştur',
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
                            maxWidth: isTablet ? 500 : double.infinity,
                          ),
                          child: Column(
                            children: [
                              // Ad
                              TextFormField(
                                controller: _nameController,
                                style: TextStyle(fontSize: isTablet ? 18 : 16),
                                decoration: InputDecoration(
                                  labelText: 'Ad',
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ad alanı boş olamaz';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: isTablet ? 30 : 20),

                              // Soyad
                              TextFormField(
                                controller: _surnameController,
                                style: TextStyle(fontSize: isTablet ? 18 : 16),
                                decoration: InputDecoration(
                                  labelText: 'Soyad',
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Soyad alanı boş olamaz';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: isTablet ? 30 : 20),

                              // Kullanıcı Adı
                              TextFormField(
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
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Kullanıcı adı boş olamaz';
                                  }
                                  if (value.length < 3) {
                                    return 'Kullanıcı adı en az 3 karakter olmalı';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: isTablet ? 30 : 20),

                              // Şifre
                              TextFormField(
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
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Şifre boş olamaz';
                                  }
                                  if (value.length < 6) {
                                    return 'Şifre en az 6 karakter olmalı';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: isTablet ? 30 : 20),

                              // Şifre Tekrar
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                style: TextStyle(fontSize: isTablet ? 18 : 16),
                                decoration: InputDecoration(
                                  labelText: 'Şifre Tekrar',
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
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.blueGrey,
                                      size: isTablet ? 28 : 24,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Şifre tekrarı boş olamaz';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Şifreler eşleşmiyor';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: isTablet ? 50 : 40),

                              // Kayıt Ol Butonu
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _register,
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
                                    'Kayıt Ol',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: isTablet ? 30 : 20),

                              // Giriş Yap Linki
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Zaten hesabınız var mı? ',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Giriş Yap',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 16 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height:
                                isLandscape ? height * 0.03 : height * 0.05),
                      ],
                    ),
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
