import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'start_page.dart';
import '../widgets/error_dialog.dart';
import '../widgets/connection_status.dart';

class LightBulbControl extends StatefulWidget {
  final ApiService apiService;
  final StorageService storageService;

  LightBulbControl({
    required this.apiService,
    required this.storageService,
  });

  @override
  _LightBulbControlState createState() => _LightBulbControlState();
}

class _LightBulbControlState extends State<LightBulbControl> {
  bool isLightOn = false;
  final String deviceId = 'your_device_id'; // Sostituisci con il tuo device ID

  @override
  void initState() {
    super.initState();
    _fetchDeviceStatus();
  }

  Future<void> _fetchDeviceStatus() async {
    String? serverUrl = await widget.storageService.read('server_url');
    final token = await widget.storageService.read('jwt');
    try {
      final response = await widget.apiService.fetchDeviceStatus(serverUrl!, deviceId, token!);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isLightOn = data['status']['is_on'];
        });
      } else {
        _showErrorDialog('Failed to load device status: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  Future<void> _toggleLight() async {
    setState(() {
      isLightOn = !isLightOn;
    });
    String? serverUrl = await widget.storageService.read('server_url');
    final token = await widget.storageService.read('jwt');
    try {
      final response = await widget.apiService.toggleLight(serverUrl!, deviceId, isLightOn, token!);
      if (response.statusCode != 200) {
        _showErrorDialog('Failed to update device status: ${response.reasonPhrase}');
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

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ConnectionStatus.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Light Bulb Control'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await widget.storageService.delete('server_url');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StartPage()),
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
            Image.asset(
              isLightOn ? 'assets/images/light-bulb-ON.jpg' : 'assets/images/light-bulb-OFF.jpg',
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleLight,
              child: Text(isLightOn ? 'Turn OFF' : 'Turn ON'),
            ),
          ],
        ),
      ),
    );
  }
}