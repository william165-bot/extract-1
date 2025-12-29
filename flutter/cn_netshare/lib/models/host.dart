class Host {
  final int userId;
  final String email;
  final bool isActive;
  final DateTime? lastActivity;

  Host({
    required this.userId,
    required this.email,
    required this.isActive,
    this.lastActivity,
  });

  factory Host.fromJson(Map<String, dynamic> json) {
    return Host(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'is_active': isActive,
      'last_activity': lastActivity?.toIso8601String(),
    };
  }

  bool get isOnline {
    if (lastActivity == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActivity!);
    return difference.inMinutes < 5;
  }
}
