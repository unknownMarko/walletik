import 'package:flutter/foundation.dart';
import '../models/loyalty_card.dart';
import '../repositories/card_repository.dart';
import '../services/card_storage.dart';

/// Provider for managing loyalty card state.
/// Exposes loading/error states and card operations to the UI.
class CardProvider extends ChangeNotifier {
  final CardRepository _repository;

  List<LoyaltyCard> _cards = [];
  List<LoyaltyCard> _recentCards = [];
  List<String?> _quickAccessKeys = [null, null, null];
  bool _isLoading = false;
  String? _error;

  CardProvider(this._repository) {
    loadCards();
  }

  // Getters
  List<LoyaltyCard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get recent cards (first 3) — cached
  List<LoyaltyCard> get recentCards => _recentCards;

  /// Quick access cards (3 slots)
  LoyaltyCard? get primaryCard =>
      CardStorage.findCardByKey(_cards, _quickAccessKeys[0]);
  LoyaltyCard? get secondaryCard =>
      CardStorage.findCardByKey(_cards, _quickAccessKeys[1]);
  LoyaltyCard? get thirdCard =>
      CardStorage.findCardByKey(_cards, _quickAccessKeys[2]);

  void _updateDerivedLists() {
    _recentCards = _cards.take(3).toList();
  }

  /// Load all cards from repository
  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cards = await _repository.loadCards();
      _quickAccessKeys = await CardStorage.loadQuickAccessKeys();
      _updateDerivedLists();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set a quick access card slot (0=primary, 1=secondary, 2=third)
  Future<void> setQuickAccessCard(int slot, LoyaltyCard? card) async {
    try {
      await CardStorage.setQuickAccessSlot(slot, card);
      _quickAccessKeys = await CardStorage.loadQuickAccessKeys();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
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
      notifyListeners();
    }
  }

  /// Update last used timestamp
  Future<void> updateLastUsed(LoyaltyCard card) async {
    try {
      await _repository.updateLastUsed(card);
    } catch (_) {
      // Silent failure for non-critical operation
    }
  }

  /// Reorder cards
  Future<void> reorderCards(List<LoyaltyCard> cards) async {
    try {
      _cards = cards;
      _updateDerivedLists();
      notifyListeners();
      await _repository.reorderCards(cards);
    } catch (e) {
      _error = e.toString();
      await loadCards(); // Reload on error
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
