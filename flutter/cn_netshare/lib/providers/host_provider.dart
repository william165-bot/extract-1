import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/connection.dart';
import '../models/data_usage.dart';
import '../services/api_service.dart';
import '../constants/app_config.dart';

class HostProvider with ChangeNotifier {
  final ApiService _apiService;

  bool _isConfigured = false;
  bool _isLoading = false;
  List<Connection> _connections = [];
  Map<int, List<DataUsage>> _dataUsageMap = {};
  String? _errorMessage;
  Timer? _refreshTimer;

  HostProvider({required ApiService apiService}) : _apiService = apiService;

  bool get isConfigured => _isConfigured;
  bool get isLoading => _isLoading;
  List<Connection> get connections => _connections;
  String? get errorMessage => _errorMessage;

  List<DataUsage> getDataUsageForConnection(int connectionId) {
    return _dataUsageMap[connectionId] ?? [];
  }

  Future<bool> configureAsHost({required bool enable}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.configureAsHost(enable: enable);
      _isConfigured = response['is_exit_node'] == true;

      _isLoading = false;
      notifyListeners();

      if (_isConfigured) {
        await loadConnections();
        startAutoRefresh();
      } else {
        stopAutoRefresh();
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadConnections() async {
    try {
      final connections = await _apiService.getHostConnections();
      _connections = connections;
      notifyListeners();

      for (final connection in connections) {
        await _loadDataUsageForConnection(connection.id);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> _loadDataUsageForConnection(int connectionId) async {
    try {
      final usage = await _apiService.getConnectionDataUsage(
        connectionId: connectionId,
      );
      _dataUsageMap[connectionId] = usage;
      notifyListeners();
    } catch (e) {
      print('Failed to load data usage for connection $connectionId: $e');
    }
  }

  void startAutoRefresh() {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(AppConfig.dataRefreshInterval, (_) {
      loadConnections();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
