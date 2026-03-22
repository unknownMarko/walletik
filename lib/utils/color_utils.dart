import 'package:flutter/material.dart';

class ColorUtils {
  static const Color _fallbackColor = Color(0xFF0066CC);

  static Color hexToColor(String hex) {
    try {
      hex = hex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return _fallbackColor;
    }
  }

  /// Darken a color for dark themes — makes cards less bright against dark backgrounds.
  static Color cardColor(String hex, Brightness brightness) {
    final color = hexToColor(hex);
    if (brightness == Brightness.dark) {
      return Color.lerp(color, Colors.black, 0.25)!;
    }
    return color;
  }
}