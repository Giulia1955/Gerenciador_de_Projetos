import 'dart:typed_data';

import 'package:apk_auth/models/project.dart';
import 'package:apk_auth/models/project_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectLocation', () {
    test('fromMap and toMap round trip', () {
      final location = ProjectLocation.fromMap({
        'latitude': -23.5505,
        'longitude': -46.6333,
        'label': 'Campus',
      });

      expect(location.latitude, -23.5505);
      expect(location.longitude, -46.6333);
      expect(location.label, 'Campus');
      expect(ProjectLocation.fromMap(location.toMap()), location);
    });

    test('rejects invalid coordinates', () {
      expect(() => ProjectLocation(latitude: -91, longitude: 0),
          throwsArgumentError);
      expect(() => ProjectLocation(latitude: 0, longitude: 181),
          throwsArgumentError);
      expect(
          () => ProjectLocation.fromMap({'latitude': 'north', 'longitude': 0}),
          throwsArgumentError);
    });
  });

  group('Project', () {
    test('fromMap and toMap round trip with nested location and timestamps',
        () {
      final due = DateTime.utc(2026, 12, 1, 9);
      final updated = DateTime.utc(2026, 11, 20, 12);
      final created = DateTime.utc(2026, 11, 1, 8);
      final project = Project.fromMap({
        'id': 'project-1',
        'ownerId': 'owner-1',
        'name': 'Night Owl App',
        'description': 'Firebase project',
        'dueDate': Timestamp.fromDate(due),
        'location': {
          'latitude': -23.5505,
          'longitude': -46.6333,
          'label': 'São Paulo'
        },
        'updatedAt': Timestamp.fromDate(updated),
        'createdAt': Timestamp.fromDate(created),
      });

      expect(project.id, 'project-1');
      expect(project.ownerId, 'owner-1');
      expect(project.name, 'Night Owl App');
      expect(project.description, 'Firebase project');
      expect(project.dueDate, due);
      expect(project.location?.label, 'São Paulo');
      expect(project.updatedAt, updated);
      expect(project.createdAt, created);

      final mapped = project.toMap();
      expect(mapped['dueDate'], isA<Timestamp>());
      expect(mapped['updatedAt'], isA<Timestamp>());
      expect(mapped['createdAt'], isA<Timestamp>());
      expect(Project.fromMap(mapped), project);
    });

    test('fromMap and toMap round trip with nested location and image blobs',
        () {
      final due = DateTime.utc(2026, 12, 1, 9);
      final updated = DateTime.utc(2026, 11, 20, 12);
      final created = DateTime.utc(2026, 11, 1, 8);
      final firstImage =
          Blob(Uint8List.fromList([255, 216, 255, 217]));
      final secondImage = Blob(Uint8List.fromList([0, 1, 2, 3]));
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
  });
}
