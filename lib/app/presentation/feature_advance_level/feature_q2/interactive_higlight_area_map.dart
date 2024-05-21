import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:ivorek_machine_test/app/utils/utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class InteractiveHiglightAreaMap extends StatefulWidget {
  const InteractiveHiglightAreaMap({super.key});

  @override
  State<InteractiveHiglightAreaMap> createState() =>
      _InteractiveHiglightAreaMapState();
}

class _InteractiveHiglightAreaMapState
    extends State<InteractiveHiglightAreaMap> {
  gl.Position? currentLatLng;
  MapboxMap? mapboxMap;
  PolygonAnnotation? polygonAnnotation;
  PolygonAnnotationManager? polygonAnnotationManager;
  int styleIndex = 1;

  _onMapCreated(MapboxMap mapboxMap) async {
    currentLatLng = await Utils.determinePosition();
    setState(() {});
    this.mapboxMap = mapboxMap;
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

  void createOneAnnotation(ScreenCoordinate screenCoordinate) {
    final polygonPoints = Utils().generatePolygonPoints(screenCoordinate);
    polygonAnnotationManager?.createMulti([
      PolygonAnnotationOptions(
          geometry: Polygon(coordinates: [polygonPoints]).toJson(),
          fillColor: Colors.red.withOpacity(.3).value,
          fillOutlineColor: Colors.purple.value)
    ]).then((value) => polygonAnnotation = value.first);
  }

  _onTapListner(ScreenCoordinate screenCoordinate) async {
    mapboxMap?.annotations.createPolygonAnnotationManager().then((value) async {
      polygonAnnotationManager = value;
      createOneAnnotation(screenCoordinate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
      key: const ValueKey("mapWidget"),
      onMapCreated: _onMapCreated,
      onTapListener: _onTapListner,
      styleUri: MapboxStyles.LIGHT,
    );
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: mapWidget,
    ));
  }
}
