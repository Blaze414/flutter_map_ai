import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

class StorageService {
  static Future<void> saveRoute(List<LatLng> route) async {
    var box = await Hive.openBox('appData');
    List<List<double>> routeData = route.map((latlng) => [latlng.latitude, latlng.longitude]).toList();
    await box.put('cachedRoute', routeData);
  }

  static Future<List<LatLng>> loadRoute() async {
    var box = await Hive.openBox('appData');
    List<dynamic>? storedData = box.get('cachedRoute');
    if (storedData != null) {
      return storedData.map<LatLng>((c) => LatLng(c[0], c[1])).toList();
    }
    return [];
  }
}
