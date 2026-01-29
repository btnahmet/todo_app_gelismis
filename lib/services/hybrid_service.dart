// import 'package:todo_app_gelismis/services/api_service.dart';
// import 'package:todo_app_gelismis/database/database_helper.dart';
// import 'package:todo_app_gelismis/model/todo_model.dart';
// import 'package:todo_app_gelismis/model/user_model.dart';

// class HybridService {
//   final ApiService _apiService = ApiService();
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   bool _useApi = true;
  
//   // API bağlantısını test et
//   Future<bool> _testApiConnection() async {
//     try {
//       print('API bağlantısı test ediliyor (10.0.2.2:3000)...');
//       await _apiService.getTodos();
//       print('API bağlantısı başarılı!');
//       return true;
//     } catch (e) {
//       print('API bağlantısı başarısız, local database kullanılacak: $e');
//       return false;
//     }
//   }
  
//   // Login işlemi
//   Future<Map<String, dynamic>> login(String username, String password) async {
//     if (_useApi) {
//       try {
//         final result = await _apiService.login(username, password);
//         return result;
//       } catch (e) {
//         // API başarısız olursa local database'e geç
//         _useApi = false;
//         final user = await _dbHelper.getUserByUsername(username);
//         if (user != null && user.password == password) {
//           return {
//             'user': {
//               'id': user.id,
//               'username': user.username,
//               'name': user.name,
//             },
//             'message': 'Local database ile giriş yapıldı',
//           };
//         } else {
//           throw Exception('Kullanıcı adı veya şifre hatalı');
//         }
//       }
//     } else {
//       // Local database kullan
//       final user = await _dbHelper.getUserByUsername(username);
//       if (user != null && user.password == password) {
//         return {
//           'user': {
//             'id': user.id,
//             'username': user.username,
//             'name': user.name,
//           },
//           'message': 'Local database ile giriş yapıldı',
//         };
//       } else {
//         throw Exception('Kullanıcı adı veya şifre hatalı');
//       }
//     }
//   }
  
//   // Register işlemi
//   Future<Map<String, dynamic>> register(String username, String email, String password) async {
//     if (_useApi) {
//       try {
//         final result = await _apiService.register(username, email, password);
//         return result;
//       } catch (e) {
//         // API başarısız olursa local database'e geç
//         _useApi = false;
//         final newUser = UserModel(
//           name: username,
//           surname: '',
//           username: username,
//           password: password,
//           createdAt: DateTime.now(),
//         );
//         final userId = await _dbHelper.insertUser(newUser);
//         return {
//           'user': {
//             'id': userId,
//             'username': username,
//             'name': username,
//           },
//           'message': 'Local database ile kayıt yapıldı',
//         };
//       }
//     } else {
//       // Local database kullan
//       final newUser = UserModel(
//         name: username,
//         surname: '',
//         username: username,
//         password: password,
//         createdAt: DateTime.now(),
//       );
//       final userId = await _dbHelper.insertUser(newUser);
//       return {
//         'user': {
//           'id': userId,
//           'username': username,
//           'name': username,
//         },
//         'message': 'Local database ile kayıt yapıldı',
//       };
//     }
//   }
  
//   // Todo listesi al
//   Future<List<TodoModel>> getTodos(int userId) async {
//     if (_useApi) {
//       try {
//         final todosData = await _apiService.getTodos();
//         return todosData.map((todoData) => TodoModel(
//           id: todoData['id']?.toString() ?? '',
//           title: todoData['title'] ?? '',
//           description: todoData['description'] ?? '',
//           isDone: todoData['isCompleted'] ?? todoData['isDone'] ?? false,
//           dueDate: todoData['dueDate'] != null 
//               ? DateTime.parse(todoData['dueDate']) 
//               : null,
//           createdAt: DateTime.parse(todoData['createdAt'] ?? DateTime.now().toIso8601String()),
//           userId: todoData['userId'] ?? userId,
//         )).toList();
//       } catch (e) {
//         _useApi = false;
//         return await _dbHelper.getTodosByUserId(userId);
//       }
//     } else {
//       return await _dbHelper.getTodosByUserId(userId);
//     }
//   }
  
//   // Todo oluştur
//   Future<void> createTodo(TodoModel todo) async {
//     if (_useApi) {
//       try {
//         await _apiService.createTodo(todo.toMap());
//       } catch (e) {
//         _useApi = false;
//         await _dbHelper.insertTodo(todo);
//       }
//     } else {
//       await _dbHelper.insertTodo(todo);
//     }
//   }
  
//   // Todo güncelle
//   Future<void> updateTodo(TodoModel todo) async {
//     if (_useApi) {
//       try {
//         await _apiService.updateTodo(todo.id, todo.toMap());
//       } catch (e) {
//         _useApi = false;
//         await _dbHelper.updateTodo(todo);
//       }
//     } else {
//       await _dbHelper.updateTodo(todo);
//     }
//   }
  
//   // Todo sil
//   Future<void> deleteTodo(String id) async {
//     if (_useApi) {
//       try {
//         await _apiService.deleteTodo(id);
//       } catch (e) {
//         _useApi = false;
//         await _dbHelper.deleteTodo(id);
//       }
//     } else {
//       await _dbHelper.deleteTodo(id);
//     }
//   }
  
//   // Kullanıcı profili al
//   Future<UserModel?> getUserProfile(int userId) async {
//     if (_useApi) {
//       try {
//         final userData = await _apiService.getUserProfile();
//         return UserModel(
//           id: userData['id'] ?? userId,
//           name: userData['name'] ?? userData['username'] ?? '',
//           surname: userData['surname'] ?? '',
//           username: userData['username'] ?? '',
//           password: '',
//           createdAt: DateTime.parse(userData['createdAt'] ?? DateTime.now().toIso8601String()),
//         );
//       } catch (e) {
//         _useApi = false;
//         return await _dbHelper.getUserById(userId);
//       }
//     } else {
//       return await _dbHelper.getUserById(userId);
//     }
//   }
  
//   // Logout
//   Future<void> logout() async {
//     if (_useApi) {
//       try {
//         await _apiService.logout();
//       } catch (e) {
//         print('Logout hatası: $e');
//       }
//     }
//   }
  
//   // API bağlantısını yeniden test et
//   Future<void> retryApiConnection() async {
//     _useApi = await _testApiConnection();
//   }
  
//   // Hangi modda çalıştığını kontrol et
//   bool get isUsingApi => _useApi;
// } 
import 'package:todo_app_gelismis/services/api_service.dart';
import 'package:todo_app_gelismis/database/database_helper.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:todo_app_gelismis/model/user_model.dart';

class HybridService {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- LOGIN & REGISTER (Auth İşlemleri) ---
  // Auth işlemleri kritiktir, önce interneti deneriz, olmazsa yerel kayıtlara bakarız.

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // 1. Önce API'yi dene (En güncel veri için)
      final result = await _apiService.login(username, password);
      
      // 2. Giriş başarılıysa, bu kullanıcıyı yerel veritabanına da kaydet/güncelle
      // Böylece bir sonraki sefere internet yoksa bile giriş yapabilir.
      if (result['user'] != null) {
        final userMap = result['user'];
        // API'den gelen user verisini modele çevirip yerel DB'ye yazalım
        // Not: API'den şifre dönmez, o yüzden girilen şifreyi kaydediyoruz (Offline login için)
        final userModel = UserModel(
          id: userMap['id'], // API'den gelen ID
          name: userMap['name'] ?? username,
          surname: userMap['surname'] ?? '',
          username: username,
          password: password, // Şifreyi saklıyoruz
          createdAt: DateTime.now(),
        );
        
        // Kullanıcı var mı kontrol et
        final existingUser = await _dbHelper.getUserByUsername(username);
        if (existingUser == null) {
          await _dbHelper.insertUser(userModel);
        }
      }
      
      return result;
    } catch (e) {
      print('API Login başarısız, yerel veritabanı deneniyor: $e');
      
      // 3. API hatası varsa yerel veritabanına bak
      final user = await _dbHelper.getUserByUsername(username);
      if (user != null && user.password == password) {
        return {
          'user': {
            'id': user.id,
            'username': user.username,
            'name': user.name,
          },
          'message': 'Çevrimdışı modda giriş yapıldı.',
        };
      } else {
        throw Exception('İnternet bağlantısı yok ve yerel kayıt bulunamadı.');
      }
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    // Kayıt işlemi genellikle internet gerektirir
    try {
      final result = await _apiService.register(username, email, password);
      
      // Başarılı olursa yerel veritabanına da ekle
      final userModel = UserModel(
        name: username,
        surname: '',
        username: username,
        password: password,
        createdAt: DateTime.now(),
      );
      await _dbHelper.insertUser(userModel);
      
      return result;
    } catch (e) {
      throw Exception('Kayıt olmak için internet bağlantısı gereklidir: $e');
    }
  }

  // --- TODO İŞLEMLERİ (Offline-First Mantığı) ---

  // 1. Verileri Getir (Okuma)
  Future<List<TodoModel>> getTodos(int userId) async {
    // ADIM A: Kullanıcıya hemen yerel veriyi göster (Hız için)
    List<TodoModel> localTodos = await _dbHelper.getTodosByUserId(userId);

    // ADIM B: Arka planda senkronizasyonu başlat (UI'ı bekletmemek için await kullanmıyoruz veya hata yakalıyoruz)
    _syncTodos(userId).catchError((e) {
      print("Arka plan senkronizasyon hatası: $e");
    });

    return localTodos;
  }

  // 2. Yeni Görev Ekle (Yazma)
  Future<void> createTodo(TodoModel todo) async {
    // A. Önce Yerele Kaydet (isSynced = 0 olarak başlar)
    // Böylece internet olmasa bile görev listede görünür.
    final unsyncedTodo = todo.copyWith(isSynced: 0);
    await _dbHelper.insertTodo(unsyncedTodo);

    try {
      // B. API'ye göndermeyi dene
      await _apiService.createTodo(unsyncedTodo.toMap());

      // C. Başarılı olursa yereldeki durumu güncelle (isSynced = 1)
      await _dbHelper.updateTodoSyncStatus(todo.id, 1);
      print("Görev API'ye başarıyla gönderildi: ${todo.title}");
    } catch (e) {
      print("Görev yerel kaydedildi ama API'ye gidilemedi (Sonra senkronize edilecek): $e");
      // Hata fırlatmıyoruz, çünkü işlem kullanıcı için "başarılı" sayılır.
    }
  }

  // 3. Görev Güncelleme
  Future<void> updateTodo(TodoModel todo) async {
    // A. Yerele Kaydet (Güncellendiği için isSynced = 0 yapıyoruz)
    final unsyncedTodo = todo.copyWith(isSynced: 0);
    await _dbHelper.updateTodo(unsyncedTodo);

    try {
      // B. API'ye gönder
      await _apiService.updateTodo(todo.id, unsyncedTodo.toMap());

      // C. Başarılı ise isSynced = 1
      await _dbHelper.updateTodoSyncStatus(todo.id, 1);
    } catch (e) {
      print("Güncelleme yerel yapıldı, API hatası: $e");
    }
  }

  // 4. Görev Silme
  Future<void> deleteTodo(String id) async {
    try {
      // A. API'den silmeyi dene
      await _apiService.deleteTodo(id);
    } catch (e) {
      print("API'den silinemedi (Offline olabilir): $e");
      // Not: Gerçek bir sistemde silinecekleri de bir kuyrukta tutmak gerekir
      // ama şimdilik sadece yerelden siliyoruz.
    }
    // B. Yerelden sil
    await _dbHelper.deleteTodo(id);
  }

  // --- SENKRONİZASYON MOTORU ---
  
  Future<void> _syncTodos(int userId) async {
    print("Senkronizasyon başladı...");
    
    // 1. PUSH: Gönderilmemiş yerel verileri sunucuya at
    final unsyncedTodos = await _dbHelper.getUnsyncedTodos(userId);
    if (unsyncedTodos.isNotEmpty) {
      print("${unsyncedTodos.length} adet gönderilmemiş veri bulundu, sunucuya gönderiliyor...");
      for (var todo in unsyncedTodos) {
        try {
          // API'de create veya update ayrımı yapmak gerekebilir.
          // Şimdilik create varsayıyoruz veya API yapısına göre düzenliyoruz.
          // Eğer API akıllıysa (ID varsa update, yoksa create) createTodo kullanabiliriz.
          await _apiService.createTodo(todo.toMap());
          
          // Gönderim başarılı, yerelde işaretle
          await _dbHelper.updateTodoSyncStatus(todo.id, 1);
        } catch (e) {
          print("Veri gönderilemedi (${todo.title}): $e");
        }
      }
    }

    // 2. PULL: Sunucudan güncel verileri çek
    try {
      final remoteDataList = await _apiService.getTodos();
      
      for (var data in remoteDataList) {
        // API'den gelen veriyi modele çevir
        // Not: API verisi her zaman "synced" (1) kabul edilir.
        final remoteTodo = TodoModel(
          id: data['id']?.toString() ?? '',
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          isDone: data['isCompleted'] ?? data['isDone'] ?? false,
          dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
          createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
          userId: data['userId'] ?? userId,
          isSynced: 1, 
        );

        // Veritabanına kaydet (Varsa üzerine yazar - ConflictAlgorithm.replace sayesinde)
        await _dbHelper.insertTodo(remoteTodo);
      }
      print("Sunucudan veriler çekildi ve yerel DB güncellendi.");
      
    } catch (e) {
      print("Sunucudan veri çekilemedi: $e");
    }
  }

  // Profil işlemleri
  Future<UserModel?> getUserProfile(int userId) async {
    try {
      // Önce API
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
      // Olmazsa Yerel
      return await _dbHelper.getUserById(userId);
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    // Not: Çıkış yapınca yerel veriyi silmek isteyebilirsin,
    // ama "Beni Hatırla" özelliği için silmiyoruz.
  }
}