import 'dart:async';

import 'package:geolocation_app/models/exceptions.dart';
import 'package:geolocation_app/models/location.dart';
import 'package:geolocator/geolocator.dart';

class Geolocation {
  StreamController<Location> _myLocationController = StreamController();
  StreamSubscription? _subscription;
  Stream<Location> get myLocationStream => _myLocationController.stream;

  void listenToMyLocation() {
    if (_myLocationController.isClosed) {
      _myLocationController = StreamController();
    }
    _subscription = Geolocator.getPositionStream()
        .map((position) => Location(position.latitude, position.longitude))
        .distinct((previous, next) =>
            previous.latitude == next.latitude &&
            previous.longitude == next.longitude)
            .handleError((error) => _handleGpsDisabled(error),
              test: ((error) => error is LocationServiceDisabledException)
            )
        .listen((location) => _myLocationController.add(location));
  }

  void _handleGpsDisabled(LocationServiceDisabledException error) {
    final exception = GpsDisabledException(error.toString());
    _myLocationController.addError(exception);
  }

  void closeMyLocationStream() {
    _subscription?.cancel();
    _myLocationController.close();
  }

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

  double distanceBetween(Location locationA, Location locationB) {
    return Geolocator.distanceBetween(
      locationA.latitude,
      locationA.longitude,
      locationB.latitude,
      locationB.longitude,
    );
  }

  void openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> isGpsEnabled() async => Geolocator.isLocationServiceEnabled();
}
