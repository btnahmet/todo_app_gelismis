import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_app_gelismis/model/user_model.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(),
        'todo_app_v2.db'); // v2 yaparak db adını değiştirdim, silip yüklemeye gerek kalmasın
    return await openDatabase(
      path,
      version: 2, // Versiyonu arttırdım
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        surname TEXT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isDone INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        userId INTEGER NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0, -- 0: Gönderilmedi, 1: Gönderildi
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // Eski kullanıcılar için veritabanı yükseltme
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Eğer tablo zaten varsa isSynced kolonunu ekle
      try {
        await db.execute(
            'ALTER TABLE todos ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 0');
      } catch (e) {
        // Hata olursa (kolon zaten varsa) yoksay
        print("Upgrade hatası: $e");
      }
    }
  }

  // --- User İşlemleri (Değişiklik yok) ---
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  // --- Todo İşlemleri ---

  Future<int> insertTodo(TodoModel todo) async {
    final db = await database;
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm
          .replace, // ID çakışırsa üzerine yaz (Sync için önemli)
    );
  }

  Future<List<TodoModel>> getTodosByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => TodoModel.fromMap(maps[i]));
  }

  // YENİ: Sadece senkronize edilmemiş (isSynced = 0) görevleri getir
  Future<List<TodoModel>> getUnsyncedTodos(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'userId = ? AND isSynced = 0',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => TodoModel.fromMap(maps[i]));
  }

  Future<int> updateTodo(TodoModel todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // YENİ: ID'ye göre senkronizasyon durumunu güncelle
  Future<void> updateTodoSyncStatus(String id, int isSynced) async {
    final db = await database;
    await db.update(
      'todos',
      {'isSynced': isSynced},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTodo(String id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // YENİ: Silinmiş olarak işaretle (Sunucuya "bunu sil" demek için bu kaydı tutabiliriz ama şimdilik direkt siliyoruz)

  Future<List<TodoModel>> getActiveTodosByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'userId = ? AND isDone = 0',
      whereArgs: [userId],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => TodoModel.fromMap(maps[i]));
  }

  Future<List<TodoModel>> getDoneTodosByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'userId = ? AND isDone = 1',
      whereArgs: [userId],
      orderBy: 'dueDate ASC',
    );
    return List.generate(maps.length, (i) => TodoModel.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
