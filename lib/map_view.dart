import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:testing/navigation_repository/navigation_repository.dart';
import 'package:testing/utils/coordinates.dart';
import 'package:testing/utils/extensions.dart';
import 'package:testing/utils/methods/lib_methods.dart';
import 'package:testing/utils/task_handler/task_handler.dart';

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
    _drawMarkers();
  }

  Future<void> _drawMarkers() async {
    final controller = _controller.value!;

    var markers = List.generate(5, (i) {
      var index = i + 1;
      return Position(
        MapView.ios.center!.coordinates.lng + index * 0.001 * Random().nextDouble(),
        MapView.ios.center!.coordinates.lat + index * 0.001 * Random().nextDouble(),
      );
    });

    final pointAnnotationManager =
        await controller.annotations.createPointAnnotationManager(id: "markers");
    var options = await Future.wait(markers.map((pos) async {
      return PointAnnotationOptions(
        geometry: Point(coordinates: pos),
        image: await const LibMethods().paint(
          painter: (canvas) => _markerPainter(canvas, Colors.red),
        ),
      );
    }).toList());

    options.add(PointAnnotationOptions(
      geometry: Point(coordinates: MapView.ios.center!.coordinates),
      image: await const LibMethods().paint(
        painter: (canvas) => _markerPainter(canvas, Colors.blue),
      ),
    ));

    await pointAnnotationManager.createMulti(options);
    await _addNavigation([MapView.ios.center!.coordinates, ...markers]);
  }

  Future<void> _addNavigation(List<Position> markers) async {
    final controller = _controller.value!;
    final pathData = await NavigationRepository().shortestPath(markers.map((e) {
      return Coordinates(latitude: e.lat.toDouble(), longitude: e.lng.toDouble());
    }).toList());

    final paths = pathData?.$2;
    if (paths == null) return;

    await controller.style.addSource(
      GeoJsonSource(
        id: "paths",
        data: jsonEncode(
          {
            "type": "FeatureCollection",
            "features": paths.map((directions) {
              return {
                "type": "Feature",
                "properties": {
                  "color":
                      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0).hexCode
                },
                "geometry": {
                  "type": "LineString",
                  "coordinates": directions.route.map((e) => [e.longitude, e.latitude]).toList(),
                },
              };
            }).toList(),
          },
        ),
      ),
    );
    await controller.style.addLayerAt(
      LineLayer(
        slot: "markers",
        id: "line-layer",
        sourceId: "paths",
        lineWidth: 1,
        lineColorExpression: ['get', 'color'],
        lineDasharray: [5, 3],
      ),
      LayerPosition(below: "markers"),
    );
  }

  Size _markerPainter(Canvas canvas, Color color) {
    var size = const Size.square(60);
    var circleSize = Size(size.width - 8, size.height - 8);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      circleSize.shortestSide / 2,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color,
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
