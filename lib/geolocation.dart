import 'package:geolocator/geolocator.dart';

class Geolocation {
  bool _hasPermission(LocationPermission locationPermission) {
    return locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always;
  }

  Future<bool> checkPermission() async {
    final locationPermission = await Geolocator.checkPermission();
    return _hasPermission(locationPermission);
  }

  Future<bool> requestPermission() async {
    final locationPermission = await Geolocator.requestPermission();
    return _hasPermission(locationPermission);
  }
}
