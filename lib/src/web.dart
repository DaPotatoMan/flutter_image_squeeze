import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:total_image_compress/src/core.dart';
import 'package:web/web.dart' as web;

class TotalCompress extends TotalCompressBase {
  TotalCompress({super.format, super.maxHeight, super.quality});

  @override
  Future<Uint8List> process(Uint8List source) {
    final promise = Completer<Uint8List>();
    final worker = web.Worker(
      './assets/packages/total_image_compress/assets/worker.mjs'.toJS,
      web.WorkerOptions(type: 'module'),
    );

    worker.addEventListener(
      'message',
      (web.MessageEvent event) {
        final data = event.data.dartify();

        if (data is Uint8List) {
          worker.terminate();
          promise.complete(data);
        }
      }.toJS,
    );

    final type = switch (format) {
      ImageFormat.jpg => 'image/jpeg',
      ImageFormat.png => 'image/png',
    };

    final task = {
      'data': source,
      'type': type,
      'quality': (quality / 100).clamp(0, 1),
      'maxHeight': maxHeight,
    };

    worker.postMessage(task.jsify(), [source.buffer.toJS].toJS);
    return promise.future;
  }
}
