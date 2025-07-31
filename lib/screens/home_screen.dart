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

  List<TodoModel> get _sortedTodos {
    final List<TodoModel> sorted = [..._todos];
    sorted.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sorted;
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
        ),
        backgroundColor: const Color(0xFFFFF9C4),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _todos.isEmpty
              ? const Center(child: Text("Henüz hiç görev yok."))
              : ListView.builder(
                  itemCount: _sortedTodos.length,
                  itemBuilder: (context, index) {
                    final todo = _sortedTodos[index];
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
                                  value: todo.isDone,
                                  onChanged: (val) {
                                    setState(() {
                                      _todos[_todos.indexWhere((t) => t.id == todo.id)] = TodoModel(
                                        id: todo.id,
                                        title: todo.title,
                                        description: todo.description,
                                        createdAt: todo.createdAt,
                                        dueDate: todo.dueDate,
                                        isDone: val ?? false,
                                      );
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: todo.isDone
                                              ? Colors.grey
                                              : Colors.blueGrey,
                                          decoration: todo.isDone
                                              ? TextDecoration.lineThrough
                                              : null,
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
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddTodoScreen(
                                          onAdd: _addTodo,
                                          onUpdate: _updateTodo,
                                          editingTodo: todo,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: "Sil",
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(todo.id),
                                ),
                              ],
                            ),
                            if (isExpanded && todo.description != null) ...[
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
                  final doneTodos = _todos.where((todo) => todo.isDone).toList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoneTasksScreen(doneTodos: doneTodos),
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
                      builder: (_) => AddTodoScreen(onAdd: _addTodo),
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
