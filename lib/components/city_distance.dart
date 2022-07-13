import 'package:flutter/material.dart';
import 'package:geolocation_app/models/city_distance.dart';
import 'package:geolocation_app/resources/strings.dart';

class CityDistanceCard extends StatelessWidget {
  const CityDistanceCard({
    Key? key,
    required this.cityDistance,
  }) : super(key: key);

  final CityDistance cityDistance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final distanceKm = cityDistance.distance / 1000;
    final distanceText = distanceKm.toStringAsFixed(2) + ' km';
    final latitude = Strings.latitude(cityDistance.city.location.latitude);
    final longitude = Strings.longitude(cityDistance.city.location.longitude);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.asset(
            cityDistance.city.image,
            color: isDarkMode ? Colors.white.withOpacity(0.9) : null,
            colorBlendMode: isDarkMode ? BlendMode.difference : null,
          ),
          ListTile(
            tileColor: theme.colorScheme.secondary.withOpacity(0.4),
            title: Text(Strings.distanceFromMe(distanceText)),
            subtitle: Text('$latitude\n$longitude'),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}