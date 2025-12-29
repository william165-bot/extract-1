class DataUsage {
  final int connectionId;
  final int bytesSent;
  final int bytesReceived;
  final DateTime timestamp;

  DataUsage({
    required this.connectionId,
    required this.bytesSent,
    required this.bytesReceived,
    required this.timestamp,
  });

  factory DataUsage.fromJson(Map<String, dynamic> json) {
    return DataUsage(
      connectionId: json['connection_id'] as int,
      bytesSent: json['bytes_sent'] as int,
      bytesReceived: json['bytes_received'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connection_id': connectionId,
      'bytes_sent': bytesSent,
      'bytes_received': bytesReceived,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  int get totalBytes => bytesSent + bytesReceived;

  String get formattedBytesSent => _formatBytes(bytesSent);
  String get formattedBytesReceived => _formatBytes(bytesReceived);
  String get formattedTotalBytes => _formatBytes(totalBytes);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
