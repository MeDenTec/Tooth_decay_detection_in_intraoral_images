// ignore_for_file: prefer_const_constructors
import 'model.dart';
import 'package:firebase_core/firebase_core.dart'; // Import the Firebase Core package
import 'package:dmft_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'home.dart'; // Import the HomePage
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter/services.dart';

// import 'login.dart'; // Import the LoginScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await loadModel();
  print(objectModel);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: createMaterialColor(
            Color.fromARGB(255, 209, 237, 255)), // Use a custom MaterialColor
      ),
      home: HomePage(), // Set HomePage as the initial screen
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (209 - r)) * ds).round(),
        g + ((ds < 0 ? g : (237 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        0.2,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
