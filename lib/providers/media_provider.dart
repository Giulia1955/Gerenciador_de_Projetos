import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../utils/project_image_processor.dart';

class MediaProvider extends ChangeNotifier {
  bool _uploading = false;
  String? _error;

  bool get isUploading => _uploading;
  String? get errorMessage => _error;

  Blob? process(Uint8List bytes) {
    _uploading = true;
    _error = null;
    notifyListeners();
    try {
      final compressed = ProjectImageProcessor.compress(bytes);
      return Blob(compressed);
    } on ProjectImageProcessingException catch (error) {
      _error = error.message;
      return null;
    } catch (_) {
      _error = 'Não foi possível processar a imagem.';
      return null;
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }
}
