import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = true;
  ThemeData? _cachedThemeData;
  static const String _themeKey = 'isDarkTheme';

  bool get isDarkTheme => _isDarkTheme;

  ThemeProvider() {
    _cachedThemeData = _buildThemeData();
    _loadTheme();
  }

  ThemeData get themeData => _cachedThemeData ??= _buildThemeData();

  ThemeData _buildThemeData() {
    if (_isDarkTheme) {
      const deepPurple = Color(0xFF6535CC);
      const surface = Color(0xFF1a1128);
      const surfaceLight = Color(0xFF2a1f3d);
      const surfaceDark = Color(0xFF120b1e);

      return ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: deepPurple,
          onPrimary: Colors.white,
          primaryContainer: deepPurple,
          onPrimaryContainer: Colors.white,
          secondary: deepPurple,
          onSecondary: Colors.white,
          secondaryContainer: surfaceLight,
          onSecondaryContainer: Colors.white,
          surface: surface,
          onSurface: Colors.white,
          surfaceContainerLowest: surfaceDark,
          surfaceContainerLow: surface,
          surfaceContainer: surface,
          surfaceContainerHigh: surfaceLight,
          surfaceContainerHighest: surfaceLight,
          surfaceTint: Colors.transparent,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceDark,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: deepPurple,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: deepPurple,
          foregroundColor: Colors.white,
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
      const deepPurple = Color(0xFF6535CC);

      return ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: deepPurple,
          brightness: Brightness.light,
        ).copyWith(
          primary: deepPurple,
          surfaceTint: Colors.transparent,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: deepPurple,
          unselectedItemColor: Colors.grey,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: deepPurple,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: deepPurple,
          foregroundColor: Colors.white,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.black54),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return deepPurple;
            }
            return Colors.grey.shade400;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return deepPurple.withValues(alpha: 0.3);
            }
            return Colors.grey.withValues(alpha: 0.3);
          }),
        ),
      );
    }
  }

  String get themeName => _isDarkTheme ? 'Dark Blue' : 'Light';

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _cachedThemeData = _buildThemeData();
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = prefs.getBool(_themeKey) ?? true;
    if (loaded != _isDarkTheme) {
      _isDarkTheme = loaded;
      _cachedThemeData = _buildThemeData();
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkTheme);
  }
}
