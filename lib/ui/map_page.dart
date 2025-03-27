import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/route_service.dart';
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
      final duration = (distance / 4.8 * 60).round(); // 4.8km/h walking speed

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
                urlTemplate: isDark
                    ? 'https://tiles.stadiamaps.com/tiles/alidade_dark/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                      child: Icon(Icons.my_location, color: Colors.blue, size: 40),
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
                      strokeWidth: 4.5,
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
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.timer, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text("$_durationMin min"),
                    ]),
                    Row(children: [
                      Icon(Icons.directions_walk, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text("${_distanceKm.toStringAsFixed(1)} km"),
                    ]),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              onPressed: _setupNavigation,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}