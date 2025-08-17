import 'package:todo_app_gelismis/services/api_service.dart';
import 'package:todo_app_gelismis/database/database_helper.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:todo_app_gelismis/model/user_model.dart';

class HybridService {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _useApi = true;
  
  // API bağlantısını test et
  Future<bool> _testApiConnection() async {
    try {
      print('API bağlantısı test ediliyor (10.0.2.2:3000)...');
      await _apiService.getTodos();
      print('API bağlantısı başarılı!');
      return true;
    } catch (e) {
      print('API bağlantısı başarısız, local database kullanılacak: $e');
      return false;
    }
  }
  
  // Login işlemi
  Future<Map<String, dynamic>> login(String username, String password) async {
    if (_useApi) {
      try {
        final result = await _apiService.login(username, password);
        return result;
      } catch (e) {
        // API başarısız olursa local database'e geç
        _useApi = false;
        final user = await _dbHelper.getUserByUsername(username);
        if (user != null && user.password == password) {
          return {
            'user': {
              'id': user.id,
              'username': user.username,
              'name': user.name,
            },
            'message': 'Local database ile giriş yapıldı',
          };
        } else {
          throw Exception('Kullanıcı adı veya şifre hatalı');
        }
      }
    } else {
      // Local database kullan
      final user = await _dbHelper.getUserByUsername(username);
      if (user != null && user.password == password) {
        return {
          'user': {
            'id': user.id,
            'username': user.username,
            'name': user.name,
          },
          'message': 'Local database ile giriş yapıldı',
        };
      } else {
        throw Exception('Kullanıcı adı veya şifre hatalı');
      }
    }
  }
  
  // Register işlemi
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    if (_useApi) {
      try {
        final result = await _apiService.register(username, email, password);
        return result;
      } catch (e) {
        // API başarısız olursa local database'e geç
        _useApi = false;
        final newUser = UserModel(
          name: username,
          surname: '',
          username: username,
          password: password,
          createdAt: DateTime.now(),
        );
        final userId = await _dbHelper.insertUser(newUser);
        return {
          'user': {
            'id': userId,
            'username': username,
            'name': username,
          },
          'message': 'Local database ile kayıt yapıldı',
        };
      }
    } else {
      // Local database kullan
      final newUser = UserModel(
        name: username,
        surname: '',
        username: username,
        password: password,
        createdAt: DateTime.now(),
      );
      final userId = await _dbHelper.insertUser(newUser);
      return {
        'user': {
          'id': userId,
          'username': username,
          'name': username,
        },
        'message': 'Local database ile kayıt yapıldı',
      };
    }
  }
  
  // Todo listesi al
  Future<List<TodoModel>> getTodos(int userId) async {
    if (_useApi) {
      try {
        final todosData = await _apiService.getTodos();
        return todosData.map((todoData) => TodoModel(
          id: todoData['id']?.toString() ?? '',
          title: todoData['title'] ?? '',
          description: todoData['description'] ?? '',
          isDone: todoData['isCompleted'] ?? todoData['isDone'] ?? false,
          dueDate: todoData['dueDate'] != null 
              ? DateTime.parse(todoData['dueDate']) 
              : null,
          createdAt: DateTime.parse(todoData['createdAt'] ?? DateTime.now().toIso8601String()),
          userId: todoData['userId'] ?? userId,
        )).toList();
      } catch (e) {
        _useApi = false;
        return await _dbHelper.getTodosByUserId(userId);
      }
    } else {
      return await _dbHelper.getTodosByUserId(userId);
    }
  }
  
  // Todo oluştur
  Future<void> createTodo(TodoModel todo) async {
    if (_useApi) {
      try {
        await _apiService.createTodo(todo.toMap());
      } catch (e) {
        _useApi = false;
        await _dbHelper.insertTodo(todo);
      }
    } else {
      await _dbHelper.insertTodo(todo);
    }
  }
  
  // Todo güncelle
  Future<void> updateTodo(TodoModel todo) async {
    if (_useApi) {
      try {
        await _apiService.updateTodo(todo.id, todo.toMap());
      } catch (e) {
        _useApi = false;
        await _dbHelper.updateTodo(todo);
      }
    } else {
      await _dbHelper.updateTodo(todo);
    }
  }
  
  // Todo sil
  Future<void> deleteTodo(String id) async {
    if (_useApi) {
      try {
        await _apiService.deleteTodo(id);
      } catch (e) {
        _useApi = false;
        await _dbHelper.deleteTodo(id);
      }
    } else {
      await _dbHelper.deleteTodo(id);
    }
  }
  
  // Kullanıcı profili al
  Future<UserModel?> getUserProfile(int userId) async {
    if (_useApi) {
      try {
        final userData = await _apiService.getUserProfile();
        return UserModel(
          id: userData['id'] ?? userId,
          name: userData['name'] ?? userData['username'] ?? '',
          surname: userData['surname'] ?? '',
          username: userData['username'] ?? '',
          password: '',
          createdAt: DateTime.parse(userData['createdAt'] ?? DateTime.now().toIso8601String()),
        );
      } catch (e) {
        _useApi = false;
        return await _dbHelper.getUserById(userId);
      }
    } else {
      return await _dbHelper.getUserById(userId);
    }
  }
  
  // Logout
  Future<void> logout() async {
    if (_useApi) {
      try {
        await _apiService.logout();
      } catch (e) {
        print('Logout hatası: $e');
      }
    }
  }
  
  // API bağlantısını yeniden test et
  Future<void> retryApiConnection() async {
    _useApi = await _testApiConnection();
  }
  
  // Hangi modda çalıştığını kontrol et
  bool get isUsingApi => _useApi;
} 