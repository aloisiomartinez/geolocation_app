import 'package:flutter/material.dart';
import 'package:geolocation_app/components/geolocation_error.dart';
import 'package:geolocation_app/resources/strings.dart';
import 'package:geolocation_app/components/city_list.dart';
import 'package:geolocation_app/geolocation.dart';

class WonderfulCities extends StatefulWidget {
  const WonderfulCities({
    Key? key,
    required this.onThemeModePressed,
  }) : super(key: key);

  final VoidCallback onThemeModePressed;

  @override
  _WonderfulCitiesState createState() => _WonderfulCitiesState();
}

class _WonderfulCitiesState extends State<WonderfulCities> {
  final geolocation = Geolocation();

  late Future<bool> hasLocationPermissionFuture;

  @override
  void initState() {
    super.initState();
    hasLocationPermissionFuture = geolocation.checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appName),
        actions: [
          IconButton(
            onPressed: widget.onThemeModePressed,
            icon: Icon(
              theme.brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: hasLocationPermissionFuture,
        builder: (context, snapshot) {
          debugPrint('Permission: $snapshot');
          if (snapshot.connectionState == ConnectionState.done) {
            final hasPermission = snapshot.data;
            if (hasPermission != null && hasPermission) {
              return CityList(geolocation: geolocation);
            }
            return GeolocationError(
              icon: Icons.lock,
              title: Strings.errorLocationPermissionTitle,
              description: Strings.errorLocationPermissionDescription,
              actionText: Strings.givePermission,
              action: () async {
                final hasPermission = await geolocation.requestPermission();
                setState(() {
                  hasLocationPermissionFuture = Future.value(hasPermission);
                });
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
