import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListStorage {
  static const String _key = 'shopping_list_items';

  static Future<List<Map<String, dynamic>>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? itemsJson = prefs.getString(_key);
    
    if (itemsJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = json.decode(itemsJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> saveItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String itemsJson = json.encode(items);
    await prefs.setString(_key, itemsJson);
  }

  static Future<void> addItem(Map<String, dynamic> item) async {
    final items = await loadItems();
    
    item['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    item['createdAt'] = DateTime.now().toIso8601String();
    item['isCompleted'] = item['isCompleted'] ?? false;
    
    items.add(item);
    await saveItems(items);
  }

  static Future<void> updateItem(Map<String, dynamic> oldItem, Map<String, dynamic> newItem) async {
    final items = await loadItems();
    final index = items.indexWhere((item) => item['id'] == oldItem['id']);
    
    if (index != -1) {
      newItem['id'] = oldItem['id'];
      newItem['createdAt'] = oldItem['createdAt'];
      items[index] = newItem;
      await saveItems(items);
    }
  }

  static Future<void> removeItem(Map<String, dynamic> item) async {
    final items = await loadItems();
    items.removeWhere((i) => i['id'] == item['id']);
    await saveItems(items);
  }

  static Future<void> toggleItemCompletion(Map<String, dynamic> item) async {
    final items = await loadItems();
    final index = items.indexWhere((i) => i['id'] == item['id']);
    
    if (index != -1) {
      items[index]['isCompleted'] = !(items[index]['isCompleted'] ?? false);
      await saveItems(items);
    }
  }

  static Future<void> clearCompleted() async {
    final items = await loadItems();
    items.removeWhere((item) => item['isCompleted'] == true);
    await saveItems(items);
  }

  static Future<void> clearAll() async {
    await saveItems([]);
  }
}