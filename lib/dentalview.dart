import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dmft_app/login.dart';
import 'package:dmft_app/utils.dart';
import 'package:dmft_app/left_Lateral_View.dart';
import 'package:dmft_app/right_Lateral_View.dart';
import 'package:dmft_app/frontal_View.dart';
import 'package:dmft_app/maxillary_Occlusal_View.dart';
import 'package:dmft_app/mandibular_Occlusal_View.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class DentalViewSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final String patientId;
  final String patientrefId;
  final String retractId;
  // Constructor to receive patientData
  const DentalViewSelectionScreen(
      {super.key,
      required this.patientData,
      required this.patientId,
      required this.retractId,
      required this.patientrefId});

  @override
  _DentalViewSelectionScreenState createState() =>
      _DentalViewSelectionScreenState();
}

class _DentalViewSelectionScreenState extends State<DentalViewSelectionScreen> {
  Map<String, int> viewStatus = {};
  void get_view_status() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      viewStatus['RightLateralView'] = prefs.getInt('RightLateralView') ?? 0;
      viewStatus['FrontalView'] = prefs.getInt('FrontalView') ?? 0;
      viewStatus['LeftLateralView'] = prefs.getInt('LeftLateralView') ?? 0;
      viewStatus['MaxillaryView'] = prefs.getInt('MaxillaryView') ?? 0;
      viewStatus['MandibularView'] = prefs.getInt('MandibularView') ?? 0;
    });

    print(viewStatus);
  }

  late String doctorName;
  late String patientName;
  late String patientAge;
  late String patientGender;
  late String patientDentition;
  late String patientSchool;
  late String schoolRefId = "";
  late String doctorRefId = "";

  @override
  void initState() {
    super.initState();
    // print(widget.patientData);

    patientName = widget.patientData['name'];
    patientAge = widget.patientData['age'];
    patientGender = widget.patientData['gender'];
    patientDentition = widget.patientData['dentition'];
    doctorName = widget.patientData['doctorName'];
    patientSchool = widget.patientData['school'];
    getSchoolIdByName(patientSchool).then((value) {
      setState(() {
        schoolRefId = value;
      });
    });
    getDoctorIdByEmail().then((value) {
      setState(() {
        doctorRefId = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // get_view_status();
    return Scaffold(
      backgroundColor: null,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Container(
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
                              'Logged in as\n$doctorName',
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
                          width: constraints.maxWidth * 0.2,
                          height: constraints.maxWidth * 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Select View',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF109CCF),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Color(0xFF109CCF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                        onPressed: () {
                          // setState(() {
                          //   viewStatus['RightLateralView'] = 1;
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RightLateralViewScreen(
                                doctorName: doctorName,
                                patientData: widget.patientData,
                                patientId: widget.patientId,
                              ),
                            ),
                          ).then((_) {
                            // This will run when you pop back to this screen
                            get_view_status();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: constraints.maxWidth * 0.3,
                          height: constraints.maxWidth * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            boxShadow: viewStatus['RightLateralView'] == 1
                                ? [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 45, 201, 105),
                                    ),
                                    BoxShadow(
                                      color: Color.fromARGB(255, 38, 173, 90),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 22, 173, 228),
                                    ),
                                    BoxShadow(
                                      color: Color(0xFF109CCF),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ],
                          ),
                          child: const Text(
                            'Right\nLateral\nView',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Color(0xFF109CCF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                        onPressed: () {
                          // setState(() {
                          //   viewStatus['FrontalView'] = 1;
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FrontalViewScreen(
                                doctorName: doctorName,
                                patientData: widget.patientData,
                                patientId: widget.patientId,
                              ),
                            ),
                          ).then((_) {
                            // This will run when you pop back to this screen
                            get_view_status();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: constraints.maxWidth * 0.3,
                          height: constraints.maxWidth * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            boxShadow: viewStatus['FrontalView'] == 1
                                ? [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 45, 201, 105),
                                    ),
                                    BoxShadow(
                                      color: Color.fromARGB(255, 38, 173, 90),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 22, 173, 228),
                                    ),
                                    BoxShadow(
                                      color: Color(0xFF109CCF),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ],
                          ),
                          child: const Text(
                            'Frontal\nView',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Color(0xFF109CCF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                        onPressed: () {
                          // setState(() {
                          //   viewStatus['LeftLateralView'] = 1;
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeftLateralViewScreen(
                                doctorName: doctorName,
                                patientData: widget.patientData,
                                patientId: widget.patientId,
                              ),
                            ),
                          ).then((_) {
                            // This will run when you pop back to this screen
                            get_view_status();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: constraints.maxWidth * 0.3,
                          height: constraints.maxWidth * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            boxShadow: viewStatus['LeftLateralView'] == 1
                                ? [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 45, 201, 105),
                                    ),
                                    BoxShadow(
                                      color: Color.fromARGB(255, 38, 173, 90),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 22, 173, 228),
                                    ),
                                    BoxShadow(
                                      color: Color(0xFF109CCF),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ],
                          ),
                          child: const Text(
                            'Left\nLateral\nView',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Color(0xFF109CCF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                        onPressed: () {
                          // setState(() {
                          //   viewStatus['MaxillaryView'] = 1;
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MaxillaryViewScreen(
                                doctorName: doctorName,
                                patientData: widget.patientData,
                                patientId: widget.patientId,
                              ),
                            ),
                          ).then((_) {
                            // This will run when you pop back to this screen
                            get_view_status();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: constraints.maxWidth * 0.43,
                          height: constraints.maxWidth * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            boxShadow: viewStatus['MaxillaryView'] == 1
                                ? [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 45, 201, 105),
                                    ),
                                    BoxShadow(
                                      color: Color.fromARGB(255, 38, 173, 90),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 22, 173, 228),
                                    ),
                                    BoxShadow(
                                      color: Color(0xFF109CCF),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text(
                              'Maxillary\nOcclusal View',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Color(0xFF109CCF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                        onPressed: () {
                          // setState(() {
                          //   viewStatus['MandibularView'] = 1;
                          // });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MandibularViewScreen(
                                doctorName: doctorName,
                                patientData: widget.patientData,
                                patientId: widget.patientId,
                              ),
                            ),
                          ).then((_) {
                            // This will run when you pop back to this screen
                            get_view_status();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: constraints.maxWidth * 0.43,
                          height: constraints.maxWidth * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            boxShadow: viewStatus['MandibularView'] == 1
                                ? [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 45, 201, 105),
                                    ),
                                    BoxShadow(
                                      color: Color.fromARGB(255, 38, 173, 90),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 22, 173, 228),
                                    ),
                                    BoxShadow(
                                      color: Color(0xFF109CCF),
                                      spreadRadius: -3.0,
                                      blurRadius: 1.5,
                                    ),
                                  ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text(
                              'Mandibular\nOcclusal View',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF109CCF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            color: const Color(0xFF276490),
                            child: ListTile(
                              title: Row(
                                children: [
                                  const Text(
                                    'Patient ID: ',
                                    style: TextStyle(color: Color(0xFFBDBDBD)),
                                  ),
                                  Text(
                                    "${schoolRefId}_${doctorRefId}_${widget.patientrefId}_${widget.retractId}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            color: const Color(0xFF276490),
                            child: ListTile(
                              title: Row(
                                children: [
                                  const Text(
                                    'School: ',
                                    style: TextStyle(color: Color(0xFFBDBDBD)),
                                  ),
                                  Text(
                                    patientSchool,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            color: const Color(0xFF276490),
                            child: ListTile(
                              title: Row(
                                children: [
                                  const Text(
                                    'Name: ',
                                    style: TextStyle(color: Color(0xFFBDBDBD)),
                                  ),
                                  Text(
                                    patientName,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            color: const Color(0xFF276490),
                            child: ListTile(
                              title: Row(
                                children: [
                                  const Text(
                                    'Age: ',
                                    style: TextStyle(color: Color(0xFFBDBDBD)),
                                  ),
                                  Text(
                                    patientAge,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            color: const Color(0xFF276490),
                            child: ListTile(
                              title: Row(
                                children: [
                                  const Text(
                                    'Gender: ',
                                    style: TextStyle(color: Color(0xFFBDBDBD)),
                                  ),
                                  Text(
                                    patientGender,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Card(
                            color: const Color(0xFF276490),
                            child: ListTile(
                              title: Row(
                                children: [
                                  const Text(
                                    'Dentition: ',
                                    style: TextStyle(color: Color(0xFFBDBDBD)),
                                  ),
                                  Text(
                                    patientDentition,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: constraints.maxWidth * 0.8,
                    height: 60.0,
                    child: ElevatedButton(
                      onPressed: () {
                        showAlertDialogSubmit(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: const Color(0xFF109CCF),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
