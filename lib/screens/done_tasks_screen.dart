import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';

class DoneTasksScreen extends StatefulWidget {
  final List<TodoModel> doneTodos;
  final void Function(TodoModel) onUncheck;

  const DoneTasksScreen({super.key, required this.doneTodos, required this.onUncheck});

  @override
  State<DoneTasksScreen> createState() => _DoneTasksScreenState();
}

class _DoneTasksScreenState extends State<DoneTasksScreen> {
  final Set<String> _expandedIds = {};

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
            onPressed: () {
              widget.onUncheck(todo);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Ana ekrana döndür
            },
            child: const Text("Evet"),
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
        body: widget.doneTodos.isEmpty
            ? const Center(child: Text("Henüz tamamlanmış görev yok."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.doneTodos.length,
                itemBuilder: (context, index) {
                  final todo = widget.doneTodos[index];
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
