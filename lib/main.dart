import 'package:flutter/material.dart';
import 'comunication/mqtt_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Light Bulb Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LightBulbControl(),
    );
  }
}

class LightBulbControl extends StatefulWidget {
  @override
  _LightBulbControlState createState() => _LightBulbControlState();
}

class _LightBulbControlState extends State<LightBulbControl> {
  late MQTTService mqttService;
  bool isLightOn = false;

  @override
  void initState() {
    super.initState();
    mqttService = MQTTService('10.0.2.2', 'flutter_client', 1883); // 10.0.2.2 is to connect to pc localhost from emulator
    mqttService.connect().then((_) {
      mqttService.subscribeToTopic('lamp/status');
    });
  }

  void toggleLight() {
    setState(() {
      isLightOn = !isLightOn;
    });
    mqttService.publishMessage('lamp/status', isLightOn ? 'on' : 'off');
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Light Bulb Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              isLightOn ? 'assets/images/light-bulb-ON.jpg' : 'assets/images/light-bulb-OFF.jpg',
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: toggleLight,
              child: Text(isLightOn ? 'Turn OFF' : 'Turn ON'),
            ),
          ],
        ),
      ),
    );
  }
}