import 'package:flutter_test/flutter_test.dart';
import 'package:walletik/models/loyalty_card.dart';

void main() {
  group('LoyaltyCard', () {
    final now = DateTime(2025, 10, 24, 12, 0, 0);

    LoyaltyCard createCard({
      String? id = 'test-id',
      String shopName = 'Tesco',
      String cardNumber = '123456',
      String? description = 'Test card',
      String color = '#0066CC',
      String barcodeFormat = 'code128',
    }) {
      return LoyaltyCard(
        id: id,
        shopName: shopName,
        cardNumber: cardNumber,
        description: description,
        color: color,
        barcodeFormat: barcodeFormat,
        createdAt: now,
        lastUsed: now,
      );
    }

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'abc123',
          'shopName': 'Kaufland',
          'cardNumber': '999888777',
          'description': 'My card',
          'color': '#E74C3C',
          'barcodeFormat': 'qrCode',
          'createdAt': '2025-10-24T12:54:36.334486',
          'lastUsed': '2025-10-24T12:54:36.334461',
        };

        final card = LoyaltyCard.fromJson(json);

        expect(card.id, 'abc123');
        expect(card.shopName, 'Kaufland');
        expect(card.cardNumber, '999888777');
        expect(card.description, 'My card');
        expect(card.color, '#E74C3C');
        expect(card.barcodeFormat, 'qrCode');
        expect(card.createdAt, DateTime(2025, 10, 24, 12, 54, 36, 334, 486));
      });

      test('handles null/missing fields with defaults', () {
        final card = LoyaltyCard.fromJson({});

        expect(card.id, isNull);
        expect(card.shopName, '');
        expect(card.cardNumber, '');
        expect(card.description, isNull);
        expect(card.color, '#0066CC');
        expect(card.barcodeFormat, 'code128');
      });

      test('handles null description', () {
        final card = LoyaltyCard.fromJson({
          'shopName': 'Test',
          'cardNumber': '123',
          'description': null,
        });

        expect(card.description, isNull);
      });

      test('handles invalid date strings', () {
        final card = LoyaltyCard.fromJson({
          'createdAt': 'not-a-date',
          'lastUsed': '',
        });

        // Should fall back to DateTime.now() — just verify it doesn't throw
        expect(card.createdAt, isNotNull);
        expect(card.lastUsed, isNotNull);
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final card = createCard();
        final json = card.toJson();

        expect(json['id'], 'test-id');
        expect(json['shopName'], 'Tesco');
        expect(json['cardNumber'], '123456');
        expect(json['description'], 'Test card');
        expect(json['color'], '#0066CC');
        expect(json['barcodeFormat'], 'code128');
        expect(json['createdAt'], now.toIso8601String());
        expect(json['lastUsed'], now.toIso8601String());
      });

      test('roundtrip fromJson/toJson preserves data', () {
        final original = createCard();
        final restored = LoyaltyCard.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.shopName, original.shopName);
        expect(restored.cardNumber, original.cardNumber);
        expect(restored.description, original.description);
        expect(restored.color, original.color);
        expect(restored.barcodeFormat, original.barcodeFormat);
        expect(restored.createdAt, original.createdAt);
        expect(restored.lastUsed, original.lastUsed);
      });
    });

    group('copyWith', () {
      test('copies with changed fields', () {
        final card = createCard();
        final copied = card.copyWith(shopName: 'Lidl', color: '#FF0000');

        expect(copied.shopName, 'Lidl');
        expect(copied.color, '#FF0000');
        expect(copied.id, card.id); // unchanged
        expect(copied.cardNumber, card.cardNumber); // unchanged
      });

      test('copies with no changes returns equivalent object', () {
        final card = createCard();
        final copied = card.copyWith();

        expect(copied.shopName, card.shopName);
        expect(copied.id, card.id);
      });
    });

    group('equality', () {
      test('same id means equal', () {
        final a = createCard(id: 'same-id', shopName: 'A');
        final b = createCard(id: 'same-id', shopName: 'B');

        expect(a, equals(b));
      });

      test('different id means not equal', () {
        final a = createCard(id: 'id-1');
        final b = createCard(id: 'id-2');

        expect(a, isNot(equals(b)));
      });

      test('null ids fall back to shopName+cardNumber comparison', () {
        final a = createCard(id: null, shopName: 'X', cardNumber: '1');
        final b = createCard(id: null, shopName: 'X', cardNumber: '1');

        expect(a, equals(b));
      });

      test('null ids with different shopName are not equal', () {
        final a = createCard(id: null, shopName: 'X', cardNumber: '1');
        final b = createCard(id: null, shopName: 'Y', cardNumber: '1');

        expect(a, isNot(equals(b)));
      });

      test('identical returns true', () {
        final card = createCard();
        expect(card == card, isTrue);
      });
    });

    group('hashCode', () {
      test('equal objects have same hashCode', () {
        final a = createCard(id: 'same');
        final b = createCard(id: 'same');

        expect(a.hashCode, equals(b.hashCode));
      });

      test('null id uses shopName+cardNumber hash', () {
        final card = createCard(id: null);
        expect(card.hashCode, isNonZero);
      });
    });
  });
}
