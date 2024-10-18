import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<http.Response> login(
      String serverUrl, String username, String password) {
    return http.post(
      Uri.parse('$serverUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
  }

  Future<http.Response> signup(
      String serverUrl, String username, String password) {
    return http.post(
      Uri.parse('$serverUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
  }

  Future<http.Response> fetchDeviceStatus(
      String serverUrl, String deviceId, String token) {
    return http.get(
      Uri.parse('$serverUrl/device/$deviceId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> updateDeviceStatus(String serverUrl, String deviceId,
      bool isLightOn, bool isBulbDimmable, int? brightness, String token) {
    final status = <String, dynamic>{
      'is_on': isLightOn,
      'is_dimmable': isBulbDimmable,
    };

    // Conditionally add brightness if isDimmable is true and brightness is not null
    if (isBulbDimmable && brightness != null) {
      status['brightness'] = brightness;
    }

    return http.post(
      Uri.parse('$serverUrl/device/$deviceId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );
  }

  Future<http.Response> ping(String serverUrl) {
    return http.get(
      Uri.parse('$serverUrl/ping'),
    );
  }

  Future<http.Response> getDevices(String serverUrl, String token) {
    return http.get(
      Uri.parse('$serverUrl/devices'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
