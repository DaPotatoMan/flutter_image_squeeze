import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_squeeze/image_squeeze.dart';

const _warmupIterations = 3;
const _measuredIterations = 10;

void main() {
  test('image processing benchmarks', () async {
    final input = await File('test/assets/source.jpg').readAsBytes();

    print('Input: ${input.lengthInBytes} bytes');
    print('Warm-up iterations: $_warmupIterations');
    print('Measured iterations: $_measuredIterations');

    await _benchmark(
      name: 'JPEG, quality 70, max height 1080',
      process: ImageSqueeze(maxHeight: 1080, quality: 70).process,
      input: input,
    );
    await _benchmark(
      name: 'PNG, max height 1080',
      process: ImageSqueeze(maxHeight: 1080, quality: 70, format: ImageFormat.png).process,
      input: input,
    );
    await _benchmark(
      name: 'JPEG, quality 70, original dimensions',
      process: ImageSqueeze(quality: 70).process,
      input: input,
    );
  }, timeout: Timeout.none);
}

Future<void> _benchmark({
  required String name,
  required Future<Uint8List> Function(Uint8List input) process,
  required Uint8List input,
}) async {
  for (var iteration = 0; iteration < _warmupIterations; iteration++) {
    await process(input);
  }

  final stopwatch = Stopwatch()..start();
  var outputBytes = 0;
  for (var iteration = 0; iteration < _measuredIterations; iteration++) {
    final output = await process(input);
    outputBytes = output.lengthInBytes;
  }
  stopwatch.stop();

  final averageMilliseconds = stopwatch.elapsedMicroseconds / _measuredIterations / 1000;
  print('$name: ${averageMilliseconds.toStringAsFixed(2)} ms/run ($outputBytes output bytes)');
}
