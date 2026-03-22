import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/loyalty_card.dart';
import '../models/shopping_item.dart';
import 'card_storage.dart';
import 'shopping_list_storage.dart';

class DataExportService {
  static const int _version = 1;

  /// Export all data to JSON and open share sheet.
  static Future<void> exportData() async {
    final cards = await CardStorage.loadCards();
    final items = await ShoppingListStorage.loadItems();
    final quickAccessKeys = await CardStorage.loadQuickAccessKeys();

    final data = {
      'version': _version,
      'exportedAt': DateTime.now().toIso8601String(),
      'cards': cards.map((c) => c.toJson()).toList(),
      'shoppingItems': items.map((i) => i.toJson()).toList(),
      'quickAccessKeys': quickAccessKeys,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/walletik_backup_$timestamp.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Walletik Backup',
    );
  }

  /// Import data from a JSON file. Returns a summary string or throws on error.
  static Future<String> importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) {
      throw Exception('No file selected');
    }

    final path = result.files.single.path;
    if (path == null) throw Exception('Could not read file');

    final file = File(path);
    final jsonString = await file.readAsString();

    final data = json.decode(jsonString) as Map<String, dynamic>;

    // Validate version
    final version = data['version'] as int?;
    if (version == null || version > _version) {
      throw Exception('Unsupported backup version');
    }

    int cardsImported = 0;
    int itemsImported = 0;

    // Import cards
    if (data['cards'] != null) {
      final cardsList = (data['cards'] as List)
          .map((c) => LoyaltyCard.fromJson(c as Map<String, dynamic>))
          .toList();
      await CardStorage.saveCards(cardsList);
      cardsImported = cardsList.length;
    }

    // Import shopping items
    if (data['shoppingItems'] != null) {
      final itemsList = (data['shoppingItems'] as List)
          .map((i) => ShoppingItem.fromJson(i as Map<String, dynamic>))
          .toList();
      await ShoppingListStorage.saveItems(itemsList);
      itemsImported = itemsList.length;
    }

    // Import quick access keys
    if (data['quickAccessKeys'] != null) {
      final keys = (data['quickAccessKeys'] as List)
          .map((k) => k as String?)
          .toList();
      await CardStorage.saveQuickAccessKeys(keys);
    }

    return '$cardsImported cards, $itemsImported items imported';
  }
}
