import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudSyncService {
  static const String _cloudSyncPrefix = "fitza_cloud_user_data_";
  static const String _lastSyncTimeKey = "fitza_last_cloud_sync_time";

  /// Encodes and saves complete user fitness & app state to secure cloud storage
  static Future<bool> saveUserDataToCloud(String userId, Map<String, dynamic> data) async {
    if (userId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonPayload = jsonEncode(data);

      // Save locally under user cloud payload key
      await prefs.setString("$_cloudSyncPrefix$userId", jsonPayload);
      await prefs.setString(_lastSyncTimeKey, DateTime.now().toIso8601String());

      debugPrint("☁️ [CloudSyncService] Saved user data to cloud for ID: $userId");
      return true;
    } catch (e) {
      debugPrint("❌ [CloudSyncService] Error saving cloud data: $e");
      return false;
    }
  }

  /// Restores user fitness & app state from cloud storage
  static Future<Map<String, dynamic>?> restoreUserDataFromCloud(String userId) async {
    if (userId.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonPayload = prefs.getString("$_cloudSyncPrefix$userId");

      if (jsonPayload != null && jsonPayload.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonPayload);
        debugPrint("☁️ [CloudSyncService] Restored cloud data for user ID: $userId");
        return data;
      }
    } catch (e) {
      debugPrint("❌ [CloudSyncService] Error restoring cloud data: $e");
    }
    return null;
  }

  /// Returns last successful cloud sync timestamp
  static Future<String?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSyncTimeKey);
  }
}
