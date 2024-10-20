import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/services/light_sensor_service.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'start_page.dart';
import 'login_screen.dart';
import 'settings_page.dart';
import '../widgets/error_dialog.dart';
import '../widgets/connection_status.dart';

class LightBulbControl extends StatefulWidget {
  final ApiService apiService;
  final StorageService storageService;
  final String deviceId;
  final List<String> devices;

  const LightBulbControl({
    super.key,
    required this.apiService,
    required this.storageService,
    required this.deviceId,
    required this.devices,
  });

  @override
  _LightBulbControlState createState() => _LightBulbControlState();
}

class _LightBulbControlState extends State<LightBulbControl> {
  bool isLightOn = false;
  bool isBulbDimmable = true;
  int brightness = 50;
  bool automaticBrightness = false;
  late String deviceId;
  late IO.Socket socket;
  late final LightSensorService lightSensorService;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    deviceId = widget.deviceId;
    _fetchDeviceStatus();
    _connectWebSocket();

    lightSensorService = LightSensorService();
    lightSensorService.initialize();
  }

  void _connectWebSocket() async {
    String? serverUrl = await widget.storageService.read('server_url');
    if (serverUrl == null) {
      _showErrorDialog('Server URL not found');
      return;
    }

    try {
      socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket.connect();

      socket.onConnect((_) {
        print('connect');
      });

      socket.on('device_status_update', (data) {
        // Usa direttamente i dati ricevuti senza decodificarli
        final message = data;
        if (message['device_id'] == deviceId) {
          final status = message['status'];

          setState(() {
            if (status.containsKey('is_on')) {
              isLightOn = status['is_on'];
            }
            if (status.containsKey('is_dimmable')) {
              isBulbDimmable = status['is_dimmable'];

              if (status.containsKey('brightness')) {
                brightness = status['brightness'];
              }
            }
          });
        }
      });

      socket.onDisconnect((_) => print('disconnect'));

      socket.onError((error) {
        _showErrorDialog('WebSocket error: $error');
      });

      socket.on('connect_error', (error) {
        _showErrorDialog('WebSocket connection error: $error');
      });
    } catch (e) {
      _showErrorDialog('Failed to connect to WebSocket: $e');
    }
  }

  Future<void> _fetchDeviceStatus() async {
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
      final response = await widget.apiService
          .fetchDeviceStatus(serverUrl!, deviceId, token);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        setState(() {
          isLightOn = status['is_on'];
          isBulbDimmable = status['is_dimmable'];
          if (isBulbDimmable) {
            brightness = status['brightness'];
          }
        });
      } else {
        _showErrorDialog(
            'Failed to load device status: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  Future<void> _updateDeviceStatus() async {
    String? serverUrl = await widget.storageService.read('server_url');
    final token = await widget.storageService.read('jwt');
    try {
      final response = await widget.apiService.updateDeviceStatus(
          serverUrl!,
          deviceId,
          isLightOn,
          isBulbDimmable,
          isBulbDimmable ? brightness : null,
          token!);
      if (response.statusCode != 200) {
        _showErrorDialog(
            'Failed to update device status: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  Future<void> _toggleLight() async {
    setState(() {
      isLightOn = !isLightOn;
    });
    await _updateDeviceStatus();
  }

  Future<void> _updateBrightness(double newBrightness) async {
    // Cancels the previous debouncer if there was a new state change
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Starts a new debouncer
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        brightness = newBrightness.toInt();
      });
      await _updateDeviceStatus();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message);
      },
    );
  }

  Future<void> _logout() async {
    await widget.storageService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StartPage()),
    );
  }

  void _onDeviceSelected(String? newDeviceId) {
    setState(() {
      deviceId = newDeviceId!;
    });
    _fetchDeviceStatus();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.close();
    lightSensorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ConnectionStatus.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Light Bulb Control'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SettingsPage(storageService: widget.storageService)),
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
              connectionStatus?.isConnected ?? false
                  ? 'Connected to server'
                  : 'Not connected to server',
              style: TextStyle(
                  color: connectionStatus?.isConnected ?? false
                      ? Colors.green
                      : Colors.red),
            ),
            DropdownButton<String>(
              hint: Text('Select Device'),
              value: deviceId,
              onChanged: _onDeviceSelected,
              items: widget.devices.map((String deviceId) {
                return DropdownMenuItem<String>(
                  value: deviceId,
                  child: Text(deviceId),
                );
              }).toList(),
            ),
            Image.asset(
              isLightOn
                  ? 'assets/images/light-bulb-ON.jpg'
                  : 'assets/images/light-bulb-OFF.jpg',
              height: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleLight,
              child: Text(isLightOn ? 'Turn OFF' : 'Turn ON'),
            ),
            SizedBox(height: 20),
            if (isLightOn)
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder<int>(
                      stream: lightSensorService.lightStream,
                      builder: (context, snapshot) {
                        // Check if the stream has valid data
                        double lightValue =
                            snapshot.hasData ? snapshot.data!.toDouble() : 10.0;

                        // Automatically update brightness if automaticBrightness is true
                        if (automaticBrightness && snapshot.hasData) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _updateBrightness(lightValue);
                          });
                        }

                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: automaticBrightness
                                ? lightValue
                                : brightness.toDouble(),
                            end: automaticBrightness
                                ? lightValue
                                : brightness.toDouble(),
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, animatedValue, child) {
                            return Slider(
                              value: automaticBrightness
                                  ? animatedValue
                                  : brightness.toDouble(),
                              min: 1,
                              max: 100,
                              divisions: 99,
                              label: '$brightness',
                              onChanged: automaticBrightness
                                  ? null
                                  : (double value) {
                                      _updateBrightness(value);
                                    },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            Center(
              child: Row(
                children: [
                  StreamBuilder<int>(
                    stream: lightSensorService.lightStream,
                    builder: (context, snapshot) {
                      return Text(
                        'Light Level: ${snapshot.data ?? 'No data'}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      );
                    },
                  ),
                  Switch(
                    value: automaticBrightness,
                    activeColor: Colors.blueAccent,
                    onChanged: (bool value) async {
                      setState(() {
                        automaticBrightness = value;
                      });
                      if (value) {
                        await lightSensorService.startListening();
                      } else {
                        await lightSensorService.stopListening();
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
