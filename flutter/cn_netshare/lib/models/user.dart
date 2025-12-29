class User {
  final int id;
  final String email;
  final String role;
  final bool isExitNode;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.isExitNode,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      isExitNode: json['is_exit_node'] == 1 || json['is_exit_node'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'is_exit_node': isExitNode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isHost => role.toLowerCase() == 'host';
  bool get isReceiver => role.toLowerCase() == 'receiver';
}
