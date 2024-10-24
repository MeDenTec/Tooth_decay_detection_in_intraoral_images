import 'package:flutter/material.dart';
import 'package:dmft_app/login.dart';
import 'package:dmft_app/utils.dart';

// ignore: must_be_immutable
class RegisterSchoolScreen extends StatefulWidget {
  RegisterSchoolScreen({Key? key, required this.doctorName}) : super(key: key);
  final String doctorName;

  @override
  _RegisterSchoolScreenState createState() => _RegisterSchoolScreenState();
}

class _RegisterSchoolScreenState extends State<RegisterSchoolScreen> {
  // create a dictionary
  Map<String, String> schoolData = {
    'school_name': '',
    'school_address': '',
    'school_id': '',
  };

  // create controllers for text editing fields
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  bool isAuthenticated = false;
  bool isLoading = false;

  void _authenticate(
      BuildContext context, schoolData, bool isAuthenticated) async {
    if (isAuthenticated) {
      setState(() {
        isLoading = true;
      });

      var school_id = await dumpschoolData(schoolData, context);

      setState(() {
        isLoading = false;
      });
      if(school_id == "Failed"){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Registration Failed'),
              content: const Text('School already exists.'),
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
      }else{
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text('School has been registered successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Failed'),
            content: const Text('Please fill all the fields.'),
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
      backgroundColor: Color.fromARGB(255, 209, 237, 255),
      body: Container(
        decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 209, 237, 255),
                    Color.fromARGB(255, 115, 200, 253),
                  ],
                ),
              ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          signOut();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF109CCF),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                        child: Text(
                          'Logged in as\n${widget.doctorName}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF109CCF),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    child: Image.asset(
                      'assets/images/teeth5.png',
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Register New school',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF109CCF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  alignment: Alignment.center,
                  width: 350.0,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'School Name',
                          hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: 'School Address',
                          hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFF109CCF)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 45, vertical: 15),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFF109CCF)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              schoolData['school_name'] = nameController.text;
                              schoolData['school_address'] =
                                  addressController.text;

                              if (schoolData['school_name'] == '' ||
                                  schoolData['school_address'] == '') {
                                isAuthenticated = false;
                              } else {
                                isAuthenticated = true;
                              }

                              _authenticate(
                                  context, schoolData, isAuthenticated);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              backgroundColor: Color(0xFF109CCF),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors
                                        .white)) // Show loader if isLoading is true
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
