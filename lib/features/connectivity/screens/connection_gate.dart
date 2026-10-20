import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_petfinder/core/services/connection_service.dart';
import 'package:app_petfinder/features/connectivity/screens/check_connection_screen.dart';
import 'package:app_petfinder/features/connectivity/screens/no_connection_screen.dart';

class ConnectionGate extends StatefulWidget {
  final Widget child;

  const ConnectionGate({
    super.key,
    required this.child,
  });

  @override
  State<ConnectionGate> createState() => _ConnectionGateState();
}

class _ConnectionGateState extends State<ConnectionGate> {
  late final ConnectionService _connectionService;
  StreamSubscription<bool>? _subscription;

  bool? _hasInternet;
  int _connectionEventVersion = 0;

  @override
  void initState() {
    super.initState();

    _connectionService = ConnectionService();

    _subscription =
        _connectionService.onConnectionChanged.listen((hasInternet) {
      if (!mounted) return;

      _connectionEventVersion++;

      setState(() {
        _hasInternet = hasInternet;
      });
    });

    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final versionBeforeCheck = _connectionEventVersion;

    bool hasInternet;

    try {
      hasInternet = await _connectionService.checkConnection();
    } catch (_) {
      hasInternet = false;
    }

    if (!mounted ||
        versionBeforeCheck != _connectionEventVersion) {
      return;
    }

    setState(() {
      _hasInternet = hasInternet;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _connectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = _hasInternet != true;

    return PopScope(
      canPop: !isBlocked,
      child: Stack(
        children: [
          IgnorePointer(
            ignoring: isBlocked,
            child: widget.child,
          ),
          if (isBlocked)
            Positioned.fill(
              child: _hasInternet == null
                  ? const CheckingConnectionScreen()
                  : NoConnectionScreen(
                      onRetry: _checkConnection,
                    ),
            ),
        ],
      ),
    );
  }
}
