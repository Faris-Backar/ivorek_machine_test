import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:ivorek_machine_test/app/utils/resources.dart';
import 'package:ivorek_machine_test/app/utils/utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapWithInteractiveLineMarker extends StatefulWidget {
  const MapWithInteractiveLineMarker({super.key});

  @override
  State<MapWithInteractiveLineMarker> createState() =>
      _MapWithInteractiveLineMarkerState();
}

class _MapWithInteractiveLineMarkerState
    extends State<MapWithInteractiveLineMarker> {
  gl.Position? currentLatLng;
  CircleAnnotation? circleAnnotation;
  CircleAnnotationManager? circleAnnotationManager;
  PolylineAnnotation? polylineAnnotation;
  PolylineAnnotationManager? polylineAnnotationManager;
  MapboxMap? mapboxMap;
  var isLight = true;
  Position? p1;
  Position? p2;

  void createOneAnnotation(ScreenCoordinate screenCoordinate) {
    if (p1 == null && p2 == null) {
      p1 = Position(screenCoordinate.y, screenCoordinate.x);
    } else {
      p2 = Position(screenCoordinate.y, screenCoordinate.x);
    }
    circleAnnotationManager
        ?.create(CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              screenCoordinate.y,
              screenCoordinate.x,
            ),
          ).toJson(),
          circleColor: p2 != null ? Colors.red.value : Colors.yellow.value,
          circleRadius: 12.0,
        ))
        .then((value) => circleAnnotation = value);
  }

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
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 1500),
      );
    }
  }

  void drawRoutePolyline(Position start, Position end) {
    Utils()
        .fetchRouteCoordinates(start, end, AppResources().mapBoxKey)
        .then((coordinates) {
      List<Position> points = coordinates
          .map((position) => Position(position.lng, position.lat))
          .toList();
      mapboxMap?.annotations.createPolylineAnnotationManager().then((manager) {
        polylineAnnotationManager = manager;
        manager
            .create(PolylineAnnotationOptions(
                geometry: LineString(coordinates: points).toJson(),
                lineColor: Colors.green.value,
                lineWidth: 3))
            .then((value) => polylineAnnotation = value);
      });
    });
  }

  _onTapListner(ScreenCoordinate screenCoordinate) {
    mapboxMap?.annotations.createCircleAnnotationManager().then((value) async {
      circleAnnotationManager = value;
      createOneAnnotation(screenCoordinate);
      if (p1 != null && p2 != null) {
        drawRoutePolyline(p1!, p2!);
        p1 = p2 = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: MapWidget(
        key: const ValueKey("mapWidget"),
        styleUri: MapboxStyles.LIGHT,
        textureView: true,
        onMapCreated: _onMapCreated,
        onTapListener: _onTapListner,
      ),
    ));
  }
}
