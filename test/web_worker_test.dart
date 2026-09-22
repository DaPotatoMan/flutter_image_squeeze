@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_squeeze/src/web.dart';
import 'package:web/web.dart' as web;

void main() {
  group('WebWorker', () {
    test('preserves a worker error message', () {
      final event = web.ErrorEvent('error', web.ErrorEventInit(message: 'Worker failed'));

      expect(WebWorker.errorMessage(event), 'Worker failed');
    });

    test('uses a fallback when a worker error omits its message', () {
      final event = web.ErrorEvent('error');

      expect(WebWorker.errorMessage(event), 'Unknown worker error');
    });

    test('forwards listener exceptions to its error callback', () async {
      final worker = WebWorker.from(web.Worker('data:text/javascript,'.toJS));
      void terminateWorker() => worker.terminate();

      addTearDown(terminateWorker);
      final error = Completer<Object>();

      worker
        ..onEvent<web.Event>(
          'test-error',
          (_) => throw StateError('listener failure'),
          onError: (exception, _) => error.complete(exception),
        )
        ..dispatchEvent(web.Event('test-error'));

      await expectLater(error.future, completion(isA<StateError>()));
    });
  });
}
