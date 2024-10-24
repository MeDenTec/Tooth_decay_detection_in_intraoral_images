import 'package:flutter/material.dart';
import 'package:dmft_app/login.dart';
import 'package:dmft_app/registerPatient.dart';
import 'package:dmft_app/registerSchool.dart';
import 'package:dmft_app/utils.dart';
import 'package:flutter/rendering.dart';

class PatientScreen extends StatefulWidget {
  final String doctorName;
  const PatientScreen({Key? key, required this.doctorName}) : super(key: key);
  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  // write list of four names demo
  List<dynamic> patientNames = []; // List to hold patient names
  late var flag_loader = true;
  @override
  void initState() {
    super.initState();
    fetchPatients(); // Fetch patients when the widget is initialized
  }

  Future<void> fetchPatients() async {
    List<dynamic> fetchedPatients =
        await fetchAllPatients(); // Await the future
    setState(() {
      flag_loader = false;
      patientNames = fetchedPatients; // Update the state with the fetched data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor:
      //     Color.fromARGB(255, 209, 237, 255), // Red background color
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
        child: Column(
          children: [
            const SizedBox(height: 25), // Added some space from the top
            Stack(
              alignment: Alignment.center, // Centers the icon
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Handle logout action
                        signOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
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
                    width: 100.0, // Adjust the size if needed
                    height: 100.0, // Adjust the size if needed
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle register new patient action
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RegisterPatientScreen(doctorName: widget.doctorName)),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Color(0xFF109CCF),
              ),
              child: const Text(
                'Register New Patient',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle register new patient action
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RegisterSchoolScreen(doctorName: widget.doctorName)),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                backgroundColor: Color.fromARGB(186, 31, 115, 184),
              ),
              child: const Text(
                'Register New School',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Patients',
              style: TextStyle(
                fontSize: 32,
                color: Color(0xFF109CCF),
                fontWeight: FontWeight.bold,
              ),
            ),
            flag_loader
                ? CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF109CCF)))
                : Expanded(
                    child: ListView.builder(
                      itemCount: patientNames.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            color: const Color(0xFF276490),
                            child: ListTile(
                              title: Text(
                                patientNames[index],
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                // Handle patient selection
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
