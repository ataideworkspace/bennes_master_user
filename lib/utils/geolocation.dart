import 'package:background_location/background_location.dart';

void gpsEnd() {
  BackgroundLocation.stopLocationService();
}

void gpsStart() {
  BackgroundLocation.startLocationService();
}
