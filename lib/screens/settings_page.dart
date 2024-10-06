import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'start_page.dart';

class SettingsPage extends StatelessWidget {
  final StorageService storageService;

  SettingsPage({required this.storageService});

  Future<void> _resetSettings(BuildContext context) async {
    await storageService.delete('server_url');
    await storageService.delete('jwt');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _resetSettings(context),
          child: Text('Reset'),
        ),
      ),
    );
  }
}