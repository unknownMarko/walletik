import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loyalty_card.dart';

class CardStorage {
  static const String _cardsKey = 'loyalty_cards';

  static Future<List<LoyaltyCard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString(_cardsKey);

    if (cardsJson == null) {
      return [];
    }

    try {
      final cardsList = json.decode(cardsJson) as List<dynamic>;
      return cardsList
          .map((c) => LoyaltyCard.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCards(List<LoyaltyCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = json.encode(cards.map((c) => c.toJson()).toList());
    await prefs.setString(_cardsKey, cardsJson);
  }

  static Future<void> addCard(LoyaltyCard card) async {
    final cards = await loadCards();
    cards.add(card);
    await saveCards(cards);
  }

  static Future<void> removeCard(LoyaltyCard cardToRemove) async {
    final cards = await loadCards();
    cards.removeWhere((card) =>
      card.shopName == cardToRemove.shopName &&
      card.cardNumber == cardToRemove.cardNumber
    );
    await saveCards(cards);
  }

  static Future<void> updateCard(LoyaltyCard oldCard, LoyaltyCard newCard) async {
    final cardToSave = newCard.copyWith(
      id: oldCard.id,
      createdAt: oldCard.createdAt,
    );

    final cards = await loadCards();
    final index = cards.indexWhere((card) =>
      card.shopName == oldCard.shopName &&
      card.cardNumber == oldCard.cardNumber
    );

    if (index != -1) {
      cards[index] = cardToSave;
      await saveCards(cards);
    }
  }

  static Future<void> toggleFavorite(LoyaltyCard card) async {
    final cards = await loadCards();
    final index = cards.indexWhere((c) =>
      c.shopName == card.shopName &&
      c.cardNumber == card.cardNumber
    );

    if (index != -1) {
      cards[index] = cards[index].copyWith(isFavorite: !card.isFavorite);
      await saveCards(cards);
    }
  }

  static Future<void> updateLastUsed(LoyaltyCard card) async {
    final cards = await loadCards();
    final index = cards.indexWhere((c) =>
      c.shopName == card.shopName &&
      c.cardNumber == card.cardNumber
    );

    if (index != -1) {
      cards[index] = cards[index].copyWith(lastUsed: DateTime.now());
      await saveCards(cards);
    }
  }
}
