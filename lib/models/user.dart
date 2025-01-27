// Definisi kelas User
class User {
  // Deklarasi atribut dalam kelas User
  final int id;
  final String username;
  final String password;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['userid'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}