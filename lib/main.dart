import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/home_page.dart';
import '../models/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  UserPreferences userPreferences = UserPreferences();
  await userPreferences.initialize(); // ✅ Wait for preferences to load

  runApp(MyApp(userPreferences));
}

class MyApp extends StatelessWidget {
  final UserPreferences userPreferences;
  const MyApp(this.userPreferences, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: userPreferences, // ✅ Pass initialized preferences
      child: Consumer<UserPreferences>(
        builder: (context, preferences, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Walking Navigator',
            theme: preferences.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: HomePage(),
          );
        },
      ),
    );
  }
}
