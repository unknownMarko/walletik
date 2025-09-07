import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = true;
  static const String _themeKey = 'isDarkTheme';

  bool get isDarkTheme => _isDarkTheme;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData {
    if (_isDarkTheme) {
      return ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1b2345),
          onSurface: Colors.white,
          primary: Color(0xFF1b2345),
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF1b2345),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1b2345),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white60;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white.withValues(alpha: 0.3);
            }
            return Colors.white.withValues(alpha: 0.1);
          }),
        ),
      );
    } else {
      return ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
      );
    }
  }

  String get themeName => _isDarkTheme ? 'Dark Blue' : 'Light';

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveTheme();
    notifyListeners();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool(_themeKey) ?? true;
    notifyListeners();
  }

  void _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themeKey, _isDarkTheme);
  }
}