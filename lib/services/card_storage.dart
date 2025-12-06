import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loyalty_card.dart';
import 'firestore_service.dart';
import 'sync_queue_service.dart';
import 'connectivity_service.dart';

class CardStorage {
  static const String _cardsKey = 'loyalty_cards';
  static final FirestoreService _firestoreService = FirestoreService();
  static final ConnectivityService _connectivityService = ConnectivityService();

  static Future<List<LoyaltyCard>> loadCards() async {
    if (_firestoreService.isAuthenticated) {
      debugPrint('User is authenticated, loading from Firestore...');
      try {
        final firestoreCards = await _firestoreService.loadCards();
        final cards = firestoreCards.map((c) => LoyaltyCard.fromJson(c)).toList();
        debugPrint('Loaded ${cards.length} cards from Firestore');
        await _saveCardsLocally(cards);
        return cards;
      } catch (e) {
        debugPrint('Firestore load failed: $e');
        final localCards = await _loadCardsLocally();
        debugPrint('Loaded ${localCards.length} cards from local storage (fallback)');
        return localCards;
      }
    } else {
      debugPrint('User not authenticated, loading from local storage');
      final localCards = await _loadCardsLocally();
      debugPrint('Loaded ${localCards.length} cards from local storage');
      return localCards;
    }
  }

  static Future<List<LoyaltyCard>> _loadCardsLocally() async {
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

  static Future<void> _saveCardsLocally(List<LoyaltyCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = json.encode(cards.map((c) => c.toJson()).toList());
    await prefs.setString(_cardsKey, cardsJson);
  }

  static Future<void> saveCards(List<LoyaltyCard> cards) async {
    await _saveCardsLocally(cards);
  }

  static Future<void> addCard(LoyaltyCard card) async {
    final cards = await _loadCardsLocally();
    cards.add(card);
    await _saveCardsLocally(cards);

    if (_firestoreService.isAuthenticated) {
      if (_connectivityService.isOnline) {
        try {
          await _firestoreService.saveCard(card.toJson());
          debugPrint('Card saved to Firestore');
        } catch (e) {
          debugPrint('Failed to save to Firestore, queuing for sync: $e');
          await SyncQueueService.queueOperation('add', card.toJson());
        }
      } else {
        debugPrint('Offline: Queuing card for sync');
        await SyncQueueService.queueOperation('add', card.toJson());
      }
    }
  }

  static Future<void> removeCard(LoyaltyCard cardToRemove) async {
    final cards = await _loadCardsLocally();
    cards.removeWhere((card) =>
      card.shopName == cardToRemove.shopName &&
      card.cardNumber == cardToRemove.cardNumber
    );
    await _saveCardsLocally(cards);

    if (_firestoreService.isAuthenticated && cardToRemove.id != null) {
      if (_connectivityService.isOnline) {
        try {
          await _firestoreService.deleteCard(cardToRemove.id!);
          debugPrint('Card deleted from Firestore');
        } catch (e) {
          debugPrint('Failed to delete from Firestore, queuing for sync: $e');
          await SyncQueueService.queueOperation('delete', cardToRemove.toJson());
        }
      } else {
        debugPrint('Offline: Queuing card deletion for sync');
        await SyncQueueService.queueOperation('delete', cardToRemove.toJson());
      }
    }
  }

  static Future<void> updateCard(LoyaltyCard oldCard, LoyaltyCard newCard) async {
    final cardToSave = newCard.copyWith(
      id: oldCard.id,
      createdAt: oldCard.createdAt,
    );

    final cards = await _loadCardsLocally();
    final index = cards.indexWhere((card) =>
      card.shopName == oldCard.shopName &&
      card.cardNumber == oldCard.cardNumber
    );

    if (index != -1) {
      cards[index] = cardToSave;
      await _saveCardsLocally(cards);
    }

    if (_firestoreService.isAuthenticated && oldCard.id != null) {
      if (_connectivityService.isOnline) {
        try {
          await _firestoreService.saveCard(cardToSave.toJson());
          debugPrint('Card updated in Firestore');
        } catch (e) {
          debugPrint('Failed to update in Firestore, queuing for sync: $e');
          await SyncQueueService.queueOperation('update', cardToSave.toJson());
        }
      } else {
        debugPrint('Offline: Queuing card update for sync');
        await SyncQueueService.queueOperation('update', cardToSave.toJson());
      }
    }
  }

  static Future<void> toggleFavorite(LoyaltyCard card) async {
    final newFavoriteStatus = !card.isFavorite;

    if (_firestoreService.isAuthenticated && card.id != null) {
      try {
        await _firestoreService.toggleFavorite(card.id!, newFavoriteStatus);
        final firestoreCards = await _firestoreService.loadCards();
        final cards = firestoreCards.map((c) => LoyaltyCard.fromJson(c)).toList();
        await _saveCardsLocally(cards);
        return;
      } catch (e) {
        debugPrint('Failed to toggle favorite in Firestore: $e');
      }
    }

    final cards = await _loadCardsLocally();
    final index = cards.indexWhere((c) =>
      c.shopName == card.shopName &&
      c.cardNumber == card.cardNumber
    );

    if (index != -1) {
      cards[index] = cards[index].copyWith(isFavorite: newFavoriteStatus);
      await _saveCardsLocally(cards);
    }
  }

  static Future<void> updateLastUsed(LoyaltyCard card) async {
    if (_firestoreService.isAuthenticated && card.id != null) {
      try {
        await _firestoreService.updateLastUsed(card.id!);
        final firestoreCards = await _firestoreService.loadCards();
        final cards = firestoreCards.map((c) => LoyaltyCard.fromJson(c)).toList();
        await _saveCardsLocally(cards);
        return;
      } catch (e) {
        debugPrint('Failed to update lastUsed in Firestore: $e');
      }
    }

    final cards = await _loadCardsLocally();
    final index = cards.indexWhere((c) =>
      c.shopName == card.shopName &&
      c.cardNumber == card.cardNumber
    );

    if (index != -1) {
      cards[index] = cards[index].copyWith(lastUsed: DateTime.now());
      await _saveCardsLocally(cards);
    }
  }

  static Future<void> syncLocalCardsToFirestore() async {
    if (!_firestoreService.isAuthenticated) return;

    try {
      final localCards = await _loadCardsLocally();
      if (localCards.isEmpty) return;

      await _firestoreService.syncLocalCardsToFirestore(
        localCards.map((c) => c.toJson()).toList()
      );

      final firestoreCards = await _firestoreService.loadCards();
      final cards = firestoreCards.map((c) => LoyaltyCard.fromJson(c)).toList();
      await _saveCardsLocally(cards);
    } catch (e) {
      debugPrint('Failed to sync local cards to Firestore: $e');
    }
  }

  static Future<void> processPendingSync() async {
    debugPrint('Processing pending sync operations...');
    final hadOperations = await SyncQueueService.processQueue();

    // Only reload from Firestore if we actually synced something
    if (hadOperations && _firestoreService.isAuthenticated) {
      try {
        final firestoreCards = await _firestoreService.loadCards();
        final cards = firestoreCards.map((c) => LoyaltyCard.fromJson(c)).toList();
        await _saveCardsLocally(cards);
        debugPrint('Cards reloaded from Firestore after sync');
      } catch (e) {
        debugPrint('Failed to reload cards after sync: $e');
      }
    }
  }
}
