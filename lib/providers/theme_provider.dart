import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(AppConstants.prefsThemeMode) ?? 'light';
    _mode = v == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
        AppConstants.prefsThemeMode, _mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
