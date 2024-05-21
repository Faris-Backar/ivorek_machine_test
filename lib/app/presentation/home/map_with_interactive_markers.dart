import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:ivorek_machine_test/app/utils/resources.dart';
import 'package:ivorek_machine_test/app/utils/utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapWithInteractiveMarkers extends StatefulWidget {
  const MapWithInteractiveMarkers({super.key});

  @override
  State<MapWithInteractiveMarkers> createState() =>
      _MapWithInteractiveMarkersState();
}

class _MapWithInteractiveMarkersState extends State<MapWithInteractiveMarkers> {
  gl.Position? currentLatLng;
  MapboxMap? mapboxMap;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;
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
    }
  }

  void createOneAnnotation(ScreenCoordinate screenCoordinate, Uint8List list) {
    pointAnnotationManager
        ?.create(PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                screenCoordinate.y,
                screenCoordinate.x,
              ),
            ).toJson(),
            textOffset: [0.0, -2.0],
            textColor: Colors.red.value,
            iconSize: 1.3,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            image: list))
        .then((value) => pointAnnotation = value);
  }

  _onTapListner(ScreenCoordinate screenCoordinate) async {
    log("ontapped => ${screenCoordinate.encode()}");
    final ByteData bytes = await rootBundle.load(AppResources.customIcon);
    final Uint8List list = bytes.buffer.asUint8List();
    mapboxMap?.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      createOneAnnotation(screenCoordinate, list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
      key: const ValueKey("mapWidget"),
      styleUri: MapboxStyles.LIGHT,
      onMapCreated: _onMapCreated,
      onTapListener: _onTapListner,
    );
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: mapWidget,
    ));
  }
}
