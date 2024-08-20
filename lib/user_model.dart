import 'dart:convert';

class User {
  final int? id; // Tambahkan properti id
  final String email;
  final String password;
  final String role;
  final String foto;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'foto': foto
    };
  }

  // Konversi objek User ke JSON
  String toJson() => json.encode(toMap());

  // Konversi dari Map ke objek User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      foto: map['foto'],
    );
  }

  // Konversi dari JSON string ke objek User
  static User fromJson(String source) => User.fromMap(json.decode(source));
}
