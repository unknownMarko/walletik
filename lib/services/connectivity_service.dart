import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionStatusController.stream;
  bool _isOnline = true;

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool get isOnline => _isOnline;

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Error checking connectivity: $e');
      _isOnline = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;

    
    _isOnline = results.any((result) =>
      result != ConnectivityResult.none
    );

    print('🌐 Connectivity changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');

    // Notify listeners
    _connectionStatusController.add(_isOnline);

    // Notify when going from offline to online
    if (!wasOnline && _isOnline) {
      print('✅ Connection restored!');
    }
  }

  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
