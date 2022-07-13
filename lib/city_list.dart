import 'package:flutter/material.dart';
import 'package:geolocation_app/components/city_distance.dart';
import 'package:geolocation_app/components/my_location.dart';
import 'package:geolocation_app/geolocation.dart';
import 'package:geolocation_app/models/city_distance.dart';
import 'package:geolocation_app/models/location.dart';
import 'package:geolocation_app/utils/city_helper.dart' as city_helper;

import 'models/city.dart';

class CityList extends StatefulWidget {
  const CityList({
    Key? key,
    required this.geolocation,
  }) : super(key: key);

  final Geolocation geolocation;

  @override
  _CityListState createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  final cities = List<City>.from(city_helper.cities);

  @override
  void initState() {
    super.initState();
    widget.geolocation.listenToMyLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: StreamBuilder<Location>(
        stream: widget.geolocation.myLocationStream,
        builder: (context, snapshot) {
          debugPrint('Location: $snapshot');
          if (snapshot.connectionState == ConnectionState.active) {
            final myLocation = snapshot.data;
            if (myLocation != null) {
              final cityDistanceList = getCityDistanceList(myLocation);
              return Column(
                children: [
                  MyLocation(location: myLocation),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 5.0),
                      itemCount: cityDistanceList.length,
                      itemBuilder: (context, index) {
                        final cityDistance = cityDistanceList[index];
                        return CityDistanceCard(cityDistance: cityDistance);
                      },
                    ),
                  )
                ],
              );
            }
            // TODO: implementar a lógica de erros
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<CityDistance> getCityDistanceList(Location myLocation) {
    return cities
        .map((city) => CityDistance(city,
            widget.geolocation.distanceBetween(myLocation, city.location)))
        .toList()
      ..sort((cityA, cityB) => cityA.distance.compareTo(cityB.distance));
  }

  @override
  void dispose() {
    widget.geolocation.closeMyLocationStream();
    super.dispose();
  }
}