import 'dart:convert';
import 'package:flutter/material.dart';

const String mockCardsJson = '''
{
  "cards": [
    {
      "shopName": "Albert",
      "description": "Česká Kartička",
      "cardNumber": "SB123456789",
      "color": "#00704A"
    },
    {
      "shopName": "Billa",
      "description": "Slovenska Kartička",
      "cardNumber": "TG987654321",
      "color": "#CC0000"
    },
    {
      "shopName": "Tesco",
      "description": "Ukrajinská Kartička",
      "cardNumber": "TB456123789",
      "color": "#CC0000"
    },
    {
      "shopName": "LIDL",
      "description": "Německá Kartička",
      "cardNumber": "TL999999999",
      "color": "#CC0000"
    },
    {
      "shopName": "Kaufland",
      "description": "Rakúska Kartička",
      "cardNumber": "TL123456789",
      "color": "#CC0000"
    }
  ]
}
''';

class MockCards {
  static List<Map<String, dynamic>> getCards() {
    final Map<String, dynamic> data = json.decode(mockCardsJson);
    return List<Map<String, dynamic>>.from(data['cards']);
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
