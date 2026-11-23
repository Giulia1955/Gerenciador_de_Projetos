import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ProjectImageProcessingException implements Exception {
  const ProjectImageProcessingException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProjectImageProcessor {
  static const maximumImageBytes = 100 * 1024;
  static const maximumImageDimension = 600;

  static Uint8List compress(Uint8List originalBytes) {
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) {
      throw const ProjectImageProcessingException(
        'Não foi possível ler o arquivo como uma imagem.',
      );
    }

    var resized = decoded;
    if (decoded.width > maximumImageDimension ||
        decoded.height > maximumImageDimension) {
      resized = img.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? maximumImageDimension : null,
        height: decoded.height > decoded.width ? maximumImageDimension : null,
        interpolation: img.Interpolation.average,
      );
    }

    for (final quality in [82, 70, 55, 40, 28]) {
      final encoded = Uint8List.fromList(
        img.encodeJpg(resized, quality: quality),
      );
      if (encoded.length <= maximumImageBytes) return encoded;
    }

    throw const ProjectImageProcessingException(
      'Não foi possível comprimir a imagem para menos de 100 KB.',
    );
  }
}
