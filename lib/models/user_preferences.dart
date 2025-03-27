import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences extends ChangeNotifier {
  bool _isDarkMode = false;
  String _routePreference = "Fastest";

  bool get isDarkMode => _isDarkMode;
  String get routePreference => _routePreference;

  UserPreferences() {
    // Do not load preferences here, call `initialize()` manually
  }

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _routePreference = prefs.getString('routePreference') ?? "Fastest";
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setRoutePreference(String value) async {
    _routePreference = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('routePreference', value);
    notifyListeners();
  }
}
