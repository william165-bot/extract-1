import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/host.dart';
import '../models/connection.dart';
import '../services/api_service.dart';
import '../services/data_tracking_service.dart';
import '../constants/app_config.dart';

class ReceiverProvider with ChangeNotifier {
  final ApiService _apiService;
  final DataTrackingService _dataTrackingService;

  List<Host> _availableHosts = [];
  Connection? _activeConnection;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  ReceiverProvider({
    required ApiService apiService,
    required DataTrackingService dataTrackingService,
  })  : _apiService = apiService,
        _dataTrackingService = dataTrackingService;

  List<Host> get availableHosts => _availableHosts;
  Connection? get activeConnection => _activeConnection;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _activeConnection != null;

  Map<String, dynamic> get localDataUsage => _dataTrackingService.getStats();

  Future<void> loadAvailableHosts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final hosts = await _apiService.getAvailableHosts();
      _availableHosts = hosts;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestConnection(int hostUserId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.requestConnection(
        hostUserId: hostUserId,
      );

      if (response['connection'] != null) {
        _activeConnection = Connection.fromJson(
          response['connection'] as Map<String, dynamic>,
        );
        _dataTrackingService.startTracking();
        startAutoRefresh();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadActiveConnection() async {
    try {
      final connection = await _apiService.getActiveConnection();
      _activeConnection = connection;
      
      if (connection != null) {
        _dataTrackingService.startTracking();
        startAutoRefresh();
      }
      
      notifyListeners();
    } catch (e) {
      print('Failed to load active connection: $e');
    }
  }

  Future<bool> disconnectConnection() async {
    if (_activeConnection == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _apiService.disconnectConnection(
        connectionId: _activeConnection!.id,
      );

      _activeConnection = null;
      _dataTrackingService.stopTracking();
      stopAutoRefresh();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void startAutoRefresh() {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(AppConfig.hostListRefreshInterval, (_) {
      loadAvailableHosts();
      if (_activeConnection != null) {
        loadActiveConnection();
      }
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
    _dataTrackingService.dispose();
    super.dispose();
  }
}
