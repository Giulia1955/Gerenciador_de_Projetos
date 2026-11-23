import 'package:cloud_firestore/cloud_firestore.dart';

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

class ProjectTask {
  const ProjectTask({
    required this.id,
    required this.name,
    this.description,
    this.assigneeName,
    this.dueDate,
    this.completed = false,
    this.updatedAt,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? assigneeName;
  final DateTime? dueDate;
  final bool completed;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  factory ProjectTask.fromMap(Map<String, dynamic> map) {
    return ProjectTask(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      assigneeName: map['assigneeName'] as String?,
      dueDate: _dateTimeFromValue(map['dueDate']),
      completed: map['completed'] as bool? ?? false,
      updatedAt: _dateTimeFromValue(map['updatedAt']),
      createdAt: _dateTimeFromValue(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'assigneeName': assigneeName,
        'dueDate': _timestampFromDateTime(dueDate),
        'completed': completed,
        'updatedAt': _timestampFromDateTime(updatedAt),
        'createdAt': _timestampFromDateTime(createdAt),
      };

  ProjectTask copyWith({
    String? id,
    String? name,
    String? description,
    String? assigneeName,
    DateTime? dueDate,
    bool? completed,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      assigneeName: assigneeName ?? this.assigneeName,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectTask &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.assigneeName == assigneeName &&
        other.dueDate == dueDate &&
        other.completed == completed &&
        other.updatedAt == updatedAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, description, assigneeName, dueDate,
      completed, updatedAt, createdAt);
}
