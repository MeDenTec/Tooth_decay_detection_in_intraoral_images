import 'package:dmft_app/login.dart';
import 'package:flutter/material.dart';
import 'package:dmft_app/utils.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  void initState() {
    super.initState();
    getConfidence();
  }

  var conf_value;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confidenceController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  void _setConfidence() {
    if (_confidenceController.text.isNotEmpty) {
      var confidence = double.parse(_confidenceController.text);
      if (confidence < 0.1 || confidence > 0.9) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Confidence Value'),
              content:
                  const Text('Confidence value should be between 0.1 and 0.9'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
      final confidence_dict = {
        'confidence': confidence,
      };
      dumpConfidence(confidence_dict, context);
      _confidenceController.clear();
      getConfidence();
    }
  }

  void getConfidence() async {
    var confidence = await fetchConfidence();
    setState(() {
      conf_value = confidence.toString();
    });
  }

  void _authenticate(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    bool isAuthenticated = await signUpEmailPassword(
        _emailController.text, _passwordController.text);

    setState(() {
      _isLoading = false;
    });

    await dumpData(_nameController.text, _emailController.text);
    if (isAuthenticated) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('user created successfully'),
            content: const Text('user created successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Authentication Failed'),
            content: const Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1EDFF),
      body: SingleChildScrollView(
        // Added SingleChildScrollView for scrolling
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center content horizontally
            children: <Widget>[
              // Logo Image
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/teeth5.png',
                width: 100.0,
                height: 100.0,
              ),
              const SizedBox(height: 60),
              // Title
              const Text(
                'Register Doctor',
                style: TextStyle(
                  fontSize: 32,
                  color: Color(0xFF109CCF),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              // Password Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: TextButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Text(
                      _obscureText ? 'Show' : 'Hide',
                      style: const TextStyle(color: Color(0xFF109CCF)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Signup Button
              ElevatedButton(
                onPressed: () {
                  // Handle forgot password action

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => PatientScreen()),
                  // );
                  _authenticate(context);
                },
                child: const Text(
                  'Signup',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: const Color(0xFF109CCF),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
              // Forgot Password Button

              Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                child: TextField(
                  controller: _confidenceController,
                  decoration: InputDecoration(
                    hintText: conf_value,
                    hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _setConfidence();
                },
                child: const Text(
                  'Update',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: const Color(0xFF109CCF),
                  minimumSize: const Size(double.infinity, 32),
                ),
              ),
              TextButton(
                onPressed: () {
                  signOut();
                  // Handle forgot password action
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFF109CCF)),
                ),
              ),
              SizedBox(height: 16),
              
            ],
          ),
        ),
      ),
    );
  }
}
