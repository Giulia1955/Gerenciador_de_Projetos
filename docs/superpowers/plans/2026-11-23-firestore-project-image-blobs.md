# Firestore Project Image Blobs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Firebase Storage project images with compressed JPEG Blob values stored directly in each Firestore project document.

**Architecture:** Add `List<Blob> images` to `Project`, process selected files in a pure-Dart image utility using the `image` package, and render previews with `Image.memory`. Remove `StorageRepository`, Firebase Storage initialization, and all project-folder deletion behavior.

**Tech Stack:** Flutter, Dart, Cloud Firestore `Blob`, `image_picker`, `image` package, Provider, `flutter_test`, `fake_cloud_firestore`.

## Global Constraints

- Imagens existentes no Firebase Storage não serão migradas.
- O campo legado `imageUrls` não terá suporte permanente.
- Cada imagem terá no máximo aproximadamente 100 KB.
- Cada imagem será redimensionada para no máximo 600 × 600 pixels e comprimida como JPEG.
- Cada projeto terá no máximo cinco imagens.
- O documento deve manter margem segura do limite de 1 MiB do Firestore.
- Nenhuma implementação deve depender de `firebase_storage`.

---

### Task 1: Change the Project model to Blob images

**Files:**
- Modify: `lib/models/project.dart`
- Modify: `test/models/project_test.dart`

**Interfaces:**
- Consumes: `Blob` values decoded from Firestore.
- Produces: `Project.images`, `Project.toMap()['images']`, and `Project.copyWith(images: ...)`.

- [ ] **Step 1: Update the model test to require Blobs and no URLs**

```dart
test('fromMap and toMap round trip with nested location and image blobs',
    () {
  final due = DateTime.utc(2026, 12, 1, 9);
  final updated = DateTime.utc(2026, 11, 20, 12);
  final created = DateTime.utc(2026, 11, 1, 8);
  final firstImage = Blob.fromBytes(Uint8List.fromList([255, 216, 255, 217]));
  final secondImage = Blob.fromBytes(Uint8List.fromList([0, 1, 2, 3]));
  final project = Project.fromMap({
    'id': 'project-1',
    'ownerId': 'owner-1',
    'name': 'Night Owl App',
    'description': 'Firebase project',
    'dueDate': Timestamp.fromDate(due),
    'images': [firstImage, secondImage],
    'location': {
      'latitude': -23.5505,
      'longitude': -46.6333,
      'label': 'São Paulo'
    },
    'updatedAt': Timestamp.fromDate(updated),
    'createdAt': Timestamp.fromDate(created),
  });

  expect(project.images, [firstImage, secondImage]);

  final mapped = project.toMap();
  expect(mapped['images'], [firstImage, secondImage]);
  expect(mapped.containsKey('imageUrls'), isFalse);
  expect(Project.fromMap(mapped), project);
});

test('ignores legacy imageUrls and returns an empty image list', () {
  final project = Project.fromMap({
    'id': 'project-2',
    'ownerId': 'owner-2',
    'name': 'Project',
    'imageUrls': ['https://example.com/old-image.jpg'],
  });

  expect(project.images, isEmpty);
  expect(project.toMap().containsKey('imageUrls'), isFalse);
});
```

Update imports to include `dart:typed_data`.

- [ ] **Step 2: Run the model test and verify it fails**

Run: `flutter test test/models/project_test.dart`
Expected: FAIL because `Project.images`, `Blob`, or the new constructor behavior do not exist yet.

- [ ] **Step 3: Replace `imageUrls` in `Project`**

In `lib/models/project.dart`:

```dart
import 'dart:typed_data';

class Project {
  const Project({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.dueDate,
    this.images = const [],
    this.location,
    this.updatedAt,
    this.createdAt,
  });

  final List<Blob> images;

  factory Project.fromMap(Map<String, dynamic> map) {
    final rawImages = map['images'];
    final images = rawImages is Iterable
        ? rawImages.whereType<Blob>().toList(growable: false)
        : <Blob>[];

    return Project(
      id: map['id'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      dueDate: _dateTimeFromValue(map['dueDate']),
      images: images,
      location: rawLocation is Map<String, dynamic>
          ? ProjectLocation.fromMap(rawLocation)
          : null,
      updatedAt: _dateTimeFromValue(map['updatedAt']),
      createdAt: _dateTimeFromValue(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'description': description,
        'dueDate': _timestampFromDateTime(dueDate),
        'images': images,
        'location': location?.toMap(),
        'updatedAt': _timestampFromDateTime(updatedAt),
        'createdAt': _timestampFromDateTime(createdAt),
      };

  Project copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    DateTime? dueDate,
    List<Blob>? images,
    ProjectLocation? location,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      images: images ?? this.images,
      location: location ?? this.location,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

Replace equality and hash-code `imageUrls` comparisons with `images` comparisons.

- [ ] **Step 4: Run the model test and verify it passes**

Run: `flutter test test/models/project_test.dart`
Expected: PASS; all project image URL fields are replaced by Blob fields.

- [ ] **Step 5: Commit**

Run:
```bash
git add lib/models/project.dart test/models/project_test.dart
git commit -m "feat: store project images as firestore blobs"
```

---

### Task 2: Add pure-Dart JPEG image compression

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/utils/project_image_processor.dart`
- Create: `test/utils/project_image_processor_test.dart`

**Interfaces:**
- Consumes: `Uint8List originalBytes`.
- Produces: `Uint8List jpegBytes` or `ProjectImageProcessingException`.
- Constants: `maximumImageBytes = 100 * 1024`, `maximumImageDimension = 600`.

- [ ] **Step 1: Add the failing processor tests**

```dart
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
    expect(img.decodeImage(result)?.format, img.Format.jpeg);
  });

  test('rejects data that cannot be decoded as an image', () {
    expect(
      () => ProjectImageProcessor.compress(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<ProjectImageProcessingException>()),
    );
  });
}
```

- [ ] **Step 2: Add `image` as a dependency and fetch packages**

Add to `pubspec.yaml`:

```yaml
  image: ^4.13.1
```

Run: `flutter pub get`

- [ ] **Step 3: Run the processor test and verify it fails**

Run: `flutter test test/utils/project_image_processor_test.dart`
Expected: FAIL because `project_image_processor.dart` does not exist.

- [ ] **Step 4: Implement the processor**

```dart
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
```

- [ ] **Step 5: Run the processor test and verify it passes**

Run: `flutter test test/utils/project_image_processor_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

Run:
```bash
git add pubspec.yaml pubspec.lock lib/utils/project_image_processor.dart test/utils/project_image_processor_test.dart
git commit -m "feat: add project image compression"
```

---

### Task 3: Replace MediaProvider Storage uploads with Blob processing

**Files:**
- Modify: `lib/providers/media_provider.dart`
- Modify: `test/providers/media_provider_test.dart` (create if absent)

**Interfaces:**
- Consumes: `Uint8List` selected image bytes.
- Produces: `Blob?` and an error message.
- Removes: `StorageRepository`, `uid`, `projectId`, and `dart:io`.

- [ ] **Step 1: Create the failing provider test**

```dart
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
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `flutter test test/providers/media_provider_test.dart`
Expected: FAIL because `MediaProvider` still requires `StorageRepository` and has no `process` method.

- [ ] **Step 3: Replace the provider implementation**

```dart
import 'dart:typed_data';

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
      return Blob.fromBytes(compressed);
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
```

- [ ] **Step 4: Run the test and verify it passes**

Run: `flutter test test/providers/media_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

Run:
```bash
git add lib/providers/media_provider.dart test/providers/media_provider_test.dart
git commit -m "feat: convert project images to firestore blobs"
```

---

### Task 4: Update project forms and details to use Blob previews

**Files:**
- Modify: `lib/view/project_form_page.dart`
- Modify: `lib/view/project_detail_page.dart`
- Modify: `test/view/project_form_page_test.dart` (if present)
- Modify: `test/view/project_detail_page_test.dart` (if present)

**Interfaces:**
- Consumes: `List<Blob>` from `Project`.
- Produces: `Project(images: ...)` in create/update submissions.
- Preview: `Image.memory(blob.bytes, ...)`.

- [ ] **Step 1: Update form state and submission fields**

In `project_form_page.dart`, replace:

```dart
late List<String> _imageUrls;
```

with:

```dart
late List<Blob> _images;
```

Initialize:

```dart
_images = List<Blob>.from(widget.project?.images ?? const []);
```

Submit:

```dart
images: List<Blob>.from(_images),
```

- [ ] **Step 2: Replace image selection logic**

When `ImagePicker` returns a file:

```dart
final bytes = await file.readAsBytes();
final blob = context.read<MediaProvider>().process(bytes);
if (!mounted) return;
if (blob == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        context.read<MediaProvider>().errorMessage ??
            'Falha ao processar a imagem',
      ),
    ),
  );
  return;
}
setState(() => _images = [..._images, blob]);
```

Keep `_images.length >= 5` as the five-image limit.

- [ ] **Step 3: Replace preview widgets**

Form preview:

```dart
for (final blob in _images)
  Image.memory(
    blob.bytes,
    width: 100,
    height: 100,
    fit: BoxFit.cover,
  )
```

Removal:

```dart
setState(() => _images.remove(blob));
```

Detail preview:

```dart
for (final blob in project.images)
  Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        blob.bytes,
        width: 220,
        fit: BoxFit.cover,
      ),
    ),
  )
```

- [ ] **Step 4: Add or update widget expectations**

Where tests inspect project images, use `Blob.fromBytes(Uint8List...)` and expect `Image.memory` or the absence of `Image.network`.

- [ ] **Step 5: Run focused tests**

Run: `flutter test test/view`
Expected: PASS or identify each outdated URL expectation before proceeding.

- [ ] **Step 6: Commit**

Run:
```bash
git add lib/view/project_form_page.dart lib/view/project_detail_page.dart test/view
git commit -m "feat: render project firestore blob images"
```

---

### Task 5: Remove Firebase Storage from providers and dependency setup

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/providers/project_provider.dart`
- Modify: `lib/repositories/storage_repository.dart` (delete)
- Modify: `pubspec.yaml`
- Modify: `test/providers/project_provider_test.dart`

**Interfaces:**
- Removes: `StorageRepository`, `FirebaseStorage.instance`, `deleteProjectFolder`, and `storageRepository` constructor dependencies.
- Preserves: project create, update, delete, and Firestore subscriptions.

- [ ] **Step 1: Update provider and main tests to require no Storage dependency**

In project provider tests, remove constructor arguments named `storageRepository` if present and keep repository/auth-only construction.

- [ ] **Step 2: Run provider tests and verify they fail before cleanup**

Run: `flutter test test/providers/project_provider_test.dart`
Expected: PASS initially may not fail; proceed to a source check rather than relying on behavior alone:

Run: `grep -R "firebase_storage\|StorageRepository\|FirebaseStorage" -n lib test pubspec.yaml`
Expected: existing matches before cleanup.

- [ ] **Step 3: Remove Storage wiring**

`lib/main.dart`:

- Remove `firebase_storage` import.
- Remove `storage_repository.dart` import.
- Remove `Provider<StorageRepository>`.
- Remove `storageRepository:` from `ProjectProvider`.
- Construct `MediaProvider` with `MediaProvider()`.

`lib/providers/project_provider.dart`:

- Remove the `storage_repository.dart` import.
- Remove `StorageRepository? storageRepository` from constructor parameters and `_storageRepository` field.
- Remove `_storageRepository?.deleteProjectFolder(...)` from `deleteProject`.

- [ ] **Step 4: Remove dependencies and repository file**

Remove `firebase_storage` from `pubspec.yaml`.

Run:
```bash
rm lib/repositories/storage_repository.dart
flutter pub get
```

- [ ] **Step 5: Verify no Storage references remain in application code**

Run:
```bash
grep -R "firebase_storage\|StorageRepository\|FirebaseStorage" -n lib test pubspec.yaml || true
```

Expected: no matches.

- [ ] **Step 6: Run provider tests**

Run: `flutter test test/providers/project_provider_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

Run:
```bash
git add lib/main.dart lib/providers/project_provider.dart lib/repositories/storage_repository.dart pubspec.yaml pubspec.lock test/providers/project_provider_test.dart
git rm lib/repositories/storage_repository.dart
git commit -m "refactor: remove firebase storage usage"
```

---

### Task 6: Add repository and provider Blob round-trip coverage

**Files:**
- Modify: `test/repositories/project_repository_test.dart`
- Modify: `test/providers/project_provider_test.dart`

- [ ] **Step 1: Add a repository test with real Blob values**

```dart
import 'dart:typed_data';

final image = Blob.fromBytes(Uint8List.fromList([255, 216, 255, 217]));
const project = Project(
  id: 'project-blob',
  ownerId: 'uid-1',
  name: 'Blob project',
  images: [],
);
await repository.createProject(
  'uid-1',
  project.copyWith(images: [image]),
);

final stored = (await repository.watchProjects('uid-1').first).single;
expect(stored.images.single.bytes, image.bytes);
```

- [ ] **Step 2: Run the repository test and verify it passes**

Run: `flutter test test/repositories/project_repository_test.dart`
Expected: PASS if `Project.fromMap` correctly converts Blob values.

- [ ] **Step 3: Add provider create/delete Blob coverage**

Create a project through `ProjectProvider` with one Blob and confirm `watchProjects` contains the same bytes.

Delete the project and confirm it is removed without calling Firebase Storage.

- [ ] **Step 4: Run provider tests**

Run: `flutter test test/providers/project_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

Run:
```bash
git add test/repositories/project_repository_test.dart test/providers/project_provider_test.dart
git commit -m "test: cover firestore blob project round trips"
```

---

### Task 7: Remove Storage rules and verify the complete migration

**Files:**
- Remove: `storage.rules`
- Modify: `firebase.json` (remove Storage rules reference if present)
- Modify: project documentation if it mentions Firebase Storage

- [ ] **Step 1: Remove any Storage configuration reference**

Inspect `firebase.json`. Remove the `storage` entry if present:

```bash
grep -n "storage" firebase.json storage.rules pubspec.yaml lib test || true
```

Delete `storage.rules` only if no deployment or emulator configuration references it.

- [ ] **Step 2: Run full static and test verification**

Run:
```bash
flutter analyze
flutter test
```

Expected: no analyzer issues and all tests pass.

- [ ] **Step 3: Verify source cleanup**

Run:
```bash
grep -R "imageUrls\|firebase_storage\|FirebaseStorage\|StorageRepository\|Image\.network" -n lib test pubspec.yaml || true
```

Expected: no matches. `Image.network` may remain elsewhere only if intentionally unrelated to project images.

- [ ] **Step 4: Review the diff**

Run:
```bash
git diff --stat
git diff --check
git diff -- lib/models/project.dart lib/providers/media_provider.dart lib/view/project_form_page.dart lib/view/project_detail_page.dart
```

Expected: only migration-related changes and no accidental removal of unrelated login or workspace edits.

- [ ] **Step 5: Commit**

Run:
```bash
git add firebase.json storage.rules lib test pubspec.yaml pubspec.lock docs
git commit -m "chore: complete firestore blob image migration"
```

- [ ] **Step 6: Final verification**

Run:
```bash
flutter analyze && flutter test
```

Expected: complete success before declaring the migration complete.
