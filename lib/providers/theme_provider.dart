import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, oled, purple }

class ThemeProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.dark;
  ThemeData? _cachedThemeData;
  static const String _themeKey = 'appTheme';

  static const _deepPurple = Color(0xFF6535CC);

  AppTheme get theme => _theme;
  bool get isDarkTheme => _theme != AppTheme.light;

  ThemeProvider() {
    _cachedThemeData = _buildThemeData();
    _loadTheme();
  }

  ThemeData get themeData => _cachedThemeData ??= _buildThemeData();

  String get themeName => switch (_theme) {
    AppTheme.light => 'Light',
    AppTheme.dark => 'Dark',
    AppTheme.oled => 'Dark (OLED)',
    AppTheme.purple => 'Dark Purple',
  };

  void setTheme(AppTheme theme) {
    if (_theme == theme) return;
    _theme = theme;
    _cachedThemeData = _buildThemeData();
    _saveTheme();
    notifyListeners();
  }

  // Keep for backward compat
  void toggleTheme() {
    final next = AppTheme.values[(_theme.index + 1) % AppTheme.values.length];
    setTheme(next);
  }

  ThemeData _buildThemeData() {
    return switch (_theme) {
      AppTheme.light => _buildLight(),
      AppTheme.dark => _buildDark(),
      AppTheme.oled => _buildOled(),
      AppTheme.purple => _buildPurple(),
    };
  }

  ThemeData _buildDark() {
    const surface = Color(0xFF121212);
    const surfaceLight = Color(0xFF1e1e1e);
    const surfaceDark = Color(0xFF0a0a0a);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: _deepPurple,
        onPrimary: Colors.white,
        primaryContainer: _deepPurple,
        onPrimaryContainer: Colors.white,
        secondary: _deepPurple,
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
      appBarTheme: const AppBarTheme(backgroundColor: surfaceDark),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _deepPurple,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _deepPurple,
        foregroundColor: Colors.white,
      ),
      switchTheme: _darkSwitchTheme(),
    );
  }

  ThemeData _buildOled() {
    const surface = Colors.black;
    const surfaceLight = Color(0xFF1a1a1a);
    const surfaceDark = Colors.black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: _deepPurple,
        onPrimary: Colors.white,
        primaryContainer: _deepPurple,
        onPrimaryContainer: Colors.white,
        secondary: _deepPurple,
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
      appBarTheme: const AppBarTheme(backgroundColor: surfaceDark),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _deepPurple,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _deepPurple,
        foregroundColor: Colors.white,
      ),
      switchTheme: _darkSwitchTheme(),
    );
  }

  ThemeData _buildPurple() {
    const surface = Color(0xFF1e0a3c);
    const surfaceLight = Color(0xFF2d1557);
    const surfaceDark = Color(0xFF140528);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: _deepPurple,
        onPrimary: Colors.white,
        primaryContainer: _deepPurple,
        onPrimaryContainer: Colors.white,
        secondary: _deepPurple,
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
      appBarTheme: const AppBarTheme(backgroundColor: surfaceDark),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _deepPurple,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _deepPurple,
        foregroundColor: Colors.white,
      ),
      switchTheme: _darkSwitchTheme(),
    );
  }

  ThemeData _buildLight() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _deepPurple,
        brightness: Brightness.light,
      ).copyWith(
        primary: _deepPurple,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _deepPurple,
        unselectedItemColor: Colors.grey,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _deepPurple,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _deepPurple,
        foregroundColor: Colors.white,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.black54),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _deepPurple;
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _deepPurple.withValues(alpha: 0.3);
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
    );
  }

  static SwitchThemeData _darkSwitchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return Colors.white60;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white.withValues(alpha: 0.3);
        }
        return Colors.white.withValues(alpha: 0.1);
      }),
    );
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeKey) ?? AppTheme.dark.index;
    final loaded = AppTheme.values[index.clamp(0, AppTheme.values.length - 1)];
    if (loaded != _theme) {
      _theme = loaded;
      _cachedThemeData = _buildThemeData();
      notifyListeners();
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _theme.index);
  }
}
