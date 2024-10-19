import 'dart:async';
import 'dart:math';
import 'package:light/light.dart';
import 'package:rxdart/rxdart.dart';

class LightSensorService {
  Light? _light;
  StreamSubscription? _subscription;
  StreamController<int>? _lightStreamController;
  final List<int> _recentValues = [];
  final int _movingAverageWindow = 5;
  bool _isListening = false;

  // Getter for the stream
  Stream<int> get lightStream =>
      _lightStreamController?.stream ?? Stream.empty();

  // Initialize the service
  Future<void> initialize() async {
    if (_light != null) return; // Already initialized

    _light = Light();
    _lightStreamController = StreamController<int>.broadcast();
  }

  // Dispose of resources
  Future<void> dispose() async {
    await stopListening();
    await _lightStreamController?.close();
    _lightStreamController = null;
    _light = null;
  }

  // Process incoming light values
  int _processValue(int value) {
    _recentValues.add(value);
    if (_recentValues.length > _movingAverageWindow) {
      _recentValues.removeAt(0);
    }

    // Calculate moving average
    final average =
        _recentValues.reduce((a, b) => a + b) / _recentValues.length;
    return average.round();
  }

  // Start listening to light sensor
  Future<bool> startListening() async {
    if (_isListening) return true; // Already listening
    if (_light == null) await initialize();

    try {
      _subscription = _light?.lightSensorStream
          .throttleTime(const Duration(milliseconds: 250))
          .map(_mapLuxToRange)
          .listen((value) {
        _lightStreamController?.add(value);
      });

      _isListening = true;
      return true;
    } on LightException catch (exception) {
      print('Light sensor error: $exception');
      _isListening = false;
      return false;
    }
  }

  // Stop listening to light sensor
  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _recentValues.clear();
  }

  // Check if the service is currently listening
  bool get isListening => _isListening;

  int _mapLuxToRange(int luxValue, {double sensitivity = 1.0}) {
    // Prevent log(0)
    double lux = max(luxValue.toDouble(), 1.0);

    // Constants for mapping
    double maxLux = 45000.0;
    double minLux = 1.0;

    // Use log scale with sensitivity adjustment
    double logValue = log(lux) / log(10);
    double logMin = log(minLux) / log(10);
    double logMax = log(maxLux) / log(10);

    // Map to 1-100 range with sensitivity adjustment
    double scaledValue = ((logValue - logMin) / (logMax - logMin)) * 100;
    scaledValue = pow(scaledValue / 100, sensitivity) * 100;

    // Ensure output is between 1 and 100
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
}
