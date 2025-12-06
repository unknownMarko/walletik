import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firestore_service.dart';

class SyncQueueService {
  static const String _queueKey = 'sync_queue';
  static final FirestoreService _firestoreService = FirestoreService();

  static Future<void> queueOperation(String type, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    List<Map<String, dynamic>> queue = [];
    if (queueJson != null) {
      try {
        queue = (json.decode(queueJson) as List).cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error loading sync queue: $e');
      }
    }

    queue.add({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_queueKey, json.encode(queue));
    print('📝 Queued $type operation (${queue.length} pending)');
  }

  static Future<void> processQueue() async {
    if (!_firestoreService.isAuthenticated) {
      print('⚠️ Cannot process queue: user not authenticated');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson == null) {
      print('✅ Sync queue is empty');
      return;
    }

    List<Map<String, dynamic>> queue = [];
    try {
      queue = (json.decode(queueJson) as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading sync queue: $e');
      return;
    }

    if (queue.isEmpty) {
      print('✅ Sync queue is empty');
      return;
    }

    print('🔄 Processing ${queue.length} queued operations...');

    int successCount = 0;
    List<Map<String, dynamic>> failedOperations = [];

    for (var operation in queue) {
      try {
        final type = operation['type'];
        final data = operation['data'] as Map<String, dynamic>;

        switch (type) {
          case 'add':
          case 'update':
            await _firestoreService.saveCard(data);
            successCount++;
            break;
          case 'delete':
            if (data['id'] != null) {
              await _firestoreService.deleteCard(data['id']);
              successCount++;
            }
            break;
        }
      } catch (e) {
        print('❌ Failed to sync operation: $e');
        failedOperations.add(operation);
      }
    }

    if (failedOperations.isEmpty) {
      await prefs.remove(_queueKey);
      print('✅ All $successCount operations synced successfully!');
    } else {
      await prefs.setString(_queueKey, json.encode(failedOperations));
      print('⚠️ Synced $successCount operations, ${failedOperations.length} failed');
    }
  }

  static Future<int> getPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson == null) return 0;

    try {
      final queue = (json.decode(queueJson) as List);
      return queue.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    print('🗑️ Sync queue cleared');
  }
}
