import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as g_locator;
import 'package:ivorek_machine_test/app/utils/utils.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class BasicMapWithMarker extends StatefulWidget {
  const BasicMapWithMarker({super.key});

  @override
  State<BasicMapWithMarker> createState() => _BasicMapWithMarkerState();
}

class _BasicMapWithMarkerState extends State<BasicMapWithMarker> {
  g_locator.Position? currentLatLng;
  CircleAnnotation? circleAnnotation;
  CircleAnnotationManager? circleAnnotationManager;
  MapboxMap? mapboxMap;
  var isLight = true;

  void createOneAnnotation() {
    circleAnnotationManager
        ?.create(CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              currentLatLng!.longitude,
              currentLatLng!.latitude,
            ),
          ).toJson(),
          circleColor: Colors.yellow.value,
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
          zoom: 15.0, // Adjust the zoom level as needed
        ),
        MapAnimationOptions(duration: 1500), // Duration of the flyTo animation
      );
      mapboxMap.annotations.createCircleAnnotationManager().then((value) {
        circleAnnotationManager = value;
        createOneAnnotation();
        var options = <CircleAnnotationOptions>[];
        for (var i = 0; i < 2000; i++) {
          options.add(
            CircleAnnotationOptions(
              circleRadius: 8.0,
              geometry: Point(
                coordinates: Position(
                  currentLatLng!.longitude,
                  currentLatLng!.latitude,
                ),
              ).toJson(),
              circleColor: Utils.createRandomColor(),
            ),
          );
        }
        circleAnnotationManager?.createMulti(options);
        circleAnnotationManager?.addOnCircleAnnotationClickListener(
          AnnotationClickListener(
            onAnnotationClick: (annotation) => circleAnnotation = annotation,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    setState(
                      () => isLight = !isLight,
                    );
                    if (isLight) {
                      mapboxMap?.loadStyleURI(MapboxStyles.LIGHT);
                    } else {
                      mapboxMap?.loadStyleURI(MapboxStyles.DARK);
                    }
                  },
                  child: const Icon(Icons.swap_horiz)),
              const SizedBox(height: 10),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          child: MapWidget(
            key: const ValueKey("mapWidget"),
            cameraOptions: CameraOptions(
                center: currentLatLng != null
                    ? Point(
                            coordinates: Position(currentLatLng!.latitude,
                                currentLatLng!.longitude))
                        .toJson()
                    : Point(coordinates: Position(-80.1263, 25.7845)).toJson(),
                zoom: 3.0),
            styleUri: MapboxStyles.LIGHT,
            textureView: true,
            onMapCreated: _onMapCreated,
          ),
        ));
  }
}

class AnnotationClickListener extends OnCircleAnnotationClickListener {
  AnnotationClickListener({
    required this.onAnnotationClick,
  });

  final void Function(CircleAnnotation annotation) onAnnotationClick;

  @override
  void onCircleAnnotationClick(CircleAnnotation annotation) {
    debugPrint("onAnnotationClick, id: ${annotation.id}");
    onAnnotationClick(annotation);
  }
}
