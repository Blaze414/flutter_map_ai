import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var preferences = Provider.of<UserPreferences>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Dark Mode"),
              value: preferences.isDarkMode,
              onChanged: (value) => preferences.setDarkMode(value),
            ),
            SizedBox(height: 20),
            Text("Route Preference", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: preferences.routePreference,
              onChanged: (value) => preferences.setRoutePreference(value!),
              items: ["Fastest", "Scenic", "Avoid Stairs"].map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
