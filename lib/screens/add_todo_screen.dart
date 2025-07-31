import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:uuid/uuid.dart';

class AddTodoScreen extends StatefulWidget {
  final Function(TodoModel) onAdd;
  final Function(TodoModel)? onUpdate;
  final TodoModel? editingTodo;

  const AddTodoScreen({
    super.key,
    required this.onAdd,
    this.onUpdate,
    this.editingTodo,
  });

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.editingTodo != null) {
      _isEditMode = true;
      _titleController.text = widget.editingTodo!.title;
      _descriptionController.text = widget.editingTodo!.description ?? '';
      _selectedDate = widget.editingTodo!.dueDate;
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) return;

    if (_isEditMode) {
      final updatedTodo = TodoModel(
        id: widget.editingTodo!.id,
        title: title,
        description: description,
        isDone: widget.editingTodo!.isDone,
        createdAt: widget.editingTodo!.createdAt,
        dueDate: _selectedDate,
      );

      widget.onUpdate?.call(updatedTodo);
    } else {
      final newTodo = TodoModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
        dueDate: _selectedDate,
      );

      widget.onAdd(newTodo);
    }

    Navigator.pop(context);
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditMode ? "Görev Düzenle" : "Görev Ekle"),
          backgroundColor: const Color(0xFFFFF176),
          elevation: 1,
        ),
        backgroundColor: const Color(0xFFFFF9C4),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.01),
      
                // Başlık
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 60,
                    maxHeight: height * 0.15,
                  ),
                  child: Scrollbar(
                    child: TextField(
                      controller: _titleController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Görev Başlığı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
      
                // Açıklama
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 100,
                    maxHeight: height * 0.3,
                  ),
                  child: Scrollbar(
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Görev Açıklaması',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
      
                // Tarih Seçici
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Tarih seçilmedi.'
                            : 'Seçilen Tarih: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Tarih Seç"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
      
                // Kaydet/Güncelle Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(_isEditMode ? "Görevi Güncelle" : "Görevi Ekle"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
