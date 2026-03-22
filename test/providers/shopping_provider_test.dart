import 'package:flutter_test/flutter_test.dart';
import 'package:walletik/models/shopping_item.dart';
import 'package:walletik/providers/shopping_provider.dart';
import '../helpers/mock_repositories.dart';

void main() {
  group('ShoppingProvider', () {
    late MockShoppingRepository mockRepo;
    late ShoppingProvider provider;

    setUp(() {
      mockRepo = MockShoppingRepository();
      provider = ShoppingProvider(mockRepo);
    });

    ShoppingItem createItem({
      String id = 'item-1',
      String name = 'Milk',
      bool isCompleted = false,
    }) {
      return ShoppingItem(
        id: id,
        name: name,
        isCompleted: isCompleted,
        createdAt: DateTime.now(),
      );
    }

    test('starts with empty list after loading', () async {
      // Wait for constructor's loadItems() to complete
      await Future.delayed(Duration.zero);

      expect(provider.items, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('addItem adds item and reloads', () async {
      await Future.delayed(Duration.zero);
      await provider.addItem(createItem(name: 'Bread'));

      expect(provider.items.length, 1);
      expect(provider.items.first.name, 'Bread');
    });

    test('deleteItem removes item', () async {
      await Future.delayed(Duration.zero);
      final item = createItem();
      await provider.addItem(item);
      expect(provider.items.length, 1);

      await provider.deleteItem(provider.items.first);
      expect(provider.items, isEmpty);
    });

    test('toggleCompletion flips isCompleted', () async {
      await Future.delayed(Duration.zero);
      await provider.addItem(createItem(isCompleted: false));

      final item = provider.items.first;
      expect(item.isCompleted, false);

      await provider.toggleCompletion(item);
      expect(provider.items.first.isCompleted, true);

      await provider.toggleCompletion(provider.items.first);
      expect(provider.items.first.isCompleted, false);
    });

    test('pendingItems and completedItems are derived correctly', () async {
      await Future.delayed(Duration.zero);
      await provider.addItem(createItem(id: '1', name: 'Milk', isCompleted: false));
      await provider.addItem(createItem(id: '2', name: 'Bread', isCompleted: false));

      // Toggle one as completed
      await provider.toggleCompletion(provider.items.first);

      expect(provider.pendingItems.length, 1);
      expect(provider.completedItems.length, 1);
      expect(provider.completedItems.first.name, provider.items.first.name);
    });

    test('clearCompleted removes only completed items', () async {
      await Future.delayed(Duration.zero);
      await provider.addItem(createItem(id: '1', name: 'Milk'));
      await provider.addItem(createItem(id: '2', name: 'Bread'));

      await provider.toggleCompletion(provider.items.first);
      await provider.clearCompleted();

      expect(provider.items.length, 1);
      expect(provider.items.first.isCompleted, false);
    });

    test('clearAll removes everything', () async {
      await Future.delayed(Duration.zero);
      await provider.addItem(createItem(id: '1', name: 'Milk'));
      await provider.addItem(createItem(id: '2', name: 'Bread'));

      await provider.clearAll();
      expect(provider.items, isEmpty);
    });

    test('reorderItems changes order', () async {
      await Future.delayed(Duration.zero);
      await provider.addItem(createItem(id: '1', name: 'First'));
      await provider.addItem(createItem(id: '2', name: 'Second'));

      final reordered = provider.items.reversed.toList();
      await provider.reorderItems(reordered);

      expect(provider.items.first.name, 'Second');
      expect(provider.items.last.name, 'First');
    });

    test('notifies listeners on changes', () async {
      await Future.delayed(Duration.zero);
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.addItem(createItem());

      expect(notifyCount, greaterThan(0));
    });

    test('clearError resets error state', () async {
      await Future.delayed(Duration.zero);
      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
