import 'package:flutter_compass/flutter_compass.dart';

class CompassService {
  /// Stream of raw [CompassEvent]s. Each event carries heading (0-360,
  /// true-north on Android via ROTATION_VECTOR) and accuracy (±degrees).
  Stream<CompassEvent> get eventStream {
    return FlutterCompass.events ?? const Stream.empty();
  }

  /// Convenience stream of just the heading value.
  Stream<double?> get headingStream {
    return eventStream.map((e) => e.heading);
  }
}
