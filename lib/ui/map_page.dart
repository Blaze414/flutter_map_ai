import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/route_service.dart';
import 'settings_page.dart';
import '../models/user_preferences.dart';
import '../services/location_service.dart';

class MapPage extends StatefulWidget {
  final LatLng destination;

  const MapPage({required this.destination, super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<LatLng> _route = [];
  double _distanceKm = 0;
  int _durationMin = 0;

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  Future<void> _setupNavigation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      final route = await RouteService.getRoute(_currentLocation!, widget.destination);
      final distance = Distance().as(LengthUnit.Kilometer, _currentLocation!, widget.destination);
      final duration = (distance / 4.8 * 60).round();

      setState(() {
        _route = route;
        _distanceKm = distance;
        _durationMin = duration;
      });

      _mapController.move(widget.destination, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<UserPreferences>().isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? LatLng(-37.8136, 144.9631),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                retinaMode: true,
              ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
                    ),
                  Marker(
                    point: widget.destination,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.flag, color: Colors.green, size: 40),
                  ),
                ],
              ),
              if (_route.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route,
                      strokeWidth: 4.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
            ],
          ),

          if (_route.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black87 : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.timer, color: Colors.grey.shade700),
                      SizedBox(width: 8),
                      Text("$_durationMin min"),
                    ]),
                    Row(children: [
                      Icon(Icons.directions_walk, color: Colors.grey.shade700),
                      SizedBox(width: 8),
                      Text("${_distanceKm.toStringAsFixed(1)} km"),
                    ]),
                  ],
                ),
              ),
            ),

          // Locate me
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              onPressed: _setupNavigation,
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
              child: Icon(Icons.my_location, color: isDark ? Colors.white : Colors.black),
            ),
          ),

          // Settings icon
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.settings, color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}