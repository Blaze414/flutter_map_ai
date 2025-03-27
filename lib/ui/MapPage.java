import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/route_service.dart';
import '../models/user_preferences.dart';
import '../services/geocoding_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];
  double _distanceKm = 0;
  int _durationMin = 0;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation!, 15.0);
    }
  }

  Future<void> _handleSearch(String query) async {
    setState(() => _isSearching = true);
    final result = await GeocodingService.searchLocation(query);
    setState(() => _isSearching = false);

    if (result != null && _currentLocation != null) {
      setState(() {
        _destination = result;
      });
      _mapController.move(result, 15.0);
      _generateRoute();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Destination not found.")),
      );
    }
  }

  Future<void> _generateRoute() async {
    if (_currentLocation != null && _destination != null) {
      final route = await RouteService.getRoute(_currentLocation!, _destination!);
      final totalDistance = Distance().as(LengthUnit.Kilometer, _currentLocation!, _destination!);
      final estimatedDuration = (totalDistance / 4.8 * 60).round(); // avg walk speed

      setState(() {
        _route = route;
        _distanceKm = totalDistance;
        _durationMin = estimatedDuration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<UserPreferences>().isDarkMode;

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
            urlTemplate: isDarkMode
            ? 'https://tiles.stadiamaps.com/tiles/alidade_dark/{z}/{x}/{y}{r}.png'
            : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
    retinaMode: true,
              ),
    MarkerLayer(markers: [
    if (_currentLocation != null)
      Marker(
              width: 40,
            height: 40,
            point: _currentLocation!,
            child: Icon(Icons.my_location, size: 40, color: Colors.blue),
                  ),
    if (_destination != null)
      Marker(
              width: 40,
            height: 40,
            point: _destination!,
            child: Icon(Icons.location_on, size: 40, color: Colors.green),
                  ),
              ]),
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

    // 🔍 Search Bar Overlay
    SafeArea(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(30),
            child: TextField(
            controller: _searchController,
            onSubmitted: _handleSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
            hintText: "Search destination...",
            prefixIcon: Icon(Icons.search),
            suffixIcon: _isSearching
            ? Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
                          ),
    border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
          ),

    // 🧭 Info card for distance/time
    if (_route.isNotEmpty)
      Align(
              alignment: Alignment.bottomCenter,
            child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
                ),
    child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
    Row(
            children: [
    Icon(Icons.timer, color: Colors.black54),
    SizedBox(width: 8),
    Text("$_durationMin min"),
                      ],
                    ),
    Row(
            children: [
    Icon(Icons.map, color: Colors.black54),
    SizedBox(width: 8),
    Text("${_distanceKm.toStringAsFixed(1)} km"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

    // 📍 Locate Button
    Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
            onPressed: _determinePosition,
            backgroundColor: Colors.white,
            child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
