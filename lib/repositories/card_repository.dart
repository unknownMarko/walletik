import '../models/loyalty_card.dart';

/// Abstract repository interface for loyalty card operations.
/// This allows for easy testing and swapping implementations.
abstract class CardRepository {
  /// Load all cards from storage
  Future<List<LoyaltyCard>> loadCards();

  /// Add a new card
  Future<void> addCard(LoyaltyCard card);

  /// Update an existing card
  Future<void> updateCard(LoyaltyCard oldCard, LoyaltyCard newCard);

  /// Delete a card
  Future<void> deleteCard(LoyaltyCard card);

  /// Update last used timestamp
  Future<void> updateLastUsed(LoyaltyCard card);

  /// Reorder cards (save new order)
  Future<void> reorderCards(List<LoyaltyCard> cards);
}
