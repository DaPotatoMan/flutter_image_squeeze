import 'dart:typed_data';

import 'package:total_image_compress/src/core.dart';

class TotalCompress extends TotalCompressBase {
  TotalCompress({super.format, super.maxHeight, super.quality}) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> process(Uint8List source) => throw UnimplementedError();
}
