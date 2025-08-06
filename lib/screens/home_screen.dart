import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:todo_app_gelismis/screens/add_todo_screen.dart';
import 'package:todo_app_gelismis/screens/done_tasks_screen.dart';
import 'package:todo_app_gelismis/screens/profile_screen.dart';
import 'package:todo_app_gelismis/database/database_helper.dart';

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
      final dbHelper = DatabaseHelper();
      final todos = await dbHelper.getTodosByUserId(widget.userId);
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
      final dbHelper = DatabaseHelper();
      await dbHelper.insertTodo(todo);
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
      final dbHelper = DatabaseHelper();
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

  Future<void> _deleteTodo(String id) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteTodo(id);
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF176),
          title: const Text(
            'Görev Listem',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
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
              icon: const Icon(
                Icons.person,
                color: Colors.blueGrey,
                size: 28,
              ),
              tooltip: 'Profil',
            ),
            const SizedBox(width: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _activeTodos.isEmpty
                    ? const Center(child: Text("Henüz hiç görev yok."))
                    : ListView.builder(
                  itemCount: _activeTodos.length,
                  itemBuilder: (context, index) {
                    final todo = _activeTodos[index];
                    final isExpanded = _expandedIds.contains(todo.id);

                    return GestureDetector(
                      onTap: () => _toggleExpand(todo.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                                Checkbox(
                                  value: false,
                                  onChanged: (_) => _markAsDone(context, todo),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                                                             Text(
                                         'Tarih: ${todo.dueDate != null ? "${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}" : "Belirtilmemiş"}',
                                         style: const TextStyle(
                                             fontSize: 13,
                                             color: Colors.black54),
                                       ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: "Düzenle",
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blueGrey),
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
                                  icon:
                                      const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(todo.id),
                                ),
                              ],
                            ),
                            if (isExpanded && todo.description != null && todo.description!.isNotEmpty) ...[
                              const Divider(height: 16),
                              Text(
                                todo.description!,
                                style: const TextStyle(fontSize: 15),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                label: const Text("Tamamlanan Görevler"),
                icon: const Icon(Icons.check_circle_outline),
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
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
