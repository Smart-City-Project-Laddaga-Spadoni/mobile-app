import 'dart:async';
import 'dart:math';
import 'package:light/light.dart';
import 'package:rxdart/rxdart.dart';

class LightSensorService {
  late final Light _light;
  late final StreamSubscription _subscription;
  late final StreamController<int> _lightStreamController;
  List<int> _recentValues = [];
  static const int _movingAverageWindow = 5;

  LightSensorService() {
    _light = Light();
    _lightStreamController = StreamController<int>.broadcast();
  }

  void startListening() {
    try {
      _subscription = _light.lightSensorStream
          .throttleTime(const Duration(seconds: 3))
          .map((luxValue) => _mapLuxToRange(luxValue))
          .map(_smoothValue) // First smooth the raw values
          .map(_applyHysteresis) // Then apply hysteresis to the smooth values
          .map(_invertForBulbControl) // Then invert for bulb control
          .map(
              _applyTimeBasedAdjustment) // Finally apply time-based adjustments
          .map(_applyDeadZone) // And enforce dead zones
          .listen((processedValue) {
        _lightStreamController.add(processedValue);
      });
    } on LightException catch (exception) {
      print(exception);
    }
  }

  int _mapLuxToRange(int luxValue) {
    double maxLux = 40000.0;
    double minLux = 10.0;
    double scaledValue = ((luxValue - minLux) / (maxLux - minLux)) * 100;
    return scaledValue.clamp(1, 100).toInt();
  }

  // Hysteresis to prevent rapid changes when values are borderline
  int _applyHysteresis(int value) {
    int lastValue = 0;
    const int threshold = 5; // Minimum change required

    if ((value - lastValue).abs() < threshold) {
      return lastValue;
    }
    lastValue = value;
    return value;
  }

  // Moving average to smooth out sudden spikes
  int _smoothValue(int value) {
    _recentValues.add(value);
    if (_recentValues.length > _movingAverageWindow) {
      _recentValues.removeAt(0);
    }

    return (_recentValues.reduce((a, b) => a + b) / _recentValues.length)
        .round();
  }

  // Invert the value for bulb control (bright ambient = dim bulb)
  int _invertForBulbControl(int value) {
    // Apply a non-linear curve for better human perception
    // Using inverse square root for a more natural feeling response
    double normalizedValue = value / 100;
    double invertedValue = (1 - sqrt(normalizedValue)) * 100;
    return invertedValue.round();
  }

  // Optional: Add dead zone at very high/low values
  int _applyDeadZone(int value) {
    if (value < 5) return 0; // Turn bulb off in very bright conditions
    if (value > 95) return 100; // Full brightness in very dark conditions
    return value;
  }

  // Optional: Add time-based adjustments
  int _applyTimeBasedAdjustment(int value) {
    final hour = DateTime.now().hour;

    // Late night dimming (11 PM - 6 AM)
    if (hour >= 23 || hour < 6) {
      return (value * 0.7).round(); // Reduce brightness by 30%
    }

    return value;
  }

  Stream<int> getLightSensorStream() {
    return _lightStreamController.stream;
  }

  void stopListening() {
    _subscription.cancel();
  }

  void dispose() {
    _lightStreamController.close();
  }
}
