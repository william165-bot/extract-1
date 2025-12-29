import 'package:flutter/foundation.dart';
import '../models/connection.dart';
import '../models/data_usage.dart';
import '../services/api_service.dart';

class ConnectionProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Connection> _allConnections = [];
  Map<int, List<DataUsage>> _dataUsageHistory = {};
  bool _isLoading = false;
  String? _errorMessage;

  ConnectionProvider({required ApiService apiService})
      : _apiService = apiService;

  List<Connection> get allConnections => _allConnections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DataUsage> getDataUsageHistory(int connectionId) {
    return _dataUsageHistory[connectionId] ?? [];
  }

  Future<void> loadAllConnections() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final connections = await _apiService.getHostConnections();
      _allConnections = connections;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDataUsageHistory(int connectionId) async {
    try {
      final usage = await _apiService.getConnectionDataUsage(
        connectionId: connectionId,
      );
      _dataUsageHistory[connectionId] = usage;
      notifyListeners();
    } catch (e) {
      print('Failed to load data usage history: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
