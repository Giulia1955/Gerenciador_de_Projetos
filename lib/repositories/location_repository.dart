import 'package:geolocator/geolocator.dart';

import '../models/project_location.dart';

class LocationRepository {
  Future<ProjectLocation> currentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw StateError('Serviço de localização desativado');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('Permissão de localização negada');
    }

    final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium));
    return ProjectLocation(
        latitude: position.latitude, longitude: position.longitude);
  }
}
