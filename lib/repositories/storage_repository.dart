import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  StorageRepository(this._storage);
  final FirebaseStorage _storage;

  Future<String> uploadProjectImage(
      {required String uid,
      required String projectId,
      required File file}) async {
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final ref = _storage.ref('projects/$uid/$projectId/images/$fileName');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> deleteProjectFolder(String uid, String projectId) async {
    final prefix = _storage.ref('projects/$uid/$projectId/images');
    final result = await prefix.listAll();
    await Future.wait(result.items.map((item) => item.delete()));
  }
}
