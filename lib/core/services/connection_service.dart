
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionService {
  final InternetConnection _connection =
      InternetConnection.createInstance();

  Stream<bool> get onConnectionChanged {
    return _connection.onStatusChange.map(
      (status) => status == InternetStatus.connected,
    );
  }

  Future<bool> checkConnection() {
    return _connection.hasInternetAccess;
  }

  void dispose() {
    _connection.dispose();
  }
}
