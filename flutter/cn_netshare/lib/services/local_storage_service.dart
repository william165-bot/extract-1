import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_config.dart';
import '../models/user.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> saveToken(String token) async {
    await _preferences?.setString(AppConfig.tokenKey, token);
  }

  String? getToken() {
    return _preferences?.getString(AppConfig.tokenKey);
  }

  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _preferences?.setString(AppConfig.userKey, userJson);
    await _preferences?.setString(AppConfig.roleKey, user.role);
  }

  User? getUser() {
    final userJson = _preferences?.getString(AppConfig.userKey);
    if (userJson == null) return null;
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  String? getRole() {
    return _preferences?.getString(AppConfig.roleKey);
  }

  Future<void> clearAll() async {
    await _preferences?.clear();
  }

  Future<void> saveBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  Future<void> saveString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }
}
