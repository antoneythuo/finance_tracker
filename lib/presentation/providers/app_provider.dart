import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Disabled for web compatibility

class AppProvider extends ChangeNotifier {
  String _selectedCurrency = 'KES';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstLaunch = true;
  String _userName = 'Tony';

  String get selectedCurrency => _selectedCurrency;
  ThemeMode get themeMode => _themeMode;
  bool get isFirstLaunch => _isFirstLaunch;
  String get userName => _userName;

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // Persistence disabled for web compatibility
    // You can add web-compatible persistence if needed
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _selectedCurrency = currency;
    // Persistence disabled for web compatibility
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    // Persistence disabled for web compatibility
    notifyListeners();
  }

  Future<void> setFirstLaunch(bool value) async {
    _isFirstLaunch = value;
    // Persistence disabled for web compatibility
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    // Persistence disabled for web compatibility
    notifyListeners();
  }
}
