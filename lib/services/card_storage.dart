import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loyalty_card.dart';

class CardStorage {
  static const String _cardsKey = 'loyalty_cards';
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<List<LoyaltyCard>> loadCards() async {
    final prefs = await _instance;
    final cardsJson = prefs.getString(_cardsKey);

    if (cardsJson == null) {
      return [];
    }

    try {
      final cardsList = json.decode(cardsJson) as List<dynamic>;
      return cardsList
          .map((c) => LoyaltyCard.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CardStorage.loadCards error: $e');
      return [];
    }
  }

  static Future<void> saveCards(List<LoyaltyCard> cards) async {
    final prefs = await _instance;
    final cardsJson = json.encode(cards.map((c) => c.toJson()).toList());
    await prefs.setString(_cardsKey, cardsJson);
  }

  static Future<void> addCard(LoyaltyCard card) async {
    final cardToSave = card.id == null
        ? card.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
        : card;
    final cards = await loadCards();
    cards.add(cardToSave);
    await saveCards(cards);
  }

  static Future<void> removeCard(LoyaltyCard cardToRemove) async {
    final cards = await loadCards();
    cards.removeWhere((card) => cardToRemove.id != null
        ? card.id == cardToRemove.id
        : card.shopName == cardToRemove.shopName &&
            card.cardNumber == cardToRemove.cardNumber);
    await saveCards(cards);
  }

  static Future<void> updateCard(LoyaltyCard oldCard, LoyaltyCard newCard) async {
    final cardToSave = newCard.copyWith(
      id: oldCard.id,
      createdAt: oldCard.createdAt,
    );

    final cards = await loadCards();
    final index = cards.indexWhere((card) => oldCard.id != null
        ? card.id == oldCard.id
        : card.shopName == oldCard.shopName &&
            card.cardNumber == oldCard.cardNumber);

    if (index != -1) {
      cards[index] = cardToSave;
      await saveCards(cards);
    }
  }

  // Quick Access Cards (3 slots: primary, secondary, third)
  static const String _quickAccessKey = 'quick_access_cards';

  static String _cardKey(LoyaltyCard card) =>
      card.id ?? '${card.shopName}::${card.cardNumber}';

  static Future<List<String?>> loadQuickAccessKeys() async {
    final prefs = await _instance;
    final stored = prefs.getString(_quickAccessKey);
    if (stored == null) return [null, null, null];

    try {
      final list = json.decode(stored) as List<dynamic>;
      return List.generate(3, (i) => i < list.length ? list[i] as String? : null);
    } catch (e) {
      debugPrint('CardStorage.loadQuickAccessKeys error: $e');
      return [null, null, null];
    }
  }

  static Future<void> saveQuickAccessKeys(List<String?> keys) async {
    final prefs = await _instance;
    await prefs.setString(_quickAccessKey, json.encode(keys));
  }

  static Future<void> setQuickAccessSlot(int slot, LoyaltyCard? card) async {
    final keys = await loadQuickAccessKeys();
    keys[slot] = card != null ? _cardKey(card) : null;
    await saveQuickAccessKeys(keys);
  }

  static LoyaltyCard? findCardByKey(List<LoyaltyCard> cards, String? key) {
    if (key == null) return null;
    // Try id-based match first (new format)
    try {
      return cards.firstWhere((c) => c.id == key);
    } catch (_) {
      // Fallback: composite key shopName::cardNumber (backward compat)
      final parts = key.split('::');
      if (parts.length != 2) return null;
      try {
        return cards.firstWhere(
          (c) => c.shopName == parts[0] && c.cardNumber == parts[1],
        );
      } catch (_) {
        return null;
      }
    }
  }

  static Future<void> updateLastUsed(LoyaltyCard card) async {
    final cards = await loadCards();
    final index = cards.indexWhere((c) => card.id != null
        ? c.id == card.id
        : c.shopName == card.shopName &&
            c.cardNumber == card.cardNumber);

    if (index != -1) {
      cards[index] = cards[index].copyWith(lastUsed: DateTime.now());
      await saveCards(cards);
    }
  }
}
