# image_squeeze

Shrink images before you upload, share, or store them.

`image_squeeze` takes image bytes, optionally resizes them, and gives you the processed bytes back. It is intentionally small: pick your settings, call `process`, and use the result wherever your app needs it.

## Features

- Simple byte-in, byte-out API
- Resize images by maximum height
- Keeps the original aspect ratio
- Choose JPEG or PNG where supported
- Works on mobile, desktop, and web

## Getting started

Install the package:

```bash
dart pub add image_squeeze
```


## Usage

```dart
import 'dart:typed_data';
import 'package:image_squeeze/image_squeeze.dart';

final Uint8List output = await ImageSqueeze(maxHeight: 1440, quality: 75, format: .jpg).process(imageBytes);
```

## Parameters

| Property | Default | Supported values | What it does |
| --- | --- | --- | --- |
| `format` | `ImageFormat.jpg` | `.jpg` or `.png` | Sets the output format. |
| `maxHeight` | `null` | A positive pixel value or `null` | Sets the largest allowed height. The image keeps its original proportions. |
| `quality` | `100` | `0`–`100` | Sets JPEG quality. Lower values usually create smaller files. |

## Compatibility

JPEG is the safest choice for both input and output on every supported platform.

| Platform | JPEG | PNG | Notes |
| --- | --- | --- | --- |
| Android | Yes | Yes | Uses the native compressor, then converts to PNG when requested. |
| iOS | Yes | Yes | Uses the native compressor, then converts to PNG when requested. |
| Windows, macOS, Linux | Yes | Yes | PNG is lossless. |
| Web | Yes | Yes | Works in modern browsers. |

Other input formats may work too, but support varies by platform and browser. If your app needs predictable results everywhere, use JPEG input.

## Benchmarks

Run the included benchmark suite from the package root:

```bash
flutter test benchmark/image_squeeze_benchmark.dart --reporter expanded
```

It warms up the image processor, then reports the average processing time and output size for JPEG and PNG conversions using the bundled sample image.


## Acknowledgements

Thanks to [fast_image_compress](https://pub.dev/packages/fast_image_compress) for the mobile compression backend and [image](https://pub.dev/packages/image) for desktop image processing.

## License

This package is licensed under the [MIT License](LICENSE).
