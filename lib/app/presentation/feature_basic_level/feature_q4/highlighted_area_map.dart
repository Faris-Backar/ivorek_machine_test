import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:ivorek_machine_test/app/utils/utils.dart';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HighlightedAreaMap extends StatefulWidget {
  const HighlightedAreaMap({super.key});

  @override
  State<HighlightedAreaMap> createState() => _HighlightedAreaMapState();
}

class _HighlightedAreaMapState extends State<HighlightedAreaMap> {
  gl.Position? currentLatLng;
  MapboxMap? mapboxMap;
  PolygonAnnotation? polygonAnnotation;
  PolygonAnnotationManager? polygonAnnotationManager;
  int styleIndex = 1;

  _onMapCreated(MapboxMap mapboxMap) async {
    currentLatLng = await Utils.determinePosition();
    setState(() {});
    this.mapboxMap = mapboxMap;
    mapboxMap.style;

    if (currentLatLng != null) {
      mapboxMap.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              currentLatLng!.longitude,
              currentLatLng!.latitude,
            ),
          ).toJson(),
          pitch: 0,
          zoom: 8.0, // Adjust the zoom level as needed
        ),
        MapAnimationOptions(duration: 1500), // Duration of the flyTo animation
      );
      mapboxMap.annotations
          .createPolygonAnnotationManager()
          .then((value) async {
        polygonAnnotationManager = value;
        createOneAnnotation();
      });
    }
  }

  void createOneAnnotation() {
    final polygonPoints = Utils().generatePolygonPoints(ScreenCoordinate(
        x: currentLatLng!.latitude, y: currentLatLng!.longitude));
    polygonAnnotationManager
        ?.create(PolygonAnnotationOptions(
            geometry: Polygon(coordinates: [polygonPoints]).toJson(),
            fillColor: Colors.red.withOpacity(.3).value,
            fillOutlineColor: Colors.purple.value))
        .then((value) => polygonAnnotation = value);
  }

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
      key: const ValueKey("mapWidget"),
      onMapCreated: _onMapCreated,
      styleUri: MapboxStyles.LIGHT,
    );

    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: mapWidget,
    ));
  }
}
