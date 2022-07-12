import 'package:geolocator/geolocator.dart';

class Geolocation {
  bool _hasPermission(locationPermission) {
    return locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always;
  }

  Future<bool> checkPermission() {
    return Geolocator.checkPermission().then(_hasPermission);
  }

  Future<bool> requestPermission() {
    return Geolocator.requestPermission().then(_hasPermission);
  }
}
