import 'dart:typed_data';

import 'package:apk_auth/utils/project_image_processor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('resizes and JPEG-compresses an image below 100 KB', () {
    final original = img.Image(width: 1200, height: 800);
    img.fill(original, color: img.ColorRgb8(40, 120, 200));

    final result = ProjectImageProcessor.compress(
      Uint8List.fromList(img.encodePng(original)),
    );

    expect(result.length, lessThanOrEqualTo(100 * 1024));
  });

  test('rejects data that cannot be decoded as an image', () {
    expect(
      () => ProjectImageProcessor.compress(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<ProjectImageProcessingException>()),
    );
  });
}
