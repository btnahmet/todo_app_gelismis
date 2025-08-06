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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;
    final isLandscape = width > height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Tamamlanan Görevler",
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                ? Center(
                    child: Text(
                      "Henüz tamamlanmış görev yok.",
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        color: Colors.blueGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    itemCount: _doneTodos.length,
                    itemBuilder: (context, index) {
                      final todo = _doneTodos[index];
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
                                      value: true,
                                      onChanged: (_) => _confirmUncheck(todo),
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
                                            color: Colors.grey,
                                            decoration: TextDecoration.lineThrough,
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
    );
  }
}
