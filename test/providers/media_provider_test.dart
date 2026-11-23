import 'dart:typed_data';

import 'package:apk_auth/providers/media_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('converts selected JPEG bytes to a Blob', () {
    final original = img.Image(width: 300, height: 200);
    img.fill(original, color: img.ColorRgb8(120, 40, 60));

    final provider = MediaProvider();
    final blob = provider.process(
      Uint8List.fromList(img.encodeJpg(original, quality: 100)),
    );

    expect(blob, isA<Blob>());
    expect(provider.errorMessage, isNull);
  });

  test('stores an error and returns null for invalid image bytes', () {
    final provider = MediaProvider();

    final blob = provider.process(Uint8List.fromList([1, 2, 3]));

    expect(blob, isNull);
    expect(provider.errorMessage, isNotNull);
  });
}
