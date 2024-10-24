import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import 'package:dmft_app/login.dart'; // Import your login screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Set a timer to navigate to LoginScreen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Right to left dissolve animation
            const begin = Offset(1.0, 0.0); // Start from the right
            const end = Offset.zero; // End at the center
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 209, 237, 255), // Red background color
      body: Stack(
        children: <Widget>[
          // Centered logo
          Center(
            child: Image.asset(
              'assets/images/medentec.png', // Ensure you have a logo in the assets folder
              width: 300.0, // Adjust size as needed
              height: 300.0,
            ),
          ),
          // Icons in various corners
          Positioned(
            top: 90.0,
            right: 30.0,
            child: Image.asset(
              'assets/images/teeth5.png', // Ensure you have a logo in the assets folder
              width: 100.0, // Adjust size as needed
              height: 100.0,
            ),
          ),
          Positioned(
            top: 250.0,
            left: 30.0,
            child: Image.asset(
              'assets/images/teeth4.png', // Ensure you have a logo in the assets folder
              width: 100.0, // Adjust size as needed
              height: 100.0,
            ),
          ),
          Positioned(
            bottom: 400.0,
            right: 20.0,
            child: Image.asset(
              "assets/images/teeth1.png", // Ensure you have a logo in the assets folder
              width: 100.0, // Adjust size as needed
              height: 100.0,
            ),
          ),
          Positioned(
            bottom: 40.0,
            right: 20.0,
            child: Image.asset(
              'assets/images/teeth2.png', // Ensure you have a logo in the assets folder
              width: 100.0, // Adjust size as needed
              height: 100.0,
            ),
          ),
          Positioned(
            bottom: 200.0,
            left: 20.0,
            child: Image.asset(
              'assets/images/teeth3.png', // Ensure you have a logo in the assets folder
              width: 100.0, // Adjust size as needed
              height: 100.0,
            ),
          ),
        ],
      ),
    );
  }
}
