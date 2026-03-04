import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyUserRole = 'user_role';
  static const String _keyStartTime = 'start_time';

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  Future<void> setUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  Future<DateTime?> getStartTime() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeStr = prefs.getString(_keyStartTime);
    if (startTimeStr != null) {
      return DateTime.parse(startTimeStr);
    }
    return null;
  }

  Future<void> setStartTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStartTime, time.toIso8601String());
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
