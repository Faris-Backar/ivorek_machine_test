import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:ivorek_machine_test/app/utils/resources.dart';
import 'package:ivorek_machine_test/app/utils/utils.dart';
import 'package:image/image.dart' as img;

class MapWithInteractiveGifMarker extends StatefulWidget {
  const MapWithInteractiveGifMarker({super.key});

  @override
  State<MapWithInteractiveGifMarker> createState() =>
      _MapWithInteractiveGifMarkerState();
}

class _MapWithInteractiveGifMarkerState
    extends State<MapWithInteractiveGifMarker> {
  gl.Position? currentLatLng;
  MapboxMap? mapboxMap;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;
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

  Future<void> _addImageSource(ScreenCoordinate screenCoordinate) async {
    const sourceId = "image_source_id";
    const layerId = "image_layer_id";

    // Check if the source already exists
    try {
      var existingSource = await mapboxMap?.style.getSource(sourceId);
      if (existingSource == null) {
        await mapboxMap?.style
            .addSource(ImageSource(id: sourceId, coordinates: [
          [screenCoordinate.x, screenCoordinate.y],
          [screenCoordinate.x, screenCoordinate.y],
          [screenCoordinate.x, screenCoordinate.y],
          [screenCoordinate.x, screenCoordinate.y],
        ]));
      }
    } catch (e) {
      // If the source does not exist or any other error occurs, we add the source
      await mapboxMap?.style.addSource(ImageSource(id: sourceId, coordinates: [
        [screenCoordinate.x, screenCoordinate.y],
        [screenCoordinate.x, screenCoordinate.y],
        [screenCoordinate.x, screenCoordinate.y],
        [screenCoordinate.x, screenCoordinate.y],
      ]));
    }

    // Check if the layer already exists
    try {
      var existingLayer = await mapboxMap?.style.getLayer(layerId);
      if (existingLayer == null) {
        await mapboxMap?.style.addLayer(RasterLayer(
          id: layerId,
          sourceId: sourceId,
        ));
      }
    } catch (e) {
      // If the layer does not exist or any other error occurs, we add the layer
      await mapboxMap?.style.addLayer(RasterLayer(
        id: layerId,
        sourceId: sourceId,
      ));
    }
  }

  _onTapListener(ScreenCoordinate screenCoordinate) async {
    final bytes = await rootBundle.load(AppResources.animatedIcon);
    final list = bytes.buffer.asUint8List();

    // Decode the image to get its actual dimensions
    final image = img.decodeImage(list);
    if (image != null) {
      final width = image.width;
      final height = image.height;

      // Add the image to the style with the correct dimensions
      await mapboxMap?.style.addStyleImage(
        "Image_id",
        1.0,
        MbxImage(width: width, height: height, data: list),
        false,
        [],
        [],
        ImageContent(left: 10, top: 10, right: 10, bottom: 10),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final MapWidget mapWidget = MapWidget(
      key: const ValueKey("mapWidget"),
      onMapCreated: _onMapCreated,
      onTapListener: _onTapListener,
      styleUri: MapboxStyles.LIGHT,
    );
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: mapWidget,
      ),
    );
  }
}
