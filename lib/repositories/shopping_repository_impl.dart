import '../models/shopping_item.dart';
import '../services/shopping_list_storage.dart';
import 'shopping_repository.dart';

/// Implementation of ShoppingRepository that delegates to ShoppingListStorage.
class ShoppingRepositoryImpl implements ShoppingRepository {
  @override
  Future<List<ShoppingItem>> loadItems() async {
    return ShoppingListStorage.loadItems();
  }

  @override
  Future<void> addItem(ShoppingItem item) async {
    await ShoppingListStorage.addItem(item);
  }

  @override
  Future<void> updateItem(ShoppingItem oldItem, ShoppingItem newItem) async {
    await ShoppingListStorage.updateItem(oldItem, newItem);
  }

  @override
  Future<void> deleteItem(ShoppingItem item) async {
    await ShoppingListStorage.removeItem(item);
  }

  @override
  Future<void> toggleCompletion(ShoppingItem item) async {
    await ShoppingListStorage.toggleItemCompletion(item);
  }

  @override
  Future<void> reorderItems(List<ShoppingItem> items) async {
    await ShoppingListStorage.saveItems(items);
  }

  @override
  Future<void> clearCompleted() async {
    await ShoppingListStorage.clearCompleted();
  }

  @override
  Future<void> clearAll() async {
    await ShoppingListStorage.clearAll();
  }
}
