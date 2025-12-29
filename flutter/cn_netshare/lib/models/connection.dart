class Connection {
  final int id;
  final int hostUserId;
  final int receiverUserId;
  final String? wireguardConfig;
  final String status;
  final DateTime createdAt;
  final String? hostEmail;
  final String? receiverEmail;

  Connection({
    required this.id,
    required this.hostUserId,
    required this.receiverUserId,
    this.wireguardConfig,
    required this.status,
    required this.createdAt,
    this.hostEmail,
    this.receiverEmail,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as int,
      hostUserId: json['host_user_id'] as int,
      receiverUserId: json['receiver_user_id'] as int,
      wireguardConfig: json['wireguard_config'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      hostEmail: json['host_email'] as String?,
      receiverEmail: json['receiver_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'host_user_id': hostUserId,
      'receiver_user_id': receiverUserId,
      'wireguard_config': wireguardConfig,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'host_email': hostEmail,
      'receiver_email': receiverEmail,
    };
  }

  bool get isActive => status.toLowerCase() == 'active';
  bool get isDisconnected => status.toLowerCase() == 'disconnected';
  bool get isPending => status.toLowerCase() == 'pending';
}
