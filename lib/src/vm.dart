import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart' deferred as native;
import 'package:image/image.dart' as image;
import 'package:image_squeeze/src/core.dart';

/// Large enough that the native scaler never shrinks an image when no [ImageSqueezeBase.maxHeight] is set
const int _unboundedHeight = 1 << 16;

class ImageSqueeze extends ImageSqueezeBase {
  ImageSqueeze({super.format, super.maxHeight, super.quality});

  Future<image.Image> _parseImage(Uint8List source) async {
    final decoder = await (image.Command()..decodeImage(source)).executeThread();
    final input = await decoder.getImageThread();

    if (input == null) throw Exception('Failed to decode base image');
    return input;
  }

  /// Decodes, resizes and encodes natively on a background thread, so the UI never freezes.
  /// No Dart-side decode: the native side knows the size (and EXIF orientation) on its own.
  Future<Uint8List> _processMobile(Uint8List source) async {
    await native.loadLibrary();

    // The native scaler keeps the image at least minWidth x minHeight and never upscales.
    // A 1px minimum width leaves the height as the only bound.
    return native.FlutterImageCompress.compressWithList(
      source,
      minWidth: 1,
      minHeight: maxHeight ?? _unboundedHeight,
      quality: quality,
      format: switch (format) {
        .jpg => native.CompressFormat.jpeg,
        .png => native.CompressFormat.png,
      },
    );
  }

  Future<Uint8List> _processDesktop(Uint8List source) async {
    final input = await _parseImage(source);
    final cmd = image.Command()..image(input);

    // Resize
    if (maxHeight != null && input.height > maxHeight!) cmd.copyResize(height: maxHeight, maintainAspect: true);

    // Convert to format
    switch (format) {
      case .jpg:
        cmd.encodeJpg(quality: quality);

      case .png:
        cmd.encodePng();
    }

    await cmd.executeThread();
    final result = await cmd.getBytesThread();

    if (result == null) throw Exception('Failed to convert image');
    return result;
  }

  @override
  Future<Uint8List> process(Uint8List source) async {
    if (Platform.isAndroid || Platform.isIOS) return _processMobile(source);
    return _processDesktop(source);
  }
}
