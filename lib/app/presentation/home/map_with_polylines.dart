import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:ivorek_machine_test/app/utils/utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapWithPolyLines extends StatefulWidget {
  const MapWithPolyLines({super.key});

  @override
  State<MapWithPolyLines> createState() => _MapWithPolyLinesState();
}

class _MapWithPolyLinesState extends State<MapWithPolyLines> {
  MapboxMap? mapboxMap;
  PolylineAnnotation? polylineAnnotation;
  PolylineAnnotationManager? polylineAnnotationManager;
  int styleIndex = 1;
  gl.Position? currentLatLng;

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
            zoom: 12.0,
            pitch: 0),
        MapAnimationOptions(duration: 1500),
      );
    }
    mapboxMap.annotations.createPolylineAnnotationManager().then((value) {
      polylineAnnotationManager = value;
      createOneAnnotation();
      List<Position> positions = [];
      double startLat = currentLatLng!.latitude;
      double startLng = currentLatLng!.longitude;

      for (var i = 0; i < 100; i++) {
        positions.add(Position(
          startLng + (i * 0.001), // Increment longitude
          startLat + (i * 0.001), // Increment latitude
        ));
      }
      polylineAnnotationManager?.create(PolylineAnnotationOptions(
          geometry: LineString(coordinates: positions).toJson(),
          lineColor: Utils.createRandomColor()));
    });
  }

  void createOneAnnotation() {
    polylineAnnotationManager
        ?.create(PolylineAnnotationOptions(
            geometry: LineString(coordinates: [
              Position(
                currentLatLng?.latitude ?? 0,
                currentLatLng?.longitude ?? 0,
              ),
              Position(
                (currentLatLng?.latitude ?? 0) + 10,
                (currentLatLng?.longitude ?? 0) + 10,
              ),
            ]).toJson(),
            lineColor: Colors.red.value,
            lineWidth: 2))
        .then((value) => polylineAnnotation = value);
  }

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
        key: const ValueKey("mapWidget"),
        styleUri: MapboxStyles.LIGHT,
        onMapCreated: _onMapCreated);

    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: mapWidget,
    ));
  }
}
