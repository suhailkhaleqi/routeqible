import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> hasLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}
