class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
  });

  // Veriyi Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  // Map'ten tekrar modele çevir
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate:
          map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }
  TodoModel copyWith({
  String? id,
  String? title,
  String? description,
  DateTime? createdAt,
  DateTime? dueDate,
  bool? isDone,
}) {
  return TodoModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    dueDate: dueDate ?? this.dueDate,
    isDone: isDone ?? this.isDone,
  );
}
}