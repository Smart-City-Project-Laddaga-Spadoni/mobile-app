import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ConnectionStatus extends StatefulWidget {
  final Widget child;
  final ApiService apiService;
  final StorageService storageService;

  ConnectionStatus({
    required this.child,
    required this.apiService,
    required this.storageService,
  });

  @override
  _ConnectionStatusState createState() => _ConnectionStatusState();

  static _ConnectionStatusState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ConnectionStatusState>();
  }
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  bool isConnected = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPingTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPingTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkServerConnection();
    });
  }

  Future<void> _checkServerConnection() async {
    String? serverUrl = await widget.storageService.read('server_url');
    if (serverUrl == null) {
      setState(() {
        isConnected = false;
      });
      return;
    }
    try {
      final response = await widget.apiService.ping(serverUrl);
      if (response.statusCode == 200) {
        setState(() {
          isConnected = true;
        });
      } else {
        setState(() {
          isConnected = false;
        });
      }
    } catch (e) {
      setState(() {
        isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionStatusInherited(
      isConnected: isConnected,
      child: widget.child,
    );
  }
}

class ConnectionStatusInherited extends InheritedWidget {
  final bool isConnected;

  ConnectionStatusInherited({
    required Widget child,
    required this.isConnected,
  }) : super(child: child);

  @override
  bool updateShouldNotify(ConnectionStatusInherited oldWidget) {
    return oldWidget.isConnected != isConnected;
  }
}