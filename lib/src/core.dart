import 'dart:typed_data';

enum ImageFormat { jpg, png }

abstract class ImageSqueezeBase {
  const ImageSqueezeBase({this.format = ImageFormat.jpg, this.maxHeight, this.quality = 100});

  final ImageFormat format;
  final int? maxHeight;
  final int quality;

  Future<Uint8List> process(Uint8List input);
}
