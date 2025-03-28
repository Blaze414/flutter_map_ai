# 🗺️ Smart Walking Navigator (Flutter Map App)

A Flutter-based smart navigation app designed for seamless and privacy-friendly walking navigation using **OpenStreetMap**, **FlutterMap**, and open-source services like **Nominatim** for geocoding and routing. The UI and UX are inspired by Google Maps with real-time location, destination search, and dynamic routing.

---

## 🚀 Features Implemented

### ✅ Core Functionality
- **Live Location Tracking**  
  Detects and displays the user’s current location using the `geolocator` package.

- **Search with Geocoding**  
  Supports free-text address searches powered by [Nominatim (OpenStreetMap)](https://nominatim.org/). Converts addresses into map coordinates.

- **Routing and Path Drawing**  
  Automatically calculates and draws a route between your current location and searched destination using `flutter_map`.

- **Dynamic Distance & Duration**  
  Displays estimated walking time and distance on a bottom card.

- **Interactive UI**  
  Includes a polished search bar with animation, a floating location button, and interactive markers on the map.

- **Dark / Light Map Themes**  
  Automatically switches between dark and light tile styles based on user preference (via `UserPreferences` model).

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point with Provider setup
├── models/
│   └── user_preferences.dart      # Manages dark mode and user settings
├── providers/
│   └── search_provider.dart       # Centralized destination state (coming soon)
├── services/
│   ├── geocoding_service.dart     # Nominatim-based address lookup
│   ├── location_service.dart      # Geolocator wrapper
│   └── route_service.dart         # Open route logic
├── ui/
│   ├── home_page.dart             # Home UI with live location & search
│   └── map_page.dart              # Map UI with routing and navigation
```

---

## 📌 Tech Stack

- **Flutter**
- **flutter_map** for rendering OSM maps
- **latlong2** for coordinate calculations
- **geolocator** for accessing GPS location
- **http** for making geocoding API calls
- **Provider** for state management
- **Hive (optional)** for local persistence

---

## 🔮 Future Features (Planned)

- 🔎 **Autocomplete Address Suggestions**  
  Integrate with [Photon](https://photon.komoot.io/) or LocationIQ for free suggestion APIs.

- ❤️ **Favorites & Recent Destinations**  
  Allow saving favorite locations and viewing recent searches using local storage (Hive).

- 📥 **Offline Caching**  
  Cache tiles and routes for offline access.

- 🧭 **Turn-by-Turn Navigation (Coming Soon)**  
  Step-by-step navigation instructions for pedestrians.

- 🎨 **Map UI Enhancements**
    - Animated category buttons: Restaurants, Train Stations, Cafes, etc.
    - Search bar overlay that transitions smoothly between Home and Map screens
    - Expandable route info card with directions list

- 🔒 **Permissions & Safety**  
  Improve user prompts and fallback behavior for denied permissions.

---

## 📱 How to Run

1. Clone the repo:
   ```bash
   git clone https://github.com/blaze414/flutter_map_ai.git
   cd flutter_map_ai
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run on your device:
   ```bash
   flutter run
   ```

---

## 🤝 Contributions

This project is actively evolving. PRs, feature requests, and feedback are welcome!  
Let’s build a privacy-first, smart navigation app together 🌍.

---

## 📧 Contact

Feel free to reach out for feedback, collaborations, or questions.  
**Maintainer**: Al Zadid Yusuf 
**Email**: yusufalzadid@gmail.com
