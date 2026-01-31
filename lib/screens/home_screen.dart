// import 'package:flutter/material.dart';
// import 'package:todo_app_gelismis/model/todo_model.dart';
// import 'package:todo_app_gelismis/screens/add_todo_screen.dart';
// import 'package:todo_app_gelismis/screens/done_tasks_screen.dart';
// import 'package:todo_app_gelismis/screens/profile_screen.dart';
// import 'package:todo_app_gelismis/database/database_helper.dart';
// import 'package:todo_app_gelismis/services/hybrid_service.dart';

// class HomeScreen extends StatefulWidget {
//   final int userId;

//   const HomeScreen({
//     super.key,
//     required this.userId,
//   });

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final List<TodoModel> _todos = [];
//   final Set<String> _expandedIds = {};
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadTodos();
//   }

//   Future<void> _loadTodos() async {
//     try {
//       final hybridService = HybridService();
//       final todos = await hybridService.getTodos(widget.userId);
      
//       setState(() {
//         _todos.clear();
//         _todos.addAll(todos);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Görevler yüklenirken hata oluştu: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Diğer sayfalardan döndüğümüzde listeyi yenilemek için
//   void _refreshTodos() {
//     _loadTodos();
//   }

//   Future<void> _addTodo(TodoModel todo) async {
//     try {
//       final hybridService = HybridService();
//       await hybridService.createTodo(todo);
//       await _loadTodos(); // Listeyi yenile
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Görev eklenirken hata oluştu: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _updateTodo(TodoModel updatedTodo) async {
//     try {
//       final hybridService = HybridService();
//       await hybridService.updateTodo(updatedTodo);
//       await _loadTodos(); // Listeyi yenile
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Görev güncellenirken hata oluştu: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _deleteTodo(String id) async {
//     try {
//       final hybridService = HybridService();
//       await hybridService.deleteTodo(id);
//       await _loadTodos(); // Listeyi yenile
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Görev silinirken hata oluştu: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _toggleExpand(String id) {
//     setState(() {
//       if (_expandedIds.contains(id)) {
//         _expandedIds.remove(id);
//       } else {
//         _expandedIds.add(id);
//       }
//     });
//   }

//   void _confirmDelete(String id) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Görevi Sil"),
//         content: const Text("Bu görevi silmek istediğinize emin misiniz?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text("Vazgeç"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               _deleteTodo(id);
//               Navigator.of(ctx).pop();
//             },
//             child: const Text("Sil"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _markAsDone(BuildContext context, TodoModel todo) async {
//     final shouldMarkDone = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Görev Tamamlandı mı?"),
//         content: const Text("Bu görevi tamamladınız mı?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text("Hayır"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text("Evet"),
//           ),
//         ],
//       ),
//     );

//     if (shouldMarkDone == true) {
//       try {
//         final dbHelper = DatabaseHelper();
//         final updatedTodo = todo.copyWith(isDone: true);
//         await dbHelper.updateTodo(updatedTodo);
//         await _loadTodos(); // Listeyi yenile
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Görev güncellenirken hata oluştu: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _uncheckDoneTask(TodoModel task) async {
//     try {
//       final dbHelper = DatabaseHelper();
//       final updatedTodo = task.copyWith(isDone: false);
//       await dbHelper.updateTodo(updatedTodo);
//       await _loadTodos(); // Listeyi yenile
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Görev güncellenirken hata oluştu: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   List<TodoModel> get _activeTodos {
//     final activeTodos = _todos.where((todo) => !todo.isDone).toList();
//     // Bitiş tarihine göre artan sıralama (en erken önce)
//     activeTodos.sort((a, b) {
//       if (a.dueDate == null && b.dueDate == null) return 0;
//       if (a.dueDate == null) return 1; // null değerler en sona
//       if (b.dueDate == null) return -1;
//       return a.dueDate!.compareTo(b.dueDate!);
//     });
//     return activeTodos;
//   }

//   List<TodoModel> get _doneTodos {
//     final doneTodos = _todos.where((todo) => todo.isDone).toList();
//     // Bitiş tarihine göre artan sıralama (en erken önce)
//     doneTodos.sort((a, b) {
//       if (a.dueDate == null && b.dueDate == null) return 0;
//       if (a.dueDate == null) return 1; // null değerler en sona
//       if (b.dueDate == null) return -1;
//       return a.dueDate!.compareTo(b.dueDate!);
//     });
//     return doneTodos;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;
//     final isTablet = width > 600;
//     final isLandscape = width > height;

//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFFFF176),
//           title: Text(
//             'Görev Listem',
//             style: TextStyle(
//               color: Colors.blueGrey,
//               fontWeight: FontWeight.bold,
//               fontSize: isTablet ? 24 : 20,
//             ),
//           ),
//           centerTitle: true,
//           elevation: 2,
//           actions: [
//             IconButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ProfileScreen(
//                       userId: widget.userId,
//                     ),
//                   ),
//                 );
//               },
//               icon: Icon(
//                 Icons.person,
//                 color: Colors.blueGrey,
//                 size: isTablet ? 32 : 28,
//               ),
//               tooltip: 'Profil',
//             ),
//             SizedBox(width: isTablet ? 15 : 10),
//           ],
//         ),
//         backgroundColor: const Color(0xFFFFF9C4),
//         body: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.blueGrey,
//                 ),
//               )
//             : Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isTablet ? width * 0.1 : 20,
//                 ),
//                 child: _activeTodos.isEmpty
//                     ? Center(
//                         child: Text(
//                           "Henüz hiç görev yok.",
//                           style: TextStyle(
//                             fontSize: isTablet ? 20 : 16,
//                             color: Colors.blueGrey,
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: _activeTodos.length,
//                         itemBuilder: (context, index) {
//                           final todo = _activeTodos[index];
//                           final isExpanded = _expandedIds.contains(todo.id);

//                           return GestureDetector(
//                             onTap: () => _toggleExpand(todo.id),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               margin: EdgeInsets.symmetric(
//                                 vertical: isTablet ? 12 : 8,
//                               ),
//                               padding: EdgeInsets.all(isTablet ? 20 : 16),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
//                                 boxShadow: const [
//                                   BoxShadow(
//                                     color: Colors.black26,
//                                     blurRadius: 6,
//                                     offset: Offset(0, 3),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Transform.scale(
//                                         scale: isTablet ? 1.2 : 1.0,
//                                         child: Checkbox(
//                                           value: false,
//                                           onChanged: (_) => _markAsDone(context, todo),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               todo.title,
//                                               style: TextStyle(
//                                                 fontSize: isTablet ? 20 : 17,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.blueGrey,
//                                               ),
//                                             ),
//                                             SizedBox(height: isTablet ? 6 : 4),
//                                             Text(
//                                               'Tarih: ${todo.dueDate != null ? "${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}" : "Belirtilmemiş"}',
//                                               style: TextStyle(
//                                                 fontSize: isTablet ? 15 : 13,
//                                                 color: Colors.black54,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       IconButton(
//                                         tooltip: "Düzenle",
//                                         icon: Icon(
//                                           Icons.edit,
//                                           color: Colors.blueGrey,
//                                           size: isTablet ? 28 : 24,
//                                         ),
//                                         onPressed: () async {
//                                           await Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (_) => AddTodoScreen(
//                                                 onAdd: _addTodo,
//                                                 onUpdate: _updateTodo,
//                                                 editingTodo: todo,
//                                                 userId: widget.userId,
//                                               ),
//                                             ),
//                                           );
//                                           // Sayfa döndüğünde listeyi yenile
//                                           _refreshTodos();
//                                         },
//                                       ),
//                                       IconButton(
//                                         tooltip: "Sil",
//                                         icon: Icon(
//                                           Icons.delete,
//                                           color: Colors.red,
//                                           size: isTablet ? 28 : 24,
//                                         ),
//                                         onPressed: () => _confirmDelete(todo.id),
//                                       ),
//                                     ],
//                                   ),
//                                   if (isExpanded && todo.description != null && todo.description!.isNotEmpty) ...[
//                                     Divider(height: isTablet ? 20 : 16),
//                                     Text(
//                                       todo.description!,
//                                       style: TextStyle(
//                                         fontSize: isTablet ? 17 : 15,
//                                       ),
//                                     ),
//                                   ]
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//         bottomNavigationBar: Padding(
//           padding: EdgeInsets.symmetric(
//             vertical: isTablet ? 16 : 12,
//             horizontal: isTablet ? width * 0.1 : 0,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               FloatingActionButton.extended(
//                 heroTag: 'doneTasksBtn',
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.blueGrey,
//                 onPressed: () async {
//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => DoneTasksScreen(
//                         userId: widget.userId,
//                         onTodoUpdated: _refreshTodos,
//                       ),
//                     ),
//                   );
//                   // Sayfa döndüğünde listeyi yenile
//                   _refreshTodos();
//                 },
//                 label: Text(
//                   "Tamamlanan Görevler",
//                   style: TextStyle(
//                     fontSize: isTablet ? 16 : 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 icon: Icon(
//                   Icons.check_circle_outline,
//                   size: isTablet ? 24 : 20,
//                 ),
//               ),
//               FloatingActionButton(
//                 heroTag: 'addTaskBtn',
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.blueGrey,
//                 tooltip: "Yeni Görev Ekle",
//                 onPressed: () async {
//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => AddTodoScreen(
//                         onAdd: _addTodo,
//                         userId: widget.userId,
//                       ),
//                     ),
//                   );
//                   // Sayfa döndüğünde listeyi yenile
//                   _refreshTodos();
//                 },
//                 child: Icon(
//                   Icons.add,
//                   size: isTablet ? 28 : 24,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:todo_app_gelismis/screens/add_todo_screen.dart';
import 'package:todo_app_gelismis/screens/done_tasks_screen.dart';
import 'package:todo_app_gelismis/screens/profile_screen.dart';
import 'package:todo_app_gelismis/database/database_helper.dart';
import 'package:todo_app_gelismis/services/hybrid_service.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({
    super.key,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TodoModel> _todos = [];
  final Set<String> _expandedIds = {};
  bool _isLoading = true;
  final HybridService _hybridService = HybridService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  // Akıllı Yükleme Sistemi
  Future<void> _initialLoad() async {
    await _loadTodos();
    
    // Trick: Senkronizasyonun bitmesi için biraz bekleyip sessizce tekrar çekiyoruz.
    // Böylece sunucudan yeni veri geldiyse ekran otomatik güncellenir.
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _loadTodos(onlyLocal: true); // Sadece DB'den çek, tekrar sync tetikleme
    }
  }

  Future<void> _loadTodos({bool onlyLocal = false}) async {
    try {
      List<TodoModel> todos;
      
      if (onlyLocal) {
        // Sadece veritabanından güncel hali oku (Sync tetikleme)
        todos = await _dbHelper.getTodosByUserId(widget.userId);
      } else {
        // Hem oku hem de arkada sync başlat
        todos = await _hybridService.getTodos(widget.userId);
      }
      
      if (mounted) {
        setState(() {
          _todos.clear();
          _todos.addAll(todos);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Sessiz hata yönetimi: Kullanıcıya her zaman hata göstermeye gerek yok
        print("Veri yükleme hatası: $e"); 
      }
    }
  }

  Future<void> _addTodo(TodoModel todo) async {
    try {
      await _hybridService.createTodo(todo);
      await _loadTodos(onlyLocal: true); // Ekranı hemen güncelle
    } catch (e) {
      _showError('Görev eklenirken hata: $e');
    }
  }

  Future<void> _updateTodo(TodoModel updatedTodo) async {
    try {
      await _hybridService.updateTodo(updatedTodo);
      await _loadTodos(onlyLocal: true);
    } catch (e) {
      _showError('Güncelleme hatası: $e');
    }
  }

  Future<void> _deleteTodo(String id) async {
    try {
      await _hybridService.deleteTodo(id);
      await _loadTodos(onlyLocal: true);
    } catch (e) {
      _showError('Silme hatası: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Görevi Sil"),
        content: const Text("Bu görevi silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop(); // Önce dialogu kapat
              _deleteTodo(id); // Sonra sil
            },
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _markAsDone(BuildContext context, TodoModel todo) async {
    // Checkbox'a basınca direkt tamamlandı sayabiliriz veya sorabiliriz.
    // UX açısından direkt işaretlemek daha akıcıdır, ama senin kodunda dialog vardı, koruyorum.
    final shouldMarkDone = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tebrikler!"),
        content: const Text("Bu görevi tamamladınız mı?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hayır"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Evet"),
          ),
        ],
      ),
    );

    if (shouldMarkDone == true) {
      final updatedTodo = todo.copyWith(isDone: true);
      await _updateTodo(updatedTodo);
    }
  }

  List<TodoModel> get _activeTodos {
    final activeTodos = _todos.where((todo) => !todo.isDone).toList();
    activeTodos.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return activeTodos;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isTablet = width > 600;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF176),
          title: Text(
            'Görev Listem',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
            ),
          ),
          centerTitle: true,
          elevation: 2,
          actions: [
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: widget.userId),
                  ),
                );
                // Profil dönüşü belki kullanıcı değişmiştir diye yenile
                _loadTodos(onlyLocal: true);
              },
              icon: Icon(Icons.person, color: Colors.blueGrey, size: isTablet ? 32 : 28),
            ),
            const SizedBox(width: 10),
          ],
        ),
        backgroundColor: const Color(0xFFFFF9C4),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueGrey))
            : RefreshIndicator(
                // Aşağı çekince senkronizasyonu tetikler
                onRefresh: () async {
                  await _loadTodos(onlyLocal: false);
                },
                color: Colors.blueGrey,
                child: _activeTodos.isEmpty
                    ? ListView( // Scroll yapılabilmesi için ListView kullandım (Boş olsa bile refresh çalışsın)
                        children: [
                          SizedBox(height: size.height * 0.3),
                          Center(
                            child: Text(
                              "Henüz hiç görev yok.\nEklemek için + butonuna bas!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 16,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? width * 0.1 : 20,
                          vertical: 20,
                        ),
                        itemCount: _activeTodos.length,
                        itemBuilder: (context, index) {
                          final todo = _activeTodos[index];
                          final isExpanded = _expandedIds.contains(todo.id);

                          return GestureDetector(
                            onTap: () => _toggleExpand(todo.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                border: todo.isSynced == 0 
                                  ? Border.all(color: Colors.orange.withOpacity(0.5), width: 1) // Senkronize değilse turuncu çerçeve
                                  : null,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 1.1,
                                        child: Checkbox(
                                          activeColor: Colors.blueGrey,
                                          value: false,
                                          onChanged: (_) => _markAsDone(context, todo),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              todo.title,
                                              style: TextStyle(
                                                fontSize: isTablet ? 20 : 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey.shade800,
                                              ),
                                            ),
                                            if (todo.dueDate != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '📅 ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                                                style: TextStyle(
                                                  fontSize: isTablet ? 14 : 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      
                                      // Senkronizasyon durumu ikonu (Opsiyonel Güzellik)
                                      if (todo.isSynced == 0)
                                        const Tooltip(
                                          message: "Gönderilmeyi bekliyor",
                                          child: Icon(Icons.cloud_upload_outlined, color: Colors.orange, size: 20),
                                        ),
                                      
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddTodoScreen(
                                                onAdd: _addTodo,
                                                onUpdate: _updateTodo,
                                                editingTodo: todo,
                                                userId: widget.userId,
                                              ),
                                            ),
                                          );
                                          _loadTodos(onlyLocal: true);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        onPressed: () => _confirmDelete(todo.id),
                                      ),
                                    ],
                                  ),
                                  if (isExpanded && (todo.description?.isNotEmpty ?? false)) ...[
                                    const Divider(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                                      child: Text(
                                        todo.description!,
                                        style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.black87),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 12,
            horizontal: isTablet ? width * 0.1 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton.extended(
                heroTag: 'doneTasksBtn',
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueGrey,
                elevation: 3,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoneTasksScreen(
                        userId: widget.userId,
                        onTodoUpdated: () => _loadTodos(onlyLocal: true),
                      ),
                    ),
                  );
                  _loadTodos(onlyLocal: true);
                },
                label: const Text("Tamamlananlar"),
                icon: const Icon(Icons.check_circle_outline),
              ),
              FloatingActionButton(
                heroTag: 'addTaskBtn',
                backgroundColor: Colors.blueGrey, // Ana aksiyon butonu daha belirgin olsun
                foregroundColor: Colors.white,
                elevation: 4,
                tooltip: "Yeni Görev Ekle",
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTodoScreen(
                        onAdd: _addTodo,
                        userId: widget.userId,
                      ),
                    ),
                  );
                  // Dönüşte listeyi güncelle
                  _loadTodos(onlyLocal: true);
                },
                child: const Icon(Icons.add, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}