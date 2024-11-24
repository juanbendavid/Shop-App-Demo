import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as locationA;

class GoogleMapsController {
  Future<bool> requestLocationPermission() async {
  final PermissionStatus status = await Permission.location.request();

  if (status == PermissionStatus.granted) {
    return true;
  } else if (status == PermissionStatus.denied) {
    // Si está denegado, solicita permisos nuevamente.
    final PermissionStatus retryStatus = await Permission.location.request();
    return retryStatus == PermissionStatus.granted;
  } else if (status == PermissionStatus.permanentlyDenied) {
    // Si está denegado permanentemente, redirige a la configuración.
    await openAppSettings();
    return false;
  }

  return false;
}


  Future<locationA.LocationData?> getCurrentLocation() async {
    locationA.Location location = locationA.Location();
    bool hasPermission = await requestLocationPermission();

    if (hasPermission) {
      return await location.getLocation();
    } else {
      print(" Permiso no concecido ");
      return null;
    }
  }
}

