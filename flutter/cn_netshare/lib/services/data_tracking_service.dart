import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class DataTrackingService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  int _bytesSent = 0;
  int _bytesReceived = 0;
  DateTime? _trackingStartTime;

  int get bytesSent => _bytesSent;
  int get bytesReceived => _bytesReceived;
  int get totalBytes => _bytesSent + _bytesReceived;

  void startTracking() {
    _trackingStartTime = DateTime.now();
    _bytesSent = 0;
    _bytesReceived = 0;
    
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateUsageStats();
    });
  }

  void stopTracking() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void _updateUsageStats() {
    _bytesSent += 1024;
    _bytesReceived += 2048;
  }

  Future<bool> checkNetworkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void recordSentBytes(int bytes) {
    _bytesSent += bytes;
  }

  void recordReceivedBytes(int bytes) {
    _bytesReceived += bytes;
  }

  void resetStats() {
    _bytesSent = 0;
    _bytesReceived = 0;
    _trackingStartTime = DateTime.now();
  }

  Duration? getTrackingDuration() {
    if (_trackingStartTime == null) return null;
    return DateTime.now().difference(_trackingStartTime!);
  }

  Map<String, dynamic> getStats() {
    return {
      'bytes_sent': _bytesSent,
      'bytes_received': _bytesReceived,
      'total_bytes': totalBytes,
      'tracking_duration': getTrackingDuration()?.inSeconds ?? 0,
    };
  }

  void dispose() {
    stopTracking();
  }
}
