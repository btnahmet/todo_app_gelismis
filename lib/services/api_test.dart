import 'package:todo_app_gelismis/services/api_service.dart';

class ApiTest {
  static Future<void> testApiConnection() async {
    final apiService = ApiService();
    
    try {
             print('API bağlantısı test ediliyor (10.0.2.2:3001)...');
      
      // Test register
      print('Register test ediliyor...');
      final testUsername = 'testuser_${DateTime.now().millisecondsSinceEpoch}';
      print('Test username: $testUsername');
      final registerResponse = await apiService.register(
        testUsername,
        'test@example.com',
        'password123',
      );
      print('Register başarılı: ${registerResponse['user']?['username']}');
      
      // Test login
      print('Login test ediliyor...');
      final loginResponse = await apiService.login(
        registerResponse['user']?['username'] ?? 'testuser',
        'password123',
      );
      print('Login başarılı: ${loginResponse['user']?['username']}');
      
      // Test create todo
      print('Todo oluşturma test ediliyor...');
      final todoData = {
        'title': 'Test Todo',
        'description': 'Bu bir test görevidir',
        'isCompleted': false,
        'dueDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      };
      final createResponse = await apiService.createTodo(todoData);
      print('Todo oluşturuldu: ${createResponse['title']}');
      
      // Test get todos
      print('Todo listesi alınıyor...');
      final todos = await apiService.getTodos();
      print('${todos.length} adet todo bulundu');
      
             // Test update todo
       if (todos.isNotEmpty) {
         print('Todo güncelleme test ediliyor...');
         final todoId = todos.first['id'].toString(); // int'i String'e çevir
         final updateData = {
           'title': 'Güncellenmiş Test Todo',
           'isCompleted': true,
         };
         final updateResponse = await apiService.updateTodo(todoId, updateData);
         print('Todo güncellendi: ${updateResponse['title']}');
       }
      
             // Test delete todo
       if (todos.isNotEmpty) {
         print('Todo silme test ediliyor...');
         final todoId = todos.first['id'].toString(); // int'i String'e çevir
         await apiService.deleteTodo(todoId);
         print('Todo silindi');
       }
      
      // Test get profile
      print('Profil bilgileri alınıyor...');
      final profile = await apiService.getUserProfile();
      print('Profil alındı: ${profile['username']}');
      
      // Test logout
      print('Logout test ediliyor...');
      await apiService.logout();
      print('Logout başarılı');
      
      print('Tüm API testleri başarılı!');
      
    } catch (e) {
      print('API test hatası: $e');
    }
  }
} 