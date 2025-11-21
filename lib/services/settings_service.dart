// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keySessionCompleteNotification = 'session_complete_notification';
  static const String _keyBreakReminderNotification = 'break_reminder_notification';
  static const String _keyTaskCompleteNotification = 'task_complete_notification';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyAutoStartBreak = 'auto_start_break';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';

  // Notification settings
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
  }

  Future<bool> getSessionCompleteNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySessionCompleteNotification) ?? true;
  }

  Future<void> setSessionCompleteNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySessionCompleteNotification, value);
  }

  Future<bool> getBreakReminderNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBreakReminderNotification) ?? true;
  }

  Future<void> setBreakReminderNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBreakReminderNotification, value);
  }

  Future<bool> getTaskCompleteNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTaskCompleteNotification) ?? true;
  }

  Future<void> setTaskCompleteNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTaskCompleteNotification, value);
  }

  // App settings
  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, value);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'en';
  }

  Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }

  Future<bool> getAutoStartBreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoStartBreak) ?? true;
  }

  Future<void> setAutoStartBreak(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoStartBreak, value);
  }

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, value);
  }

  Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVibrationEnabled) ?? true;
  }

  Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibrationEnabled, value);
  }
}

