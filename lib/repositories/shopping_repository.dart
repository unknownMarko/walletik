import '../models/shopping_item.dart';

/// Abstract repository interface for shopping list operations.
abstract class ShoppingRepository {
  /// Load all shopping items
  Future<List<ShoppingItem>> loadItems();

  /// Add a new item
  Future<void> addItem(ShoppingItem item);

  /// Update an existing item
  Future<void> updateItem(ShoppingItem oldItem, ShoppingItem newItem);

  /// Delete an item
  Future<void> deleteItem(ShoppingItem item);

  /// Toggle item completion status
  Future<void> toggleCompletion(ShoppingItem item);

  /// Reorder items (save new order)
  Future<void> reorderItems(List<ShoppingItem> items);

  /// Clear all completed items
  Future<void> clearCompleted();

  /// Clear all items
  Future<void> clearAll();
}
