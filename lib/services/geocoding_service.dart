// services/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static Future<LatLng?> searchLocation(String query) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1");

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterMapApp/1.0 (yusufalzadid@gmail.com)' // Required by Nominatim
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }

    return null;
  }
}
