class ProjectLocation {
  ProjectLocation({
    required this.latitude,
    required this.longitude,
    this.label,
  }) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw ArgumentError.value(
          latitude, 'latitude', 'must be between -90 and 90');
    }
    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw ArgumentError.value(
          longitude, 'longitude', 'must be between -180 and 180');
    }
  }

  final double latitude;
  final double longitude;
  final String? label;

  factory ProjectLocation.fromMap(Map<String, dynamic> map) {
    final latitude = map['latitude'];
    final longitude = map['longitude'];
    if (latitude is! num) {
      throw ArgumentError.value(latitude, 'latitude', 'must be a number');
    }
    if (longitude is! num) {
      throw ArgumentError.value(longitude, 'longitude', 'must be a number');
    }

    return ProjectLocation(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      label: map['label'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'label': label,
      };

  ProjectLocation copyWith(
      {double? latitude, double? longitude, String? label}) {
    return ProjectLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, label);
}
