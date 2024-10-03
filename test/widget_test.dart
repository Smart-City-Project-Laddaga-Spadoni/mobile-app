import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/comunication/mqtt_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mqtt_client/mqtt_client.dart'; // Importa il pacchetto mqtt_client
import 'widget_test.mocks.dart'; // Importa il file di mock generato

@GenerateMocks([MQTTService])
void main() {
  group('LightBulbControl Widget Tests', () {
    late MockMQTTService mockMQTTService;

    setUp(() {
      mockMQTTService = MockMQTTService();
      when(mockMQTTService.connect()).thenAnswer((_) async {
        // Simula una connessione riuscita
        when(mockMQTTService.client.connectionStatus!.state)
            .thenReturn(MqttConnectionState.connected);
      });
      when(mockMQTTService.subscribeToTopic(any)).thenReturn(null);
      when(mockMQTTService.setOnMessageReceived(any)).thenReturn(null);
      when(mockMQTTService.publishMessage(any, any)).thenReturn(null);
    });

    testWidgets('Initial state is light off', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LightBulbControl(),
      ));

      expect(find.text('Turn ON'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}