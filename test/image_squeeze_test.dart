import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_squeeze/image_squeeze.dart';

void main() async {
  final input = await File('test/assets/source.jpg').readAsBytes();

  test('can compress: JPG', () async {
    final output = await ImageSqueeze(maxHeight: 1080, quality: 70).process(input);
    expect(output.length < input.length, true);
  });

  test('can compress: PNG', () async {
    final output = await ImageSqueeze(maxHeight: 1080, quality: 70, format: ImageFormat.png).process(input);
    expect(output.isNotEmpty, true);
  });
}
