import 'dart:async';
import 'package:light/light.dart';

class LightSensorService {
  late final Light _light;
  late final StreamSubscription _subscription;
  late final StreamController<int> _lightStreamController;

  LightSensorService() {
    _light = Light();
    _lightStreamController = StreamController<int>.broadcast();
  }

  void startListening() {
    try {
      _subscription = _light.lightSensorStream.listen((luxValue) {
        int normalizedLuxValue = _mapLuxToRange(luxValue);
        _lightStreamController.add(normalizedLuxValue);
      });
    } on LightException catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _subscription.cancel();
  }

  Stream<int> getLightSensorStream() {
    return _lightStreamController.stream;
  }

  void dispose() {
    _lightStreamController.close();
  }

  int _mapLuxToRange(int luxValue) {
    // TODO -> check if the received value's range
    double maxLux = 40000.0; // massimo lux rilevabile
    double minLux = 10.0; // minimo lux rilevabile
    double scaledValue = ((luxValue - minLux) / (maxLux - minLux)) * 100;
    return scaledValue.clamp(1, 100).toInt();
  }
}
