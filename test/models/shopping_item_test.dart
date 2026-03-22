import 'package:flutter_test/flutter_test.dart';
import 'package:walletik/models/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    final now = DateTime(2025, 11, 1, 10, 0, 0);

    ShoppingItem createItem({
      String id = 'item-1',
      String name = 'Milk',
      int quantity = 1,
      String category = 'Groceries',
      String? notes,
      bool isCompleted = false,
    }) {
      return ShoppingItem(
        id: id,
        name: name,
        quantity: quantity,
        category: category,
        notes: notes,
        isCompleted: isCompleted,
        createdAt: now,
      );
    }

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'abc',
          'name': 'Bread',
          'quantity': 3,
          'category': 'Groceries',
          'notes': 'Whole wheat',
          'isCompleted': true,
          'createdAt': '2025-11-01T10:00:00.000000',
        };

        final item = ShoppingItem.fromJson(json);

        expect(item.id, 'abc');
        expect(item.name, 'Bread');
        expect(item.quantity, 3);
        expect(item.category, 'Groceries');
        expect(item.notes, 'Whole wheat');
        expect(item.isCompleted, true);
      });

      test('handles null/missing fields with defaults', () {
        final item = ShoppingItem.fromJson({});

        expect(item.name, '');
        expect(item.quantity, 1);
        expect(item.category, 'Groceries');
        expect(item.notes, isNull);
        expect(item.isCompleted, false);
      });

      test('generates id when missing', () {
        final item = ShoppingItem.fromJson({'name': 'Eggs'});
        expect(item.id, isNotEmpty);
      });

      test('handles invalid date', () {
        final item = ShoppingItem.fromJson({
          'name': 'Test',
          'createdAt': 'invalid',
        });
        expect(item.createdAt, isNotNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final item = createItem(notes: 'Fresh');
        final json = item.toJson();

        expect(json['id'], 'item-1');
        expect(json['name'], 'Milk');
        expect(json['quantity'], 1);
        expect(json['category'], 'Groceries');
        expect(json['notes'], 'Fresh');
        expect(json['isCompleted'], false);
        expect(json['createdAt'], now.toIso8601String());
      });

      test('roundtrip fromJson/toJson preserves data', () {
        final original = createItem(
          notes: 'Test note',
          quantity: 5,
          isCompleted: true,
        );
        final restored = ShoppingItem.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.quantity, original.quantity);
        expect(restored.category, original.category);
        expect(restored.notes, original.notes);
        expect(restored.isCompleted, original.isCompleted);
      });
    });

    group('copyWith', () {
      test('copies with changed fields', () {
        final item = createItem();
        final copied = item.copyWith(name: 'Eggs', quantity: 12);

        expect(copied.name, 'Eggs');
        expect(copied.quantity, 12);
        expect(copied.id, item.id);
        expect(copied.isCompleted, item.isCompleted);
      });

      test('toggle completion via copyWith', () {
        final item = createItem(isCompleted: false);
        final toggled = item.copyWith(isCompleted: true);

        expect(toggled.isCompleted, true);
        expect(toggled.name, item.name);
      });
    });

    group('equality', () {
      test('same fields means equal', () {
        final a = createItem();
        final b = createItem();

        expect(a, equals(b));
      });

      test('different isCompleted means not equal', () {
        final a = createItem(isCompleted: false);
        final b = createItem(isCompleted: true);

        expect(a, isNot(equals(b)));
      });

      test('different name means not equal', () {
        final a = createItem(name: 'Milk');
        final b = createItem(name: 'Bread');

        expect(a, isNot(equals(b)));
      });

      test('different quantity means not equal', () {
        final a = createItem(quantity: 1);
        final b = createItem(quantity: 2);

        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('equal objects have same hashCode', () {
        final a = createItem();
        final b = createItem();

        expect(a.hashCode, equals(b.hashCode));
      });

      test('different objects likely have different hashCode', () {
        final a = createItem(name: 'Milk');
        final b = createItem(name: 'Bread');

        expect(a.hashCode, isNot(equals(b.hashCode)));
      });
    });
  });
}
