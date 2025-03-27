import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final response = await http.get(Uri.parse(
        "https://router.project-osrm.org/route/v1/walking/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson"));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var coordinates = data["routes"][0]["geometry"]["coordinates"];
      return coordinates.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception("Failed to load route");
    }
  }
}
