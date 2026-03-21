import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

class ShoppingListStorage {
  static const String _key = 'shopping_list_items';
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<List<ShoppingItem>> loadItems() async {
    final prefs = await _instance;
    final String? itemsJson = prefs.getString(_key);

    if (itemsJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(itemsJson);
      return decoded
          .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ShoppingListStorage.loadItems error: $e');
      return [];
    }
  }

  static Future<void> saveItems(List<ShoppingItem> items) async {
    final prefs = await _instance;
    final String itemsJson = json.encode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_key, itemsJson);
  }

  static Future<void> addItem(ShoppingItem item) async {
    final items = await loadItems();
    final newItem = item.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
    items.add(newItem);
    await saveItems(items);
  }

  static Future<void> updateItem(ShoppingItem oldItem, ShoppingItem newItem) async {
    final items = await loadItems();
    final index = items.indexWhere((item) => item.id == oldItem.id);

    if (index != -1) {
      items[index] = newItem.copyWith(
        id: oldItem.id,
        createdAt: oldItem.createdAt,
      );
      await saveItems(items);
    }
  }

  static Future<void> removeItem(ShoppingItem item) async {
    final items = await loadItems();
    items.removeWhere((i) => i.id == item.id);
    await saveItems(items);
  }

  static Future<void> toggleItemCompletion(ShoppingItem item) async {
    final items = await loadItems();
    final index = items.indexWhere((i) => i.id == item.id);

    if (index != -1) {
      items[index] = items[index].copyWith(isCompleted: !items[index].isCompleted);
      await saveItems(items);
    }
  }

  static Future<void> clearCompleted() async {
    final items = await loadItems();
    items.removeWhere((item) => item.isCompleted);
    await saveItems(items);
  }

  static Future<void> clearAll() async {
    await saveItems([]);
  }
}
