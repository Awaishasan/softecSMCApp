import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStreamController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStream => _connectionStreamController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_checkConnection);
    checkConnectivity();
  }

  Future<bool> checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    await _checkConnection(connectivityResult);
    return _isConnected;
  }

  Future<void> _checkConnection(List<ConnectivityResult> results) async {
    // If no network is connected
    if (results.contains(ConnectivityResult.none)) {
      _updateConnectionStatus(false);
      return;
    }

    // Verify actual internet access
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateConnectionStatus(true);
      } else {
        _updateConnectionStatus(false);
      }
    } on SocketException catch (_) {
      _updateConnectionStatus(false);
    }
  }

  void _updateConnectionStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectionStreamController.add(_isConnected);
    }
  }
  
  void dispose() {
    _connectionStreamController.close();
  }
}
