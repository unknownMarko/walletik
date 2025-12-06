import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';
import 'sync_queue_service.dart';
import 'connectivity_service.dart';

class CardStorage {
  static const String _cardsKey = 'loyalty_cards';
  static final FirestoreService _firestoreService = FirestoreService();
  static final ConnectivityService _connectivityService = ConnectivityService();

  static Future<List<Map<String, dynamic>>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();

    if (_firestoreService.isAuthenticated) {
      print('🔥 User is authenticated, loading from Firestore...');
      try {
        final firestoreCards = await _firestoreService.loadCards();
        print('🔥 Loaded ${firestoreCards.length} cards from Firestore');
        await _saveCardsLocally(firestoreCards);
        return firestoreCards;
      } catch (e) {
        print('❌ Firestore load failed: $e');
        final localCards = await _loadCardsLocally();
        print('📱 Loaded ${localCards.length} cards from local storage (fallback)');
        return localCards;
      }
    } else {
      print('📱 User not authenticated, loading from local storage');
      final localCards = await _loadCardsLocally();
      print('📱 Loaded ${localCards.length} cards from local storage');
      return localCards;
    }
  }

  static Future<List<Map<String, dynamic>>> _loadCardsLocally() async {
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

  static Future<void> _saveCardsLocally(List<Map<String, dynamic>> cards) async {
    final prefs = await SharedPreferences.getInstance();

    final cardsToSave = cards.map((card) {
      final cardCopy = Map<String, dynamic>.from(card);

      cardCopy.forEach((key, value) {
        if (value != null && value.toString().contains('Timestamp')) {
          try {
            cardCopy[key] = (value as dynamic).toDate().toIso8601String();
          } catch (e) {
            cardCopy.remove(key);
          }
        }
      });

      return cardCopy;
    }).toList();

    final cardsJson = json.encode(cardsToSave);
    await prefs.setString(_cardsKey, cardsJson);
  }

  static Future<void> saveCards(List<Map<String, dynamic>> cards) async {
    await _saveCardsLocally(cards);
  }

  static Future<void> addCard(Map<String, dynamic> newCard) async {
    newCard['category'] ??= 'Other';
    newCard['isFavorite'] ??= false;
    newCard['lastUsed'] ??= DateTime.now().toIso8601String();
    newCard['createdAt'] ??= DateTime.now().toIso8601String();

    final cards = await _loadCardsLocally();
    cards.add(newCard);
    await _saveCardsLocally(cards);

    if (_firestoreService.isAuthenticated) {
      if (_connectivityService.isOnline) {
        try {
          await _firestoreService.saveCard(newCard);
          print('✅ Card saved to Firestore');
        } catch (e) {
          print('⚠️ Failed to save to Firestore, queuing for sync: $e');
          await SyncQueueService.queueOperation('add', newCard);
        }
      } else {
        print('📴 Offline: Queuing card for sync');
        await SyncQueueService.queueOperation('add', newCard);
      }
    }
  }

  static Future<void> removeCard(Map<String, dynamic> cardToRemove) async {
    final cards = await _loadCardsLocally();
    cards.removeWhere((card) =>
      card['shopName'] == cardToRemove['shopName'] &&
      card['cardNumber'] == cardToRemove['cardNumber']
    );
    await _saveCardsLocally(cards);

    if (_firestoreService.isAuthenticated && cardToRemove['id'] != null) {
      if (_connectivityService.isOnline) {
        try {
          await _firestoreService.deleteCard(cardToRemove['id']);
          print('✅ Card deleted from Firestore');
        } catch (e) {
          print('⚠️ Failed to delete from Firestore, queuing for sync: $e');
          await SyncQueueService.queueOperation('delete', cardToRemove);
        }
      } else {
        print('📴 Offline: Queuing card deletion for sync');
        await SyncQueueService.queueOperation('delete', cardToRemove);
      }
    }
  }

  static Future<void> updateCard(Map<String, dynamic> oldCard, Map<String, dynamic> newCard) async {
    newCard['createdAt'] ??= oldCard['createdAt'] ?? DateTime.now().toIso8601String();
    newCard['lastUsed'] ??= oldCard['lastUsed'] ?? DateTime.now().toIso8601String();
    newCard['id'] = oldCard['id'];

    final cards = await _loadCardsLocally();
    final index = cards.indexWhere((card) =>
      card['shopName'] == oldCard['shopName'] &&
      card['cardNumber'] == oldCard['cardNumber']
    );

    if (index != -1) {
      cards[index] = newCard;
      await _saveCardsLocally(cards);
    }

    if (_firestoreService.isAuthenticated && oldCard['id'] != null) {
      if (_connectivityService.isOnline) {
        try {
          await _firestoreService.saveCard(newCard);
          print('✅ Card updated in Firestore');
        } catch (e) {
          print('⚠️ Failed to update in Firestore, queuing for sync: $e');
          await SyncQueueService.queueOperation('update', newCard);
        }
      } else {
        print('📴 Offline: Queuing card update for sync');
        await SyncQueueService.queueOperation('update', newCard);
      }
    }
  }

  static Future<void> toggleFavorite(Map<String, dynamic> card) async {
    final newFavoriteStatus = !(card['isFavorite'] ?? false);

    if (_firestoreService.isAuthenticated && card['id'] != null) {
      try {
        await _firestoreService.toggleFavorite(card['id'], newFavoriteStatus);
        final cards = await _firestoreService.loadCards();
        await _saveCardsLocally(cards);
        return;
      } catch (e) {
      }
    }

    final cards = await _loadCardsLocally();
    final index = cards.indexWhere((c) =>
      c['shopName'] == card['shopName'] &&
      c['cardNumber'] == card['cardNumber']
    );

    if (index != -1) {
      cards[index]['isFavorite'] = newFavoriteStatus;
      await _saveCardsLocally(cards);
    }
  }

  static Future<void> updateLastUsed(Map<String, dynamic> card) async {
    if (_firestoreService.isAuthenticated && card['id'] != null) {
      try {
        await _firestoreService.updateLastUsed(card['id']);
        final cards = await _firestoreService.loadCards();
        await _saveCardsLocally(cards);
        return;
      } catch (e) {
      }
    }

    final cards = await _loadCardsLocally();
    final index = cards.indexWhere((c) =>
      c['shopName'] == card['shopName'] &&
      c['cardNumber'] == card['cardNumber']
    );

    if (index != -1) {
      cards[index]['lastUsed'] = DateTime.now().toIso8601String();
      await _saveCardsLocally(cards);
    }
  }

  static Future<void> syncLocalCardsToFirestore() async {
    if (!_firestoreService.isAuthenticated) return;

    try {
      final localCards = await _loadCardsLocally();
      if (localCards.isEmpty) return;

      await _firestoreService.syncLocalCardsToFirestore(localCards);

      final firestoreCards = await _firestoreService.loadCards();
      await _saveCardsLocally(firestoreCards);
    } catch (e) {
      print('Failed to sync local cards to Firestore: $e');
    }
  }

  static Future<void> processPendingSync() async {
    print('🔄 Processing pending sync operations...');
    await SyncQueueService.processQueue();

    if (_firestoreService.isAuthenticated) {
      try {
        final cards = await _firestoreService.loadCards();
        await _saveCardsLocally(cards);
        print('✅ Cards reloaded from Firestore after sync');
      } catch (e) {
        print('⚠️ Failed to reload cards after sync: $e');
      }
    }
  }

}