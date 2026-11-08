## 0.0.2

* Mobile: compress with `flutter_image_compress`, which decodes, resizes and encodes on a background thread. `fast_image_compress` ran on the main thread and froze the UI on large photos (seconds per image on older iPhones).
* Mobile: no longer decodes the full image in Dart just to read its size.
* Mobile: `format: .png` now outputs PNG (it was always JPEG).

## 0.0.1

* TODO: Describe initial release.
