import 'package:flutter/foundation.dart';
import '../models/shopping_item.dart';
import '../repositories/shopping_repository.dart';

/// Provider for managing shopping list state.
class ShoppingProvider extends ChangeNotifier {
  final ShoppingRepository _repository;

  List<ShoppingItem> _items = [];
  bool _isLoading = false;
  String? _error;

  ShoppingProvider(this._repository) {
    loadItems();
  }

  // Getters
  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get pending (not completed) items
  List<ShoppingItem> get pendingItems =>
      _items.where((item) => !item.isCompleted).toList();

  /// Get completed items
  List<ShoppingItem> get completedItems =>
      _items.where((item) => item.isCompleted).toList();

  /// Load all items from repository
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.loadItems();
    } catch (e) {
      _error = e.toString();
      debugPrint('ShoppingProvider.loadItems error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new item
  Future<void> addItem(ShoppingItem item) async {
    try {
      await _repository.addItem(item);
      await loadItems();
    } catch (e) {
      _error = e.toString();
      debugPrint('ShoppingProvider.addItem error: $e');
      notifyListeners();
    }
  }

  /// Update an existing item
  Future<void> updateItem(ShoppingItem oldItem, ShoppingItem newItem) async {
    try {
      await _repository.updateItem(oldItem, newItem);
      await loadItems();
    } catch (e) {
      _error = e.toString();
      debugPrint('ShoppingProvider.updateItem error: $e');
      notifyListeners();
    }
  }

  /// Delete an item
  Future<void> deleteItem(ShoppingItem item) async {
    try {
      await _repository.deleteItem(item);
      await loadItems();
    } catch (e) {
      _error = e.toString();
      debugPrint('ShoppingProvider.deleteItem error: $e');
      notifyListeners();
    }
  }

  /// Toggle item completion status
  Future<void> toggleCompletion(ShoppingItem item) async {
    try {
      await _repository.toggleCompletion(item);
      await loadItems();
    } catch (e) {
      _error = e.toString();
      debugPrint('ShoppingProvider.toggleCompletion error: $e');
      notifyListeners();
    }
  }

  /// Reorder items
  Future<void> reorderItems(List<ShoppingItem> items) async {
    try {
      _items = items;
      notifyListeners();
      await _repository.reorderItems(items);
    } catch (e) {
      _error = e.toString();
      debugPrint('ShoppingProvider.reorderItems error: $e');
      await loadItems(); // Reload on error
    }
  }

  /// Clear all completed items
  Future<void> clearCompleted() async {
    try {
      await _repository.clearCompleted();
      await loadItems();
    } catch (e) {
      _error = e.toString();
      debugPrint('ShoppingProvider.clearCompleted error: $e');
      notifyListeners();
    }
  }

  /// Clear all items
  Future<void> clearAll() async {
    try {
      await _repository.clearAll();
      await loadItems();
    } catch (e) {
      _error = e.toString();
      debugPrint('ShoppingProvider.clearAll error: $e');
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
