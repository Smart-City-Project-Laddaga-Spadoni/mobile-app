import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:mobile_app/screens/light_bulb_control.dart';
import 'package:mobile_app/services/api_service.dart';
import 'package:mobile_app/services/storage_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'widget_test.mocks.dart';

@GenerateMocks([ApiService, StorageService])
void main() {
  group('LightBulbControl Widget Tests', () {
    late MockApiService mockApiService;
    late MockStorageService mockStorageService;
    late List<String> devices;

    setUp(() {
      mockApiService = MockApiService();
      mockStorageService = MockStorageService();
      devices = ['device1', 'device2', 'device3'];

      when(mockStorageService.read('server_url')).thenAnswer((_) async => 'http://localhost');
      when(mockStorageService.read('jwt')).thenAnswer((_) async => 'fake_jwt_token');
      when(mockApiService.fetchDeviceStatus(any, any, any)).thenAnswer((_) async {
        return http.Response(json.encode({'status': {'is_on': false, 'brightness': 50}}), 200);
      });
      when(mockApiService.updateDeviceStatus(any, any, any, false, any, any)).thenAnswer((_) async {
        return http.Response('', 200);
      });
    });

    testWidgets('Initial state is light off with brightness 50', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: LightBulbControl(
            apiService: mockApiService,
            storageService: mockStorageService,
            deviceId: 'device1',
            devices: devices,
          ),
        ));

        expect(find.text('Turn ON'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
        expect(find.byType(DropdownButton<String>), findsOneWidget);
        expect(find.byType(Slider), findsNothing); // Slider should not be visible when light is off
      });
    });
  });
}