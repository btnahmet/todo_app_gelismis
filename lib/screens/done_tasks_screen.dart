import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';

class DoneTasksScreen extends StatelessWidget {
  final List<TodoModel> doneTodos;

  const DoneTasksScreen({super.key, required this.doneTodos});

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
        body: doneTodos.isEmpty
            ? const Center(child: Text("Henüz tamamlanmış görev yok."))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doneTodos.length,
                itemBuilder: (context, index) {
                  final todo = doneTodos[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.check, color: Colors.green),
                      title: Text(todo.title),
                      subtitle: Text(
                        todo.dueDate != null
                            ? "Tarih: ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}"
                            : "Tarih: Belirtilmemiş",
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
