import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/todo_model.dart';
import 'package:uuid/uuid.dart';

class AddTodoScreen extends StatefulWidget {
  final Function(TodoModel) onAdd;
  final Function(TodoModel)? onUpdate;
  final TodoModel? editingTodo;
  final int userId;

  const AddTodoScreen({
    super.key,
    required this.onAdd,
    this.onUpdate,
    this.editingTodo,
    required this.userId,
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

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görev başlığı boş olamaz!')),
      );
      return;
    }

    if (_isEditMode && widget.editingTodo != null) {
      final updatedTodo = TodoModel(
        id: widget.editingTodo!.id,
        title: title,
        description: description.isEmpty ? null : description,
        isDone: widget.editingTodo!.isDone,
        createdAt: widget.editingTodo!.createdAt,
        dueDate: _selectedDate,
        userId: widget.userId,
      );

      widget.onUpdate?.call(updatedTodo);
    } else {
      final newTodo = TodoModel(
        id: const Uuid().v4(),
        title: title,
        description: description.isEmpty ? null : description,
        createdAt: DateTime.now(),
        dueDate: _selectedDate,
        userId: widget.userId,
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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;
    final isLandscape = width > height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditMode ? "Görev Düzenle" : "Görev Ekle",
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFFFFF176),
          elevation: 1,
        ),
        backgroundColor: const Color(0xFFFFF9C4),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.all(
                  isTablet ? width * 0.1 : width * 0.08,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isLandscape ? height * 0.02 : height * 0.01),
                    
                    // Form Container
                    Container(
                      width: isTablet ? width * 0.6 : double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 600 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: isTablet ? 80 : 60,
                              maxHeight: height * (isTablet ? 0.12 : 0.15),
                            ),
                            child: Scrollbar(
                              child: TextField(
                                controller: _titleController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: TextStyle(fontSize: isTablet ? 18 : 16),
                                decoration: InputDecoration(
                                  labelText: 'Görev Başlığı',
                                  labelStyle: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    color: Colors.blueGrey,
                                  ),
                                  border: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 24 : 16),
                          
                          // Açıklama
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: isTablet ? 120 : 100,
                              maxHeight: height * (isTablet ? 0.25 : 0.3),
                            ),
                            child: Scrollbar(
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: TextStyle(fontSize: isTablet ? 18 : 16),
                                decoration: InputDecoration(
                                  labelText: 'Görev Açıklaması',
                                  labelStyle: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    color: Colors.blueGrey,
                                  ),
                                  border: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 24 : 16),
                          
                          // Tarih Seçici
                          Container(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                              border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedDate == null
                                        ? 'Tarih seçilmedi.'
                                        : 'Seçilen Tarih: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: isTablet ? 18 : 16,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isTablet ? 20 : 16),
                                ElevatedButton(
                                  onPressed: _pickDate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 24 : 16,
                                      vertical: isTablet ? 12 : 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                                    ),
                                  ),
                                  child: Text(
                                    "Tarih Seç",
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 32 : 20),
                          
                          // Kaydet/Güncelle Butonu
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 20 : 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                _isEditMode ? "Görevi Güncelle" : "Görevi Ekle",
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: isLandscape ? height * 0.02 : height * 0.01),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
