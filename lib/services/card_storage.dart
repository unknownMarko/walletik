import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CardStorage {
  static const String _cardsKey = 'loyalty_cards';
  
  static Future<List<Map<String, dynamic>>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString(_cardsKey);
    
    if (cardsJson == null) {
      // Return empty list if no data exists
      return [];
    }
    
    try {
      final List<dynamic> cardsList = json.decode(cardsJson);
      return cardsList.cast<Map<String, dynamic>>();
    } catch (e) {
      // Return empty list if parsing fails
      return [];
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
  
}