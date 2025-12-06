import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's cards collection reference
  CollectionReference? get _userCardsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('cards');
  }

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Save a card to Firestore
  Future<void> saveCard(Map<String, dynamic> card) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to save cards');
    }

    try {
      // Generate a unique ID for the card if it doesn't have one
      final cardId = card['id'] ?? _userCardsCollection!.doc().id;
      card['id'] = cardId;
      card['updatedAt'] = FieldValue.serverTimestamp();

      await _userCardsCollection!.doc(cardId).set(card, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save card to Firestore: $e');
    }
  }

  // Load all cards from Firestore
  Future<List<Map<String, dynamic>>> loadCards() async {
    if (!isAuthenticated) {
      print('🔥 Firestore: User not authenticated');
      return [];
    }

    try {
      print('🔥 Firestore: Fetching cards from collection...');
      final snapshot = await _userCardsCollection!.get();
      print('🔥 Firestore: Got ${snapshot.docs.length} documents');

      final cards = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        print('🔥 Firestore: Card - ${data['shopName']} (${data['cardNumber']})');
        return data;
      }).toList();

      return cards;
    } catch (e) {
      print('❌ Firestore: Error loading cards - $e');
      throw Exception('Failed to load cards from Firestore: $e');
    }
  }

  // Get real-time cards stream
  Stream<List<Map<String, dynamic>>> cardsStream() {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    return _userCardsCollection!
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Update a card in Firestore
  Future<void> updateCard(String cardId, Map<String, dynamic> updatedCard) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update cards');
    }

    try {
      updatedCard['updatedAt'] = FieldValue.serverTimestamp();
      await _userCardsCollection!.doc(cardId).update(updatedCard);
    } catch (e) {
      throw Exception('Failed to update card in Firestore: $e');
    }
  }

  // Delete a card from Firestore
  Future<void> deleteCard(String cardId) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to delete cards');
    }

    try {
      await _userCardsCollection!.doc(cardId).delete();
    } catch (e) {
      throw Exception('Failed to delete card from Firestore: $e');
    }
  }

  // Sync local cards to Firestore (one-time migration)
  Future<void> syncLocalCardsToFirestore(List<Map<String, dynamic>> localCards) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to sync cards');
    }

    try {
      final batch = _firestore.batch();

      for (var card in localCards) {
        // Generate ID if not present
        final cardId = card['id'] ?? _userCardsCollection!.doc().id;
        card['id'] = cardId;

        // Add timestamps if not present
        card['createdAt'] ??= FieldValue.serverTimestamp();
        card['updatedAt'] = FieldValue.serverTimestamp();

        final docRef = _userCardsCollection!.doc(cardId);
        batch.set(docRef, card, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync local cards to Firestore: $e');
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String cardId, bool isFavorite) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update cards');
    }

    try {
      await _userCardsCollection!.doc(cardId).update({
        'isFavorite': isFavorite,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Update last used timestamp
  Future<void> updateLastUsed(String cardId) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update cards');
    }

    try {
      await _userCardsCollection!.doc(cardId).update({
        'lastUsed': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update last used: $e');
    }
  }

  // Delete all cards (for account deletion)
  Future<void> deleteAllCards() async {
    if (!isAuthenticated) {
      return;
    }

    try {
      final snapshot = await _userCardsCollection!.get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all cards: $e');
    }
  }
}
