import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3001/api';
  static const String authTokenKey = 'auth_token';
  
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Interceptor ekle 
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Token varsa header'a ekle
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }
  
  // Auth token'ı kaydet
  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(authTokenKey, token);
  }
  
  // Auth token'ı al
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }
  
  // Auth token'ı sil
  Future<void> _removeAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authTokenKey);
  }
  
  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          await _saveAuthToken(data['token']);
        }
        // Sizin API'niz sadece token dönüyor, user bilgisini token'dan çıkar
        return {
          'token': data['token'],
          'user': {
            'id': 1, // Varsayılan ID
            'username': username,
            'name': username,
          },
          'message': 'Giriş başarılı',
        };
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Kullanıcı adı veya şifre hatalı');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Bağlantı zaman aşımı. Lütfen internet bağlantınızı kontrol edin.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Sunucuya bağlanılamıyor. Lütfen API sunucusunun çalıştığından emin olun.');
      }
      throw Exception('Bağlantı hatası: ${e.message}');
    }
  }
  
  // Register
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      // Email'den name ve surname çıkar
      final nameParts = email.split('@')[0].split('.');
      final name = nameParts.isNotEmpty ? nameParts[0] : username;
      final surname = nameParts.length > 1 ? nameParts[1] : 'User'; // Boş olamaz
      
      final requestData = {
        'name': name,
        'surname': surname,
        'username': username,
        'password': password,
      };
      
      print('Register request data: $requestData');
      print('Register URL: ${_dio.options.baseUrl}/register');
      print('Full URL: ${_dio.options.baseUrl}/register');
      
      final response = await _dio.post('/register', data: requestData);
      print('Register response status: ${response.statusCode}');
      print('Register response data: ${response.data}');
      
      if (response.statusCode == 201) {
        final data = response.data;
        // Sizin API'niz register'da token dönmüyor, sadece message
        return {
          'message': data['message'] ?? 'Kayıt başarılı',
          'user': {
            'id': 1, // Varsayılan ID
            'username': username,
            'name': name,
          },
        };
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('Bu kullanıcı adı veya email zaten kullanımda');
      }
      throw Exception('Kayıt hatası: ${e.message}');
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      // Sizin API'nizde logout endpoint'i yok, sadece token'ı siliyoruz
      print('Logout: Token siliniyor');
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _removeAuthToken();
    }
  }
  
  // Get todos
  Future<List<Map<String, dynamic>>> getTodos() async {
    try {
      final response = await _dio.get('/todos');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load todos');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _removeAuthToken();
        throw Exception('Oturum süresi doldu');
      }
      throw Exception('Görevler yüklenirken hata: ${e.message}');
    }
  }
  
  // Create todo
  Future<Map<String, dynamic>> createTodo(Map<String, dynamic> todoData) async {
    try {
      final response = await _dio.post('/todos', data: todoData);
      
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create todo');
      }
    } on DioException catch (e) {
      throw Exception('Görev oluşturulurken hata: ${e.message}');
    }
  }
  
  // Update todo
  Future<Map<String, dynamic>> updateTodo(String id, Map<String, dynamic> todoData) async {
    try {
      final response = await _dio.put('/todos/$id', data: todoData);
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update todo');
      }
    } on DioException catch (e) {
      throw Exception('Görev güncellenirken hata: ${e.message}');
    }
  }
  
  // Delete todo
  Future<void> deleteTodo(String id) async {
    try {
      final response = await _dio.delete('/todos/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete todo');
      }
    } on DioException catch (e) {
      throw Exception('Görev silinirken hata: ${e.message}');
    }
  }
  
  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/profile');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _removeAuthToken();
        throw Exception('Oturum süresi doldu');
      }
      throw Exception('Profil yüklenirken hata: ${e.message}');
    }
  }
  
  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put('/profile', data: profileData);
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception('Profil güncellenirken hata: ${e.message}');
    }
  }
} 