import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walletik/utils/color_utils.dart';

void main() {
  group('ColorUtils.hexToColor', () {
    test('parses 6-digit hex with #', () {
      final color = ColorUtils.hexToColor('#FF0000');
      expect(color, const Color(0xFFFF0000));
    });

    test('parses 6-digit hex without #', () {
      final color = ColorUtils.hexToColor('00FF00');
      expect(color, const Color(0xFF00FF00));
    });

    test('parses lowercase hex', () {
      final color = ColorUtils.hexToColor('#e74c3c');
      expect(color, const Color(0xFFE74C3C));
    });

    test('returns fallback for invalid hex', () {
      final color = ColorUtils.hexToColor('not-a-color');
      expect(color, const Color(0xFF0066CC));
    });

    test('handles empty string without crashing', () {
      final color = ColorUtils.hexToColor('');
      expect(color, isNotNull);
    });

    test('parses common card colors', () {
      expect(ColorUtils.hexToColor('#0066CC'), const Color(0xFF0066CC));
      expect(ColorUtils.hexToColor('#E74C3C'), const Color(0xFFE74C3C));
      expect(ColorUtils.hexToColor('#27AE60'), const Color(0xFF27AE60));
      expect(ColorUtils.hexToColor('#9B59B6'), const Color(0xFF9B59B6));
      expect(ColorUtils.hexToColor('#F39C12'), const Color(0xFFF39C12));
    });
  });
}
