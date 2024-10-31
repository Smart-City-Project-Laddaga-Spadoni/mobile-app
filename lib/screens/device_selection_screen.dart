import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'light_bulb_control.dart';
import 'login_screen.dart';
import 'start_page.dart';
import 'settings_page.dart';
import '../widgets/error_dialog.dart';
import '../widgets/connection_status.dart';

class DeviceSelectionScreen extends StatefulWidget {
  final ApiService apiService;
  final StorageService storageService;

  const DeviceSelectionScreen({super.key, 
    required this.apiService,
    required this.storageService,
  });

  @override
  _DeviceSelectionScreenState createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  List<String> devices = [];
  String? selectedDeviceId;

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    String? serverUrl = await widget.storageService.read('server_url');
    final token = await widget.storageService.read('jwt');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }
    try {
      final response = await widget.apiService.getDevices(serverUrl!, token);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          devices = List<String>.from(data.map((device) => device['device_id']));
        });
      } else {
        _showErrorDialog('Failed to load devices: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message);
      },
    );
  }

  void _onDeviceSelected(String? deviceId) {
    setState(() {
      selectedDeviceId = deviceId;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LightBulbControl(
          apiService: widget.apiService,
          storageService: widget.storageService,
          deviceId: selectedDeviceId!,
          devices: devices, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ConnectionStatus.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Device'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await widget.storageService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StartPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(storageService: widget.storageService)),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              connectionStatus?.isConnected ?? false ? 'Connected to server' : 'Not connected to server',
              style: TextStyle(color: connectionStatus?.isConnected ?? false ? Colors.green : Colors.red),
            ),
            DropdownButton<String>(
              hint: Text('Select Device'),
              value: selectedDeviceId,
              onChanged: _onDeviceSelected,
              items: devices.map((String deviceId) {
                return DropdownMenuItem<String>(
                  value: deviceId,
                  child: Text(deviceId),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}