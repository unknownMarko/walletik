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
}