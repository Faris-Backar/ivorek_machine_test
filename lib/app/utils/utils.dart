import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:ivorek_machine_test/app/utils/resources.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:turf/polyline.dart';

class Utils {
  static Future<gl.Position> determinePosition() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await gl.Geolocator.getCurrentPosition();
  }

  static int createRandomColor() {
    var random = Random();
    return Color.fromARGB(
            255, random.nextInt(255), random.nextInt(255), random.nextInt(255))
        .value;
  }

  Position createRandomPosition() {
    var random = Random();
    return Position(random.nextDouble() * -360.0 + 180.0,
        random.nextDouble() * -180.0 + 90.0);
  }

  List<Position> createRandomPositionList() {
    var random = Random();
    final positions = <Position>[];
    for (int i = 0; i < random.nextInt(6) + 4; i++) {
      positions.add(createRandomPosition());
    }

    return positions;
  }

  final annotationStyles = [
    MapboxStyles.SATELLITE_STREETS,
    MapboxStyles.MAPBOX_STREETS,
    MapboxStyles.OUTDOORS,
    MapboxStyles.LIGHT,
    MapboxStyles.DARK,
  ];

  Future<List<Position>> fetchRouteCoordinates(
      Position start, Position end, String accessToken) async {
    final response = await fetchDirectionRoute(start, end, accessToken);
    dev.log("route api response => $response");
    Map<String, dynamic> route = jsonDecode(response.body);

    return Polyline.decode(route['routes'][0]['geometry']);
  }

  Future<http.Response> fetchDirectionRoute(
      Position start, Position end, String accessToken) async {
    try {
      final uri = Uri.parse(
          "${AppResources.MAPBOX_DIRECTIONS_ENDPOINT}${start.lng},${start.lat};${end.lng},${end.lat}?overview=full&access_token=$accessToken");
      dev.log("route api url => $uri");
      return http.get(uri);
    } catch (e) {
      debugPrint("error in geting route api => $e");
      rethrow;
    }
  }

  List<Position> generateCirclePositions(
      gl.Position center, double radiusInKm) {
    const int numberOfPoints = 100;
    const double earthRadiusKm = 6371.0;

    double lat = center.latitude;
    double lng = center.longitude;

    double radiusRad = radiusInKm / earthRadiusKm;
    List<Position> positions = [];

    for (int i = 0; i < numberOfPoints; i++) {
      double angle = (2 * pi * i) / numberOfPoints;
      double newLat = asin(
          sin(lat) * cos(radiusRad) + cos(lat) * sin(radiusRad) * cos(angle));
      double newLng = lng +
          atan2(sin(angle) * sin(radiusRad) * cos(lat),
              cos(radiusRad) - sin(lat) * sin(newLat));
      positions.add(Position(newLng, newLat));
    }

    return positions;
  }

  List<Position> generatePolygonPoints(ScreenCoordinate center) {
    try {
      const double earthRadius = 6371.0;
      double radius = 1000.0;
      double distance = radius / earthRadius;

      List<Position> points = [];

      // Generate polygon points
      for (int i = 0; i < 360; i += 10) {
        double angle = pi * i / 180.0;
        double lat = center.x + (distance * cos(angle));
        double lng =
            center.y + (distance * sin(angle) / cos(center.x * pi / 180.0));
        points.add(Position(lng, lat));
      }

      // Close the polygon
      points.add(points.first);
      debugPrint("polygon points => $points");

      return points;
    } catch (e) {
      rethrow;
    }
  }
}
