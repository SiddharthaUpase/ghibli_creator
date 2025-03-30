import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:html' as html;

class RateLimiter {
  static const String _storageKey = 'upload_history';
  static const int _maxUploadsPerHour = 5;

  Future<bool> canUpload() async {
    // Skip rate limiting on localhost
    final currentUrl = html.window.location.href;
    if (currentUrl.contains('localhost') || currentUrl.contains('127.0.0.1')) {
      print('Running on localhost - rate limiting disabled');
      return true;
    }

    final prefs = await SharedPreferences.getInstance();
    final uploadHistory = prefs.getStringList(_storageKey) ?? [];

    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // Parse the timestamps and filter for uploads within the last hour
    final recentUploads =
        uploadHistory
            .map((timestamp) => DateTime.parse(timestamp))
            .where((time) => time.isAfter(oneHourAgo))
            .toList();

    // Clean up old entries
    final updatedHistory = [
      ...recentUploads.map((time) => time.toIso8601String()),
      now.toIso8601String(),
    ];

    await prefs.setStringList(_storageKey, updatedHistory);

    // Check if the user can upload
    return recentUploads.length < _maxUploadsPerHour;
  }
}
