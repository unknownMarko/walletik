import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CardStorage {
  static const String _cardsKey = 'loyalty_cards';
  
  static Future<List<Map<String, dynamic>>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString(_cardsKey);
    
    if (cardsJson == null) {
      return [];
    }
    
    try {
      final cardsList = json.decode(cardsJson) as List<dynamic>;
      return cardsList.cast<Map<String, dynamic>>();
    } catch (_) {
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
  
  static Future<void> updateCard(Map<String, dynamic> oldCard, Map<String, dynamic> newCard) async {
    final cards = await loadCards();
    final index = cards.indexWhere((card) => 
      card['shopName'] == oldCard['shopName'] && 
      card['cardNumber'] == oldCard['cardNumber']
    );
    
    if (index != -1) {
      cards[index] = newCard;
      await saveCards(cards);
    }
  }
  
}