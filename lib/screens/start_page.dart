import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import '../widgets/connection_status.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TextEditingController _serverController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkServerUrl();
  }

  Future<void> _checkServerUrl() async {
    String? serverUrl = await _storage.read(key: 'server_url');
    String? token = await _storage.read(key: 'jwt');
    if (serverUrl != null) {
      if (token != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  Future<void> _saveServerUrl() async {
    await _storage.write(key: 'server_url', value: _serverController.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ConnectionStatus.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Server Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              connectionStatus?.isConnected ?? false ? 'Connected to server' : 'Not connected to server',
              style: TextStyle(color: connectionStatus?.isConnected ?? false ? Colors.green : Colors.red),
            ),
            TextField(
              controller: _serverController,
              decoration: InputDecoration(labelText: 'Server Address'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveServerUrl,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}