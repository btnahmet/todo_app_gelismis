import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:todo_app_gelismis/database/database_helper.dart';

class DoneTasksScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onTodoUpdated;

  const DoneTasksScreen({
    super.key,
    required this.userId,
    this.onTodoUpdated,
  });

  @override
  State<DoneTasksScreen> createState() => _DoneTasksScreenState();
}

class _DoneTasksScreenState extends State<DoneTasksScreen> {
  final Set<String> _expandedIds = {};
  List<TodoModel> _doneTodos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoneTodos();
  }

  Future<void> _loadDoneTodos() async {
    try {
      final dbHelper = DatabaseHelper();
      final doneTodos = await dbHelper.getDoneTodosByUserId(widget.userId);
      // Bitiş tarihine göre artan sıralama (en erken önce)
      doneTodos.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1; // null değerler en sona
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      setState(() {
        _doneTodos = doneTodos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tamamlanan görevler yüklenirken hata oluştu: $e'),
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

  void _confirmUncheck(TodoModel todo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Görevi Geri Al"),
        content: const Text("Bu görevi tamamlanmamış olarak işaretlemek istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final dbHelper = DatabaseHelper();
                final updatedTodo = todo.copyWith(isDone: false);
                await dbHelper.updateTodo(updatedTodo);
                await _loadDoneTodos(); // Listeyi yenile
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Ana ekrana döndür
                // Ana sayfayı yenilemek için callback çağır
                widget.onTodoUpdated?.call();
              } catch (e) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Görev güncellenirken hata oluştu: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Evet"),
          ),
        ],
      ),
    );
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
            onPressed: () async {
              try {
                final dbHelper = DatabaseHelper();
                await dbHelper.deleteTodo(id);
                await _loadDoneTodos(); // Listeyi yenile
                Navigator.of(ctx).pop();
                // Ana sayfayı yenilemek için callback çağır
                widget.onTodoUpdated?.call();
              } catch (e) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Görev silinirken hata oluştu: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tamamlanan Görevler"),
          backgroundColor: const Color(0xFFFFF176),
          foregroundColor: Colors.black,
        ),
        backgroundColor: const Color(0xFFFFF9C4),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueGrey,
                ),
              )
            : _doneTodos.isEmpty
                ? const Center(child: Text("Henüz tamamlanmış görev yok."))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _doneTodos.length,
                    itemBuilder: (context, index) {
                      final todo = _doneTodos[index];
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
                                     value: true,
                                     onChanged: (_) => _confirmUncheck(todo),
                                   ),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           todo.title,
                                           style: const TextStyle(
                                             fontSize: 17,
                                             fontWeight: FontWeight.bold,
                                             color: Colors.grey,
                                             decoration: TextDecoration.lineThrough,
                                           ),
                                         ),
                                         const SizedBox(height: 4),
                                                                                   Text(
                                            'Tarih: ${todo.dueDate != null ? "${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}" : "Belirtilmemiş"}',
                                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                                          ),
                                       ],
                                     ),
                                   ),
                                   IconButton(
                                     tooltip: "Sil",
                                     icon: const Icon(Icons.delete, color: Colors.red),
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
    );
  }
}
