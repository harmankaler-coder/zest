import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_data.dart';

class StorageService {
  static const String _goalsKey = 'twelve_week_goals';
  static const String _settingsKey = 'twelve_week_settings';

  static Future<List<Goal>> loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString(_goalsKey);

      if (goalsJson == null) return [];

      final List<dynamic> goalsList = json.decode(goalsJson);
      return goalsList.map((goalJson) => Goal.fromJson(goalJson)).toList();
    } catch (e) {
      print('Error loading goals: $e');
      return [];
    }
  }

  static Future<void> saveGoals(List<Goal> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = json.encode(goals.map((goal) => goal.toJson()).toList());
      await prefs.setString(_goalsKey, goalsJson);
    } catch (e) {
      print('Error saving goals: $e');
    }
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson == null) {
        return {
          'notifications_enabled': true,
          'weekly_review_day': 0, // Sunday
          'theme_mode': 'system',
          'has_seen_splash': false,
        };
      }

      return json.decode(settingsJson);
    } catch (e) {
      print('Error loading settings: $e');
      return {
        'notifications_enabled': true,
        'weekly_review_day': 0,
        'theme_mode': 'system',
        'has_seen_splash': false,
      };
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings);
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}