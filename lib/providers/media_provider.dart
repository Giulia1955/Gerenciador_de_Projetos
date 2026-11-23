import 'dart:io';

import 'package:flutter/foundation.dart';

import '../repositories/storage_repository.dart';

class MediaProvider extends ChangeNotifier {
  MediaProvider({required this.repository});
  final StorageRepository repository;
  bool _uploading = false;
  String? _error;
  bool get isUploading => _uploading;
  String? get errorMessage => _error;

  Future<String?> upload(
      {required String uid,
      required String projectId,
      required File file}) async {
    _uploading = true;
    _error = null;
    notifyListeners();
    try {
      return await repository.uploadProjectImage(
          uid: uid, projectId: projectId, file: file);
    } catch (error) {
      _error = error.toString();
      return null;
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }
}
