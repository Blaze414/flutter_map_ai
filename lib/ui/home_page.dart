// lib/ui/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_ai/ui/settings_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/user_preferences.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;
  LatLng? _currentLocation;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  Future<void> _loadCurrentLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  void _searchAndNavigate() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final destination = await GeocodingService.searchLocation(query);
    setState(() => _isSearching = false);

    if (destination != null && mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MapPage(destination: destination),
          transitionsBuilder: (_, animation, __, child) {
            final offset = Tween(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
            return SlideTransition(position: offset, child: child);
          },
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
    final isDark = context.watch<UserPreferences>().isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          if (_currentLocation != null)
            FlutterMap(
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.my_location, color: Colors.redAccent, size: 36),
                    ),
                  ],
                ),
              ],
            ),

          // Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchAndNavigate(),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: "Search for a place...",
                          hintStyle: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _searchAndNavigate,
                      child: AnimatedBuilder(
                        animation: _fabController,
                        builder: (_, child) {
                          return Transform.scale(
                            scale: 1 + 0.05 * _fabController.value,
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: _isSearching
                                    ? Colors.grey
                                    : (isDark ? Colors.tealAccent[400] : Colors.green),
                                shape: BoxShape.circle,
                              ),
                              child: _isSearching
                                  ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              )
                                  : Icon(Icons.search,
                                  size: 20,
                                  color: isDark ? Colors.black : Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings Icon
          Positioned(
            top: 120,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage()),
                );
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                ),
                child: Icon(Icons.settings, size: 24, color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fabController.dispose();
    super.dispose();
  }
}