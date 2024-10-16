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
        _lightStreamController.add(luxValue);
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
}
