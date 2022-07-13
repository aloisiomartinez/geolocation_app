import 'package:flutter/material.dart';
import 'package:geolocation_app/models/location.dart';
import 'package:geolocation_app/resources/strings.dart';

class MyLocation extends StatelessWidget {
  const MyLocation({
    Key? key,
    required this.location,
  }) : super(key: key);

  final Location location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Card(
        elevation: 0.0,
        child: ListTile(
          leading: Column(
            children: [
              Icon(
                Icons.location_pin,
                color: theme.colorScheme.secondary,
                size: 45.0,
              ),
            ],
          ),
          title: const Text(Strings.myLocation),
          isThreeLine: true,
          subtitle: Text(
              'Latitude: ${location.latitude}\nLongitude: ${location.longitude}'),
        ),
      ),
    );
  }
}