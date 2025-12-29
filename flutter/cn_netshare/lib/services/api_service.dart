import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../models/user.dart';
import '../models/host.dart';
import '../models/connection.dart';
import '../models/data_usage.dart';
import 'local_storage_service.dart';

class ApiService {
  final String baseUrl;
  final LocalStorageService _storage;

  ApiService({
    required this.baseUrl,
    required LocalStorageService storage,
  }) : _storage = storage;

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      final token = _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      ).timeout(AppConfig.connectionTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Sign up failed');
      }
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signin'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.connectionTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Sign in failed');
      }
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: _getHeaders(),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(data['user']);
      } else {
        throw Exception('Failed to get user info');
      }
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<List<Host>> getAvailableHosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/hosts'),
        headers: _getHeaders(),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final hostsList = data['hosts'] as List<dynamic>;
        return hostsList.map((json) => Host.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get hosts');
      }
    } catch (e) {
      throw Exception('Failed to get available hosts: $e');
    }
  }

  Future<Map<String, dynamic>> configureAsHost({required bool enable}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/host/configure'),
        headers: _getHeaders(),
        body: jsonEncode({
          'enable': enable,
        }),
      ).timeout(AppConfig.connectionTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to configure host');
      }
    } catch (e) {
      throw Exception('Failed to configure as host: $e');
    }
  }

  Future<List<Connection>> getHostConnections() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/host/connections'),
        headers: _getHeaders(),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final connectionsList = data['connections'] as List<dynamic>;
        return connectionsList.map((json) => Connection.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get connections');
      }
    } catch (e) {
      throw Exception('Failed to get host connections: $e');
    }
  }

  Future<Map<String, dynamic>> requestConnection({required int hostUserId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/receiver/request'),
        headers: _getHeaders(),
        body: jsonEncode({
          'host_user_id': hostUserId,
        }),
      ).timeout(AppConfig.connectionTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to request connection');
      }
    } catch (e) {
      throw Exception('Failed to request connection: $e');
    }
  }

  Future<Connection?> getActiveConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/receiver/connection'),
        headers: _getHeaders(),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['connection'] != null) {
          return Connection.fromJson(data['connection']);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<DataUsage>> getConnectionDataUsage({required int connectionId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/data-usage/$connectionId'),
        headers: _getHeaders(),
      ).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final usageList = data['usage'] as List<dynamic>;
        return usageList.map((json) => DataUsage.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> disconnectConnection({required int connectionId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/connection/$connectionId/disconnect'),
        headers: _getHeaders(),
      ).timeout(AppConfig.connectionTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to disconnect');
      }
    } catch (e) {
      throw Exception('Failed to disconnect: $e');
    }
  }
}
