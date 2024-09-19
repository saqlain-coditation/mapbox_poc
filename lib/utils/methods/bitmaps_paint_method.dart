import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'painting_methods.dart';

mixin BitmapPaintMethods on PaintingMethods {
  Future<Uint8List> paint({required Size Function(ui.Canvas) painter}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);
    final size = painter(canvas);
    final img = await pictureRecorder.endRecording().toImage(size.width.ceil(), size.height.ceil());
    final data = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    return data.buffer.asUint8List();
  }

  Future<Uint8List> bitmapDescriptorFromSvg(String asset, Size size) async {
    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(asset), null);
    final ui.Image image = await pictureInfo.picture.toImage(size.width.ceil(), size.height.ceil());
    pictureInfo.picture.dispose();
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    return bytes.buffer.asUint8List();
  }

  Future<Uint8List> bitmapDescriptorFromPng(String asset, Size size) async {
    final bytes = await getBytesFromAsset(asset, size);
    return bytes;
  }
}
