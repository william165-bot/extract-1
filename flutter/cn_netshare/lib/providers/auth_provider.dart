import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final LocalStorageService _storage;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required ApiService apiService,
    required LocalStorageService storage,
  })  : _apiService = apiService,
        _storage = storage {
    _loadUserFromStorage();
  }

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _token != null;

  Future<void> _loadUserFromStorage() async {
    _token = _storage.getToken();
    _user = _storage.getUser();
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.signUp(
        email: email,
        password: password,
        role: role,
      );

      if (response['token'] != null && response['user'] != null) {
        _token = response['token'] as String;
        _user = User.fromJson(response['user'] as Map<String, dynamic>);

        await _storage.saveToken(_token!);
        await _storage.saveUser(_user!);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _apiService.signIn(
        email: email,
        password: password,
      );

      if (response['token'] != null && response['user'] != null) {
        _token = response['token'] as String;
        _user = User.fromJson(response['user'] as Map<String, dynamic>);

        await _storage.saveToken(_token!);
        await _storage.saveUser(_user!);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _user = null;
    _token = null;
    await _storage.clearAll();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
