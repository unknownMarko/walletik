import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CardStorage {
  static const String _cardsKey = 'loyalty_cards';
  
  static Future<List<Map<String, dynamic>>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString(_cardsKey);
    
    if (cardsJson == null) {
      // Return default cards if no data exists
      return _getDefaultCards();
    }
    
    try {
      final List<dynamic> cardsList = json.decode(cardsJson);
      return cardsList.cast<Map<String, dynamic>>();
    } catch (e) {
      // Return default cards if parsing fails
      return _getDefaultCards();
    }
  }
  
  static Future<void> saveCards(List<Map<String, dynamic>> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = json.encode(cards);
    await prefs.setString(_cardsKey, cardsJson);
  }
  
  static Future<void> addCard(Map<String, dynamic> newCard) async {
    final cards = await loadCards();
    cards.add(newCard);
    await saveCards(cards);
  }
  
  static Future<void> removeCard(Map<String, dynamic> cardToRemove) async {
    final cards = await loadCards();
    cards.removeWhere((card) => 
      card['shopName'] == cardToRemove['shopName'] && 
      card['cardNumber'] == cardToRemove['cardNumber']
    );
    await saveCards(cards);
  }
  
  static List<Map<String, dynamic>> _getDefaultCards() {
    return [
      {
        'shopName': 'Albert',
        'description': 'Česká Kartička',
        'cardNumber': 'SB123456789',
        'color': '#00704A'
      },
      {
        'shopName': 'Billa',
        'description': 'Slovenska Kartička',
        'cardNumber': 'TG987654321',
        'color': '#CC0000'
      },
      {
        'shopName': 'Tesco',
        'description': 'Ukrajinská Kartička',
        'cardNumber': 'TB456123789',
        'color': '#CC0000'
      },
      {
        'shopName': 'LIDL',
        'description': 'Německá Kartička',
        'cardNumber': 'TL999999999',
        'color': '#CC0000'
      },
      {
        'shopName': 'Kaufland',
        'description': 'Rakúska Kartička',
        'cardNumber': 'TL123456789',
        'color': '#CC0000'
      }
    ];
  }
}