import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:image_squeeze/src/core.dart';
import 'package:web/web.dart' as web;

class ImageSqueeze extends ImageSqueezeBase {
  ImageSqueeze({super.format, super.maxHeight, super.quality});

  @override
  Future<Uint8List> process(Uint8List source) async {
    const packageName = 'image_squeeze';
    final result = Completer<Uint8List>();
    final worker = WebWorker(packageName, 'assets/packages/$packageName/assets/worker.mjs');

    void onError(Object error, [StackTrace? stackTrace]) {
      if (!result.isCompleted) {
        result.completeError(error, stackTrace);
      }
    }

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

    try {
      worker
        ..onEvent<web.MessageEvent>(
          'message',
          (event) {
            if (result.isCompleted) return;

            final response = event.data.dartify();

            return switch (response) {
              Uint8List() => result.complete(response),
              {'error': final String error} => onError(StateError(error)),
              _ => onError(StateError('Worker returned an unexpected response: $response')),
            };
          },
          onError: onError,
        )
        ..onEvent<web.ErrorEvent>(
          'error',
          (event) => onError(StateError(WebWorker.errorMessage(event))),
          onError: onError,
        )
        ..postMessage(task.jsify(), [source.buffer.toJS].toJS);

      return await result.future;
    } finally {
      worker.terminate();
    }
  }
}

/// A worker with typed event registration and listener error forwarding.
extension type const WebWorker.from(web.Worker worker) implements web.Worker {
  /// Creates a module worker for an asset relative to the application's base URI.
  factory WebWorker(String name, String path) {
    final workerUrl = Uri.parse(web.document.baseURI).resolve(path);

    final worker = web.Worker(
      workerUrl.toString().toJS,
      .new(type: 'module', name: name),
    );

    return .from(worker);
  }

  /// Returns an error message without assuming the browser supplied one.
  static String errorMessage(web.ErrorEvent event) {
    final message = event.getProperty('message'.toJS).dartify();

    return message is String && message.isNotEmpty ? message : 'Unknown worker error';
  }

  /// Handles incoming events
  void onEvent<T extends web.Event>(
    String type,
    FutureOr<void> Function(T event) handler, {
    required void Function(Object error, StackTrace stackTrace) onError,
  }) {
    void callback(web.Event event) {
      unawaited(() async {
        try {
          await handler(event as T);
        } catch (error, trace) {
          onError(error, trace);
        }
      }());
    }

    addEventListener(type, callback.toJS);
  }
}
