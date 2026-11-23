import 'package:cloud_firestore/cloud_firestore.dart';

import 'project_location.dart';

DateTime? _dateTimeFromValue(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toUtc();
  if (value is DateTime) return value.toUtc();
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  throw ArgumentError.value(
      value, 'date', 'must be Timestamp, DateTime, num, or null');
}

Timestamp? _timestampFromDateTime(DateTime? value) {
  return value == null ? null : Timestamp.fromDate(value);
}

class Project {
  const Project({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.dueDate,
    this.imageUrls = const [],
    this.location,
    this.updatedAt,
    this.createdAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final DateTime? dueDate;
  final List<String> imageUrls;
  final ProjectLocation? location;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  factory Project.fromMap(Map<String, dynamic> map) {
    final rawImageUrls = map['imageUrls'];
    final imageUrls = rawImageUrls is Iterable
        ? rawImageUrls.whereType<String>().toList(growable: false)
        : <String>[];

    final rawLocation = map['location'];

    return Project(
      id: map['id'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      dueDate: _dateTimeFromValue(map['dueDate']),
      imageUrls: imageUrls,
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
        'imageUrls': imageUrls,
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
    List<String>? imageUrls,
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
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Project) return false;
    if (other.imageUrls.length != imageUrls.length) return false;
    for (var i = 0; i < imageUrls.length; i++) {
      if (other.imageUrls[i] != imageUrls[i]) return false;
    }

    return other.id == id &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.location == location &&
        other.updatedAt == updatedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, ownerId, name, description, dueDate,
      Object.hashAll(imageUrls), location, updatedAt, createdAt);
}
