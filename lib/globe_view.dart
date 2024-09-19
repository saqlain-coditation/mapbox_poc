import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;

import 'map_view.dart';
import 'methods/lib_methods.dart';
import 'task_handler/task_handler.dart';

class GlobeView extends StatefulWidget {
  static const sandGlobe = "mapbox://styles/saqlain-coditation/cm17tstxm008m01pcamhx3ek9";
  const GlobeView({super.key});

  @override
  State<GlobeView> createState() => _GlobeViewState();
}

class _GlobeViewState extends State<GlobeView> {
  final ValueNotifier<MapboxMap?> _controller = ValueNotifier(null);
  final TaskHandler _debouncer = TaskHandler.timed(200);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initController(MapboxMap controller) {
    _controller.value = controller;
    controller.annotations
        .createPointAnnotationManager(id: "markers")
        .then((pointAnnotationManager) async {
      await pointAnnotationManager.create(PointAnnotationOptions(
        geometry: MapView.ios.center!,
        image: await const LibMethods().paint(painter: _markPainter),
      ));
    });
  }

  Size _markPainter(Canvas canvas) {
    var size = const Size.square(120);
    var center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(
      center,
      size.shortestSide / 2,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(colors: [
          Colors.white,
          Colors.white.withOpacity(0),
        ]).createShader(Rect.fromCenter(
          center: center,
          width: size.width,
          height: size.height,
        )),
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.shortestSide * .3,
      Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity(.5),
    );

    return size;
  }

  void onUpdate(CameraChangedEventData event) {
    var controller = _controller.value;
    if (controller == null) return;
    _debouncer.handle(() async {
      var camera = await controller.getCameraState();
      print(
        "Camera Position: "
        "(${camera.center.coordinates.lng}, ${camera.center.coordinates.lat})"
        ", zoom: ${camera.zoom}",
      );
      controller.style.getLayer("markers").then((layer) async {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      cameraOptions: CameraOptions(center: MapView.ios.center, zoom: 1),
      textureView: true,
      styleUri: GlobeView.sandGlobe,
      onMapCreated: _initController,
      onCameraChangeListener: onUpdate,
    );
  }
}
