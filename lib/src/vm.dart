import 'dart:io';
import 'dart:typed_data';

import 'package:fast_image_compress/fast_image_compress.dart' deferred as fast_img;
import 'package:image/image.dart' as image;
import 'package:total_image_compress/src/core.dart';

class TotalCompress extends TotalCompressBase {
  TotalCompress({super.format, super.maxHeight, super.quality});

  Future<image.Image> _parseImage(Uint8List source) async {
    final decoder = await (image.Command()..decodeImage(source)).executeThread();
    final input = await decoder.getImageThread();

    if (input == null) throw Exception('Failed to decode base image');
    return input;
  }

  Future<Uint8List> _processMobile(Uint8List source) async {
    await fast_img.loadLibrary();

    final input = await _parseImage(source);
    final maxWidth = maxHeight == null ? input.width : (input.width * (maxHeight! / input.height)).round();

    final compressor = fast_img.FastImageCompress();
    final output = await compressor.compressImage(
      quality: quality,
      targetWidth: maxWidth,
      imageData: source,
      imageQuality: fast_img.ImageQuality.high,
    );

    if (output == null) throw Exception('Failed to compress image');
    return output;
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
