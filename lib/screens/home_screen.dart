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

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final hybridService = HybridService();
      final todos = await hybridService.getTodos(widget.userId);
      
      setState(() {
        _todos.clear();
        _todos.addAll(todos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görevler yüklenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Diğer sayfalardan döndüğümüzde listeyi yenilemek için
  void _refreshTodos() {
    _loadTodos();
  }

  Future<void> _addTodo(TodoModel todo) async {
    try {
      final hybridService = HybridService();
      await hybridService.createTodo(todo);
      await _loadTodos(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev eklenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateTodo(TodoModel updatedTodo) async {
    try {
      final hybridService = HybridService();
      await hybridService.updateTodo(updatedTodo);
      await _loadTodos(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev güncellenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTodo(String id) async {
    try {
      final hybridService = HybridService();
      await hybridService.deleteTodo(id);
      await _loadTodos(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev silinirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            onPressed: () {
              _deleteTodo(id);
              Navigator.of(ctx).pop();
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _markAsDone(BuildContext context, TodoModel todo) async {
    final shouldMarkDone = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Görev Tamamlandı mı?"),
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
      try {
        final dbHelper = DatabaseHelper();
        final updatedTodo = todo.copyWith(isDone: true);
        await dbHelper.updateTodo(updatedTodo);
        await _loadTodos(); // Listeyi yenile
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görev güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uncheckDoneTask(TodoModel task) async {
    try {
      final dbHelper = DatabaseHelper();
      final updatedTodo = task.copyWith(isDone: false);
      await dbHelper.updateTodo(updatedTodo);
      await _loadTodos(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görev güncellenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<TodoModel> get _activeTodos {
    final activeTodos = _todos.where((todo) => !todo.isDone).toList();
    // Bitiş tarihine göre artan sıralama (en erken önce)
    activeTodos.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1; // null değerler en sona
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return activeTodos;
  }

  List<TodoModel> get _doneTodos {
    final doneTodos = _todos.where((todo) => todo.isDone).toList();
    // Bitiş tarihine göre artan sıralama (en erken önce)
    doneTodos.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1; // null değerler en sona
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return doneTodos;
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.person,
                color: Colors.blueGrey,
                size: isTablet ? 32 : 28,
              ),
              tooltip: 'Profil',
            ),
            SizedBox(width: isTablet ? 15 : 10),
          ],
        ),
        backgroundColor: const Color(0xFFFFF9C4),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueGrey,
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? width * 0.1 : 20,
                ),
                child: _activeTodos.isEmpty
                    ? Center(
                        child: Text(
                          "Henüz hiç görev yok.",
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _activeTodos.length,
                        itemBuilder: (context, index) {
                          final todo = _activeTodos[index];
                          final isExpanded = _expandedIds.contains(todo.id);

                          return GestureDetector(
                            onTap: () => _toggleExpand(todo.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(
                                vertical: isTablet ? 12 : 8,
                              ),
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: isTablet ? 1.2 : 1.0,
                                        child: Checkbox(
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
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            SizedBox(height: isTablet ? 6 : 4),
                                            Text(
                                              'Tarih: ${todo.dueDate != null ? "${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}" : "Belirtilmemiş"}',
                                              style: TextStyle(
                                                fontSize: isTablet ? 15 : 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: "Düzenle",
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blueGrey,
                                          size: isTablet ? 28 : 24,
                                        ),
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
                                          // Sayfa döndüğünde listeyi yenile
                                          _refreshTodos();
                                        },
                                      ),
                                      IconButton(
                                        tooltip: "Sil",
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: isTablet ? 28 : 24,
                                        ),
                                        onPressed: () => _confirmDelete(todo.id),
                                      ),
                                    ],
                                  ),
                                  if (isExpanded && todo.description != null && todo.description!.isNotEmpty) ...[
                                    Divider(height: isTablet ? 20 : 16),
                                    Text(
                                      todo.description!,
                                      style: TextStyle(
                                        fontSize: isTablet ? 17 : 15,
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
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoneTasksScreen(
                        userId: widget.userId,
                        onTodoUpdated: _refreshTodos,
                      ),
                    ),
                  );
                  // Sayfa döndüğünde listeyi yenile
                  _refreshTodos();
                },
                label: Text(
                  "Tamamlanan Görevler",
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: Icon(
                  Icons.check_circle_outline,
                  size: isTablet ? 24 : 20,
                ),
              ),
              FloatingActionButton(
                heroTag: 'addTaskBtn',
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueGrey,
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
                  // Sayfa döndüğünde listeyi yenile
                  _refreshTodos();
                },
                child: Icon(
                  Icons.add,
                  size: isTablet ? 28 : 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
