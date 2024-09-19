import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:testing/methods/lib_methods.dart';
import 'package:testing/task_handler/task_handler.dart';

class MapView extends StatefulWidget {
  static final ios = CameraOptions(
    center: Point(coordinates: Position(-122.40642818089846, 37.78652745998411)),
    zoom: 15.202325820922852,
  );

  static final android = CameraOptions(
    center: Point(coordinates: Position(-122.08337933824733, 37.42028152585951)),
    zoom: 16,
  );
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final ValueNotifier<MapboxMap?> _controller = ValueNotifier(null);
  final TaskHandler _debouncer = TaskHandler.timed(200);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initController(MapboxMap controller) {
    _controller.value = controller;
    controller.style.setProjection(StyleProjection(name: StyleProjectionName.mercator));
    controller.location.updateSettings(LocationComponentSettings(
      enabled: true,
      showAccuracyRing: true,
    ));

    var markers = List.generate(5, (i) {
      var index = i + 1;
      return Position(
        MapView.ios.center!.coordinates.lng + index * 0.001 * Random().nextDouble(),
        MapView.ios.center!.coordinates.lat + index * 0.001 * Random().nextDouble(),
      );
    });

    () async {
      await controller.style.addSource(
        GeoJsonSource(
          id: "paths",
          data: jsonEncode(
            {
              "type": "FeatureCollection",
              "features": markers.map((pos) {
                return {
                  "type": "Feature",
                  "geometry": {
                    "type": "LineString",
                    "coordinates": [
                      [MapView.ios.center!.coordinates.lng, MapView.ios.center!.coordinates.lat],
                      [pos.lng, pos.lat],
                    ]
                  },
                };
              }).toList(),
            },
          ),
        ),
      );
      await controller.style.addLayer(LineLayer(
        id: "line-layer",
        sourceId: "paths",
        lineBorderColor: Colors.black.value,
        lineDasharray: [5, 3],
      ));

      controller.annotations.createPointAnnotationManager().then((pointAnnotationManager) async {
        var options = markers.map((pos) async {
          return PointAnnotationOptions(
            geometry: Point(coordinates: pos),
            image: await const LibMethods().paint(
              painter: (canvas) {
                var size = const Size.square(60);
                var circleSize = Size(size.width - 8, size.height - 8);
                canvas.drawCircle(
                  Offset(size.width / 2, size.height / 2),
                  circleSize.shortestSide / 2,
                  Paint()
                    ..style = PaintingStyle.fill
                    ..color = Colors.red,
                );
                canvas.drawCircle(
                  Offset(size.width / 2, size.height / 2),
                  size.shortestSide / 2,
                  Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.black,
                );
                return size;
              },
            ),
          );
        });
        await pointAnnotationManager.createMulti(await Future.wait(options));
      });
    }();
  }

  void _onUpdate(CameraChangedEventData event) {
    _debouncer.handle(() async {
      var camera = await _controller.value?.getCameraState();
      print(
        "Camera Position: "
        "(${camera?.center.coordinates.lng}, ${camera?.center.coordinates.lat})"
        ", zoom: ${camera?.zoom}",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // var screenSize = MediaQuery.sizeOf(context);
    return MapWidget(
      cameraOptions: MapView.ios,
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _initController,
      onCameraChangeListener: _onUpdate,
    );
  }
}
