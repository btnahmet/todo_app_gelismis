import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:todo_app_gelismis/screens/add_todo_screen.dart';
import 'package:todo_app_gelismis/screens/done_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TodoModel> _todos = [];
  final Set<String> _expandedIds = {};
  int _currentUserId = 1; // Geçici olarak 1 kullanıyoruz, daha sonra login'den alacağız

  void _addTodo(TodoModel todo) {
    setState(() {
      _todos.add(todo);
    });
  }

  void _updateTodo(TodoModel updatedTodo) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
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
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = todo.copyWith(isDone: true);
        }
      });
    }
  }

  void _uncheckDoneTask(TodoModel task) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _todos[index] = task.copyWith(isDone: false);
      }
    });
  }

  List<TodoModel> get _activeTodos =>
      _todos.where((todo) => !todo.isDone).toList();

  List<TodoModel> get _doneTodos =>
      _todos.where((todo) => todo.isDone).toList();

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
        ),
        backgroundColor: const Color(0xFFFFF9C4),
        body: Padding(
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddTodoScreen(
                                          onAdd: _addTodo,
                                          onUpdate: _updateTodo,
                                          editingTodo: todo,
                                          userId: _currentUserId,
                                        ),
                                      ),
                                    );
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DoneTasksScreen(doneTodos: _doneTodos, onUncheck: _uncheckDoneTask),
                    ),
                  );
                },
                label: const Text("Tamamlanan Görevler"),
                icon: const Icon(Icons.check_circle_outline),
              ),
              FloatingActionButton(
                heroTag: 'addTaskBtn',
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueGrey,
                tooltip: "Yeni Görev Ekle",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTodoScreen(
                        onAdd: _addTodo,
                        userId: _currentUserId,
                      ),
                    ),
                  );
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
