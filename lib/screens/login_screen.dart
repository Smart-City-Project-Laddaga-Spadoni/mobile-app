import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'device_selection_screen.dart';
import 'settings_page.dart';
import '../widgets/error_dialog.dart';
import '../widgets/connection_status.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final StorageService _storage = StorageService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    final connectionStatus = ConnectionStatus.of(context);
    connectionStatus?.startPingTimer();
  }

  Future<void> _login() async {
    print('Login button pressed');
    String? serverUrl = await _storage.read('server_url');
    if (serverUrl == null) {
      _showErrorDialog('Server URL is not set');
      return;
    }
    try {
      final response = await _apiService.login(serverUrl, _usernameController.text, _passwordController.text);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write('jwt', data['access_token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DeviceSelectionScreen(apiService: _apiService, storageService: _storage)),
        );
      } else {
        _showErrorDialog('Login failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  Future<void> _signup() async {
    print('Signup button pressed');
    String? serverUrl = await _storage.read('server_url');
    if (serverUrl == null) {
      _showErrorDialog('Server URL is not set');
      return;
    }
    try {
      final response = await _apiService.signup(serverUrl, _usernameController.text, _passwordController.text);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _showSuccessDialog('Registration successful. Please log in.');
      } else {
        final data = json.decode(response.body);
        _showErrorDialog('Signup failed: ${data['message']}');
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
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
        title: Text('Login'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(storageService: _storage)),
              );
            },
          ),
        ],
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
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
                Text('OR'),
                ElevatedButton(
                  onPressed: _signup,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}