import 'package:walletik/models/loyalty_card.dart';
import 'package:walletik/models/shopping_item.dart';
import 'package:walletik/repositories/card_repository.dart';
import 'package:walletik/repositories/shopping_repository.dart';

/// In-memory mock implementation of CardRepository for testing.
class MockCardRepository implements CardRepository {
  List<LoyaltyCard> _cards = [];

  @override
  Future<List<LoyaltyCard>> loadCards() async => List.from(_cards);

  @override
  Future<void> addCard(LoyaltyCard card) async {
    _cards.add(card.copyWith(id: card.id ?? DateTime.now().millisecondsSinceEpoch.toString()));
  }

  @override
  Future<void> updateCard(LoyaltyCard oldCard, LoyaltyCard newCard) async {
    final index = _cards.indexWhere((c) => c.id == oldCard.id);
    if (index != -1) _cards[index] = newCard;
  }

  @override
  Future<void> deleteCard(LoyaltyCard card) async {
    _cards.removeWhere((c) => c.id == card.id);
  }

  @override
  Future<void> updateLastUsed(LoyaltyCard card) async {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(lastUsed: DateTime.now());
    }
  }

  @override
  Future<void> reorderCards(List<LoyaltyCard> cards) async {
    _cards = List.from(cards);
  }
}

/// In-memory mock implementation of ShoppingRepository for testing.
class MockShoppingRepository implements ShoppingRepository {
  List<ShoppingItem> _items = [];

  @override
  Future<List<ShoppingItem>> loadItems() async => List.from(_items);

  @override
  Future<void> addItem(ShoppingItem item) async {
    _items.add(item.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  @override
  Future<void> updateItem(ShoppingItem oldItem, ShoppingItem newItem) async {
    final index = _items.indexWhere((i) => i.id == oldItem.id);
    if (index != -1) _items[index] = newItem;
  }

  @override
  Future<void> deleteItem(ShoppingItem item) async {
    _items.removeWhere((i) => i.id == item.id);
  }

  @override
  Future<void> toggleCompletion(ShoppingItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isCompleted: !_items[index].isCompleted);
    }
  }

  @override
  Future<void> reorderItems(List<ShoppingItem> items) async {
    _items = List.from(items);
  }

  @override
  Future<void> clearCompleted() async {
    _items.removeWhere((i) => i.isCompleted);
  }

  @override
  Future<void> clearAll() async {
    _items.clear();
  }
}
