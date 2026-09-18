import 'dart:typed_data';

import 'package:image_squeeze/src/core.dart';

class ImageSqueeze extends ImageSqueezeBase {
  ImageSqueeze({super.format, super.maxHeight, super.quality}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> process(Uint8List source) => throw UnimplementedError();
}
