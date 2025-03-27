import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/geocoding_service.dart';
import '../ui/map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();
  final TextEditingController _controller = TextEditingController();
  LatLng? _currentLocation;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() => _currentLocation = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_currentLocation!, 15);
    }
  }

  void _searchAndNavigate() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final destination = await GeocodingService.searchLocation(query);
    setState(() => _isSearching = false);

    if (destination != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapPage(destination: destination),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                ],
              ),
            ],
          ),

          // Search bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchAndNavigate(),
                        decoration: InputDecoration(
                          hintText: "Search for a place...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: _searchAndNavigate,
                        child: CircleAvatar(
                          backgroundColor: Colors.green.shade600,
                          child: _isSearching
                              ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // Location button
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
