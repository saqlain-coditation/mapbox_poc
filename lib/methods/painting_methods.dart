import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

mixin PaintingMethods {
  Future<ImageInfo> loadImage(String image, Size size) {
    var imageCompletor = Completer<ImageInfo>();
    CachedNetworkImageProvider(image)
        .resolve(ImageConfiguration(textDirection: TextDirection.ltr, size: size))
        .addListener(ImageStreamListener((image, synchronousCall) {
      imageCompletor.complete(image);
    }));
    return imageCompletor.future;
  }

  Future<Uint8List> getBytesFromRawImage(ui.Image image) async {
    final imageData = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    return imageData.buffer.asUint8List();
  }

  Future<Uint8List> getBytesFromAsset(String path, Size size) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size.width.isFinite ? size.width.ceil() : null,
      targetHeight: size.height.isFinite ? size.height.ceil() : null,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    return await getBytesFromRawImage(fi.image);
  }
}
