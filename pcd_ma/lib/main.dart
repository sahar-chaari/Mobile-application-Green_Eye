// main.dart
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'registration.dart';
import 'green_eye_screen .dart';
import 'user_profil_page.dart';
import 'weather_page.dart'; // ✅ Add this line

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Disease Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/green_eye',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => RegisterPage());
          case '/green_eye':
            return MaterialPageRoute(builder: (_) => GreenEye());
          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => HomePage(userId: args['userId']),
            );
          case '/profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => UserProfilePage(userId: args['userId']),
            );
          case '/weather': // ✅ New case for weather
            return MaterialPageRoute(builder: (_) => WeatherPage());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text("No route defined for ${settings.name}"), // fixed interpolation
                ),
              ),
            );
        }
      },
    );
  }
}