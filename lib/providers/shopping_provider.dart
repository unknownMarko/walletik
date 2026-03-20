import 'package:flutter/foundation.dart';
import '../models/shopping_item.dart';
import '../repositories/shopping_repository.dart';

/// Provider for managing shopping list state.
class ShoppingProvider extends ChangeNotifier {
  final ShoppingRepository _repository;

  List<ShoppingItem> _items = [];
  List<ShoppingItem> _pendingItems = [];
  List<ShoppingItem> _completedItems = [];
  bool _isLoading = false;
  String? _error;

  ShoppingProvider(this._repository) {
    loadItems();
  }

  // Getters
  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get pending (not completed) items — cached
  List<ShoppingItem> get pendingItems => _pendingItems;

  /// Get completed items — cached
  List<ShoppingItem> get completedItems => _completedItems;

  void _updateDerivedLists() {
    _pendingItems = _items.where((item) => !item.isCompleted).toList();
    _completedItems = _items.where((item) => item.isCompleted).toList();
  }

  /// Load all items from repository
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.loadItems();
      _updateDerivedLists();
    } catch (e) {
      _error = e.toString();
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
      notifyListeners();
    }
  }

  /// Reorder items
  Future<void> reorderItems(List<ShoppingItem> items) async {
    try {
      _items = items;
      _updateDerivedLists();
      notifyListeners();
      await _repository.reorderItems(items);
    } catch (e) {
      _error = e.toString();
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
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
