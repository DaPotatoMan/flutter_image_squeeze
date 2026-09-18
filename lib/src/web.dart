import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:image_squeeze/src/core.dart';
import 'package:web/web.dart' as web;

class ImageSqueeze extends ImageSqueezeBase {
  ImageSqueeze({super.format, super.maxHeight, super.quality});

  @override
  Future<Uint8List> process(Uint8List source) {
    final promise = Completer<Uint8List>();
    final workerUrl = Uri.base.resolve('assets/packages/image_squeeze/assets/worker.mjs');

    final worker = web.Worker(
      workerUrl.toString().toJS,
      web.WorkerOptions(type: 'module'),
    );

    void completeError(Object error, [StackTrace? stackTrace]) {
      worker.terminate();
      if (!promise.isCompleted) promise.completeError(error, stackTrace);
    }

    worker.addEventListener(
      'message',
      (web.MessageEvent event) {
        final data = event.data.dartify();

        if (data is Uint8List) {
          worker.terminate();
          if (!promise.isCompleted) promise.complete(data);
        }
      }.toJS,
    );

    worker.addEventListener(
      'error',
      (web.ErrorEvent event) {
        completeError(Exception('Image worker failed: ${event.message}'));
      }.toJS,
    );

    final type = switch (format) {
      .jpg => 'image/jpeg',
      .png => 'image/png',
    };

    final task = {
      'data': source,
      'type': type,
      'quality': (quality / 100).clamp(0, 1),
      'maxHeight': maxHeight,
    };

    worker.postMessage(task.jsify());
    return promise.future;
  }
}
