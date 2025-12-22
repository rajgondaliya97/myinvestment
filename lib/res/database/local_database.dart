import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_data_key.dart';


class AppLocalData {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // -------------------------
  // Generic SET Methods
  // -------------------------

  static Future<void> setString(LocalDataKey key, String value) async {
    await _prefs?.setString(key.key, value);
  }

  static Future<void> setBool(LocalDataKey key, bool value) async {
    await _prefs?.setBool(key.key, value);
  }

  static Future<void> setInt(LocalDataKey key, int value) async {
    await _prefs?.setInt(key.key, value);
  }

  static Future<void> setDouble(LocalDataKey key, double value) async {
    await _prefs?.setDouble(key.key, value);
  }

  static Future<void> setStringList(LocalDataKey key, List<String> value) async {
    await _prefs?.setStringList(key.key, value);
  }

  static Future<void> setMap(LocalDataKey key, Map<String, dynamic> value) async {
    await _prefs?.setString(key.key, jsonEncode(value));
  }

  static Future<void> setList(LocalDataKey key, List<dynamic> value) async {
    await _prefs?.setString(key.key, jsonEncode(value));
  }

  // -------------------------
  // Generic GET Methods
  // -------------------------

  static String? getString(LocalDataKey key) => _prefs?.getString(key.key);

  static bool? getBool(LocalDataKey key) => _prefs?.getBool(key.key);

  static int? getInt(LocalDataKey key) => _prefs?.getInt(key.key);

  static double? getDouble(LocalDataKey key) => _prefs?.getDouble(key.key);

  static List<String>? getStringList(LocalDataKey key) =>
      _prefs?.getStringList(key.key);

  static Map<String, dynamic>? getMap(LocalDataKey key) {
    final jsonString = _prefs?.getString(key.key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  static List<dynamic>? getList(LocalDataKey key) {
    final jsonString = _prefs?.getString(key.key);
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString);
      return decoded is List ? decoded : null;
    } catch (e) {
      return null;
    }
  }

  // -------------------------
  // Utility Methods
  // -------------------------

  static Future<void> remove(LocalDataKey key) async {
    await _prefs?.remove(key.key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  static bool contains(LocalDataKey key) => _prefs?.containsKey(key.key) ?? false;
}