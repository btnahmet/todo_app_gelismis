import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- AUTH İŞLEMLERİ ---

  // Giriş Yap
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Firebase email ile çalışır, username ile değil.
      // Bu yüzden username'i sahte bir email formatına çeviriyoruz.
      final email = "$username@todoapp.com";

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      return {
        'user': {
          'id': _generateIntId(user?.uid), // Int ID uyumu için hash
          'username': username,
          'name': user?.displayName ?? username,
        },
        'message': 'Giriş başarılı',
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseAuthErrorTranslate(e.code));
    }
  }

  // Kayıt Ol
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      // Eğer email parametresi geçerli değilse username'den türet
      final registerEmail =
          email.contains('@') ? email : "$username@todoapp.com";

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: registerEmail,
        password: password,
      );

      // Kullanıcı adını Firebase profiline kaydet
      await userCredential.user?.updateDisplayName(username);

      return {
        'message': 'Kayıt başarılı',
        'user': {
          'id': _generateIntId(userCredential.user?.uid),
          'username': username,
          'name': username,
        },
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_firebaseAuthErrorTranslate(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // --- TODO İŞLEMLERİ (FIRESTORE) ---

  // Verileri Getir
  Future<List<Map<String, dynamic>>> getTodos() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu kapalı");

    // Sadece bu kullanıcıya ait verileri çek
    final snapshot = await _firestore
        .collection('todos')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'],
        'description': data['description'],
        'isDone': data['isDone'] ?? false,
        'dueDate': data['dueDate'],
        'createdAt': data['createdAt'],
        // Hybrid yapıda userId int beklendiği için dönüştürüyoruz
        'userId': _generateIntId(user.uid),
      };
    }).toList();
  }

  // Veri Ekle
  Future<Map<String, dynamic>> createTodo(Map<String, dynamic> todoData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu kapalı");

    final dataToSave = Map<String, dynamic>.from(todoData);
    dataToSave['userId'] = user.uid; // Firestore'a String UID olarak kaydet

    // ID'yi doküman ID'si olarak kullan
    await _firestore.collection('todos').doc(todoData['id']).set(dataToSave);

    return dataToSave;
  }

  // Veri Güncelle
  Future<Map<String, dynamic>> updateTodo(
      String id, Map<String, dynamic> todoData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu kapalı");

    final dataToSave = Map<String, dynamic>.from(todoData);
    dataToSave['userId'] = user.uid;

    await _firestore.collection('todos').doc(id).update(dataToSave);

    return dataToSave;
  }

  // Veri Sil
  Future<void> deleteTodo(String id) async {
    await _firestore.collection('todos').doc(id).delete();
  }

  // --- PROFİL İŞLEMLERİ ---

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı bulunamadı");

    return {
      'id': _generateIntId(user.uid),
      'username': user.email?.split('@')[0] ?? 'User',
      'name': user.displayName ?? 'Kullanıcı',
      'surname': '', // Firebase'de soyad standart değil
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // --- YARDIMCI METODLAR ---

  // String UID'yi Int ID'ye çevir (SQLite uyumu için)
  int _generateIntId(String? uid) {
    if (uid == null) return 0;
    return uid.hashCode;
  }

  // Hata mesajlarını Türkçeleştir
  String _firebaseAuthErrorTranslate(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu kullanıcı adı zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz kullanıcı adı formatı.';
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      default:
        return 'Bir hata oluştu: $code';
    }
  }
}
