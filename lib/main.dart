import 'package:flutter/material.dart';
import 'screens/start_page.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'widgets/connection_status.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();
  final StorageService storageService = StorageService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectionStatus(
      apiService: apiService,
      storageService: storageService,
      child: MaterialApp(
        title: 'Smart Home Control',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: StartPage(),
      ),
    );
  }
}