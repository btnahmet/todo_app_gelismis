class UserModel {
  final int? id;
  final String name;
  final String surname;
  final String username;
  final String password;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.surname,
    required this.username,
    required this.password,
    required this.createdAt,
  });

  // Veriyi Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'username': username,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Map'ten tekrar modele çevir
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      surname: map['surname'],
      username: map['username'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Kopyalama metodu
  UserModel copyWith({
    int? id,
    String? name,
    String? surname,
    String? username,
    String? password,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Tam ad getter'ı
  String get fullName => '$name $surname';

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, surname: $surname, username: $username, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 