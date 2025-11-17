import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!;
  }

  // Token Management
  Future<bool> saveAccessToken(String token) async {
    return await prefs.setString(AppConstants.accessTokenKey, token);
  }

  String? getAccessToken() {
    return prefs.getString(AppConstants.accessTokenKey);
  }

  Future<bool> saveRefreshToken(String token) async {
    return await prefs.setString(AppConstants.refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<bool> saveTokens(AuthTokens tokens) async {
    final accessSaved = await saveAccessToken(tokens.accessToken);
    final refreshSaved = await saveRefreshToken(tokens.refreshToken);
    return accessSaved && refreshSaved;
  }

  Future<bool> clearTokens() async {
    final accessRemoved = await prefs.remove(AppConstants.accessTokenKey);
    final refreshRemoved = await prefs.remove(AppConstants.refreshTokenKey);
    return accessRemoved && refreshRemoved;
  }

  bool hasAccessToken() {
    return getAccessToken() != null;
  }

  // User Data Management
  Future<bool> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    return await prefs.setString(AppConstants.userDataKey, userJson);
  }

  User? getUser() {
    final userJson = prefs.getString(AppConstants.userDataKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<bool> clearUser() async {
    return await prefs.remove(AppConstants.userDataKey);
  }

  // General Storage
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  Future<bool> clear() async {
    return await prefs.clear();
  }

  // Complete Logout
  Future<bool> clearAll() async {
    await clearTokens();
    await clearUser();
    return true;
  }
}