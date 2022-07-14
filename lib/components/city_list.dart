import 'package:flutter/material.dart';
import 'package:geolocation_app/components/city_distance.dart';
import 'package:geolocation_app/components/geolocation_error.dart';
import 'package:geolocation_app/components/my_location.dart';
import 'package:geolocation_app/geolocation.dart';
import 'package:geolocation_app/models/city_distance.dart';
import 'package:geolocation_app/models/exceptions.dart';
import 'package:geolocation_app/models/location.dart';
import 'package:geolocation_app/resources/strings.dart';
import 'package:geolocation_app/utils/city_helper.dart' as city_helper;

import '../models/city.dart';

class CityList extends StatefulWidget {
  const CityList({
    Key? key,
    required this.geolocation,
  }) : super(key: key);

  final Geolocation geolocation;

  @override
  _CityListState createState() => _CityListState();
}

class _CityListState extends State<CityList> with WidgetsBindingObserver{
  final cities = List<City>.from(city_helper.cities);
  bool requestedEnableGps = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    widget.geolocation.listenToMyLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && requestedEnableGps) {
      final isGpsEnabled = await widget.geolocation.isGpsEnabled();
      if(isGpsEnabled) {
        widget.geolocation.closeMyLocationStream();
        setState(() {
          widget.geolocation.listenToMyLocation();
        });
      }
    }
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
            if (snapshot.hasError) {
              if (snapshot.error is GpsDisabledException) {
                return GeolocationError(
                    icon: Icons.location_off,
                    title: Strings.errorGpsDisabledDescription,
                    description: Strings.errorGpsDisabledDescription,
                    actionText: Strings.enableLocationService,
                    action: () {
                      requestedEnableGps = true;
                      widget.geolocation.openLocationSettings();
                    });
              }
            }
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
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
