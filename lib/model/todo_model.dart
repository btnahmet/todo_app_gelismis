class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int userId;
  // YENİ: Bu veri sunucuyla eşitlendi mi? (0: Hayır, 1: Evet)
  final int isSynced;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    required this.userId,
    this.isSynced = 1, // Varsayılan olarak senkronize kabul edelim
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'userId': userId,
      'isSynced': isSynced, // YENİ
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'] == 1 || map['isDone'] == true,
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      userId: map['userId'],
      isSynced: map['isSynced'] ?? 1, // Veritabanında yoksa 1 varsay
    );
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isDone,
    int? userId,
    int? isSynced, // YENİ
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced, // YENİ
    );
  }
}
