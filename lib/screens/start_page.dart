import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import '../widgets/connection_status.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final String awsServer = "http://2-env.eba-sunmfvmc.eu-north-1.elasticbeanstalk.com";
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

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  Future<void> _saveServerUrl() async {
    final serverUrl = _serverController.text;
    if (!_isValidUrl(serverUrl)) {
      _showErrorDialog('Please enter a valid server URL.');
      return;
    }
    await _storage.write(key: 'server_url', value: serverUrl);
    // Controlla immediatamente la connessione
    final connectionStatus = ConnectionStatus.of(context);
    await connectionStatus?.checkServerConnection();
    connectionStatus?.startPingTimer();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _defaultServerUrl() async {
    final serverUrl = awsServer;
    if (!_isValidUrl(serverUrl)) {
      _showErrorDialog('Please enter a valid server URL.');
      return;
    }
    await _storage.write(key: 'server_url', value: serverUrl);
    final connectionStatus = ConnectionStatus.of(context);
    await connectionStatus?.checkServerConnection();
    connectionStatus?.startPingTimer();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _defaultServerUrl,
              child: Text('AWS server'),
            ),
          ],
        ),
      ),
    );
  }
}