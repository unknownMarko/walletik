import 'package:flutter/foundation.dart';
import '../models/loyalty_card.dart';
import '../repositories/card_repository.dart';

/// Provider for managing loyalty card state.
/// Exposes loading/error states and card operations to the UI.
class CardProvider extends ChangeNotifier {
  final CardRepository _repository;

  List<LoyaltyCard> _cards = [];
  bool _isLoading = false;
  String? _error;

  CardProvider(this._repository) {
    loadCards();
  }

  // Getters
  List<LoyaltyCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get recent cards (first 3)
  List<LoyaltyCard> get recentCards => _cards.take(3).toList();

  /// Get favorite cards (first 3)
  List<LoyaltyCard> get favoriteCards =>
      _cards.where((card) => card.isFavorite).take(3).toList();

  /// Load all cards from repository
  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cards = await _repository.loadCards();
    } catch (e) {
      _error = e.toString();
      debugPrint('CardProvider.loadCards error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new card
  Future<void> addCard(LoyaltyCard card) async {
    try {
      await _repository.addCard(card);
      await loadCards();
    } catch (e) {
      _error = e.toString();
      debugPrint('CardProvider.addCard error: $e');
      notifyListeners();
    }
  }

  /// Update an existing card
  Future<void> updateCard(LoyaltyCard oldCard, LoyaltyCard newCard) async {
    try {
      await _repository.updateCard(oldCard, newCard);
      await loadCards();
    } catch (e) {
      _error = e.toString();
      debugPrint('CardProvider.updateCard error: $e');
      notifyListeners();
    }
  }

  /// Delete a card
  Future<void> deleteCard(LoyaltyCard card) async {
    try {
      await _repository.deleteCard(card);
      await loadCards();
    } catch (e) {
      _error = e.toString();
      debugPrint('CardProvider.deleteCard error: $e');
      notifyListeners();
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(LoyaltyCard card) async {
    try {
      await _repository.toggleFavorite(card);
      await loadCards();
    } catch (e) {
      _error = e.toString();
      debugPrint('CardProvider.toggleFavorite error: $e');
      notifyListeners();
    }
  }

  /// Update last used timestamp
  Future<void> updateLastUsed(LoyaltyCard card) async {
    try {
      await _repository.updateLastUsed(card);
      // Don't reload all cards for this minor update
    } catch (e) {
      debugPrint('CardProvider.updateLastUsed error: $e');
    }
  }

  /// Reorder cards
  Future<void> reorderCards(List<LoyaltyCard> cards) async {
    try {
      _cards = cards;
      notifyListeners();
      await _repository.reorderCards(cards);
    } catch (e) {
      _error = e.toString();
      debugPrint('CardProvider.reorderCards error: $e');
      await loadCards(); // Reload on error
    }
  }

  /// Sync pending offline operations
  Future<void> syncPendingOperations() async {
    try {
      await _repository.syncPendingOperations();
      await loadCards();
    } catch (e) {
      debugPrint('CardProvider.syncPendingOperations error: $e');
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
