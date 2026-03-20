import '../models/loyalty_card.dart';
import '../services/card_storage.dart';
import 'card_repository.dart';

/// Implementation of CardRepository that delegates to CardStorage.
/// This wrapper allows for dependency injection and easier testing.
class CardRepositoryImpl implements CardRepository {
  @override
  Future<List<LoyaltyCard>> loadCards() async {
    return CardStorage.loadCards();
  }

  @override
  Future<void> addCard(LoyaltyCard card) async {
    await CardStorage.addCard(card);
  }

  @override
  Future<void> updateCard(LoyaltyCard oldCard, LoyaltyCard newCard) async {
    await CardStorage.updateCard(oldCard, newCard);
  }

  @override
  Future<void> deleteCard(LoyaltyCard card) async {
    await CardStorage.removeCard(card);
  }

  @override
  Future<void> toggleFavorite(LoyaltyCard card) async {
    await CardStorage.toggleFavorite(card);
  }

  @override
  Future<void> updateLastUsed(LoyaltyCard card) async {
    await CardStorage.updateLastUsed(card);
  }

  @override
  Future<void> reorderCards(List<LoyaltyCard> cards) async {
    await CardStorage.saveCards(cards);
  }
}
