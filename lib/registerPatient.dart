import 'package:flutter/material.dart';
import 'package:dmft_app/login.dart';
import 'package:dmft_app/dentalview.dart';
import 'package:dmft_app/docpanel.dart';
import 'package:dmft_app/utils.dart';

// ignore: must_be_immutable
class RegisterPatientScreen extends StatefulWidget {
  RegisterPatientScreen({Key? key, required this.doctorName}) : super(key: key);
  final String doctorName;

  @override
  _RegisterPatientScreenState createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  // create a dictionary
  Map<String, String> patientData = {
    'name': '',
    'fatherMotherName': '',
    'age': '',
    'dentition': '',
    'doctorName': '',
  };
  List<String> school_list = [];
  // create controllers for text editing fields
  final nameController = TextEditingController();
  final fatherMotherNameController = TextEditingController();
  final ageController = TextEditingController();
  final dentitionController = TextEditingController();

  // create a variable to store the selected value from the dropdown
  String? selectedDentitionValue;
  String? selectedGenderValue;
  String? selectedCityValue;
  String? selectedRetractor;
  String? selectedSchool;
  bool isAuthenticated = false;
  bool isLoading = false;
  Future<void> updateSchoolList() async {
    fetchSchoolsList().then((value) {
      setState(() {
        school_list = value.cast<String>();
      });
    });
    print(school_list);
  }

  @override
  void initState() {
    super.initState();
    updateSchoolList();
  }

  void _authenticate(
      BuildContext context, patientData, bool isAuthenticated) async {
    if (isAuthenticated) {
      setState(() {
        isLoading = true;
      });

      var pat_data = await dumpPatientData(patientData);
      var patientId = pat_data['id'];
      var patientrefId = pat_data['refId'];
      var retractId = pat_data['retractId'];
      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DentalViewSelectionScreen(
            patientData: patientData,
            patientId: patientId,
            patientrefId: patientrefId,
            retractId: retractId,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Failed'),
            content: const Text('Please fill in all the values.'),
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
      // backgroundColor: Color.fromARGB(255, 209, 237, 255),
      backgroundColor: Color.fromARGB(255, 209, 237, 255),
      body: Container(
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
                  'Register New Patient',
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
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              items: school_list.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                selectedSchool = newValue;
                              },
                              decoration: InputDecoration(
                                hintText: 'School',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              isExpanded: true, // Add this line
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Name',
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
                        controller: fatherMotherNameController,
                        decoration: InputDecoration(
                          hintText: 'Father/ Mother Name',
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
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ageController,
                              decoration: InputDecoration(
                                hintText: 'Age',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              items: ['Primary', 'Mixed', 'Permanent']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                selectedDentitionValue = newValue;
                              },
                              decoration: InputDecoration(
                                hintText: 'Dentition',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              isExpanded: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              items: ['With Retractor', 'Without Retractor']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                selectedRetractor = newValue;
                              },
                              decoration: InputDecoration(
                                hintText: 'Retracted?',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              isExpanded: true, // Add this line
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              items: ['Male', 'Female'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                selectedGenderValue = newValue;
                              },
                              decoration: InputDecoration(
                                hintText: 'Gender',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              items: ['Mitthi', 'Karachi'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                selectedCityValue = newValue;
                              },
                              decoration: InputDecoration(
                                hintText: 'City',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientScreen(
                                    doctorName: widget.doctorName,
                                  ),
                                ),
                              );
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
                              clearViewStatus();
                              patientData['name'] = nameController.text;
                              patientData['fatherMotherName'] =
                                  fatherMotherNameController.text;
                              patientData['age'] = ageController.text;
                              patientData['dentition'] =
                                  selectedDentitionValue ?? '';
                              patientData['gender'] = selectedGenderValue ?? '';
                              patientData['city'] = selectedCityValue ?? '';
                              patientData['isRetractor'] =
                                  selectedRetractor ?? '';
                              patientData['doctorName'] = widget.doctorName;
                              patientData['school'] = selectedSchool ?? '';

                              if (patientData['name'] == '' ||
                                  patientData['fatherMotherName'] == '' ||
                                  patientData['age'] == '' ||
                                  patientData['dentition'] == '' ||
                                  patientData['isRetractor'] == '' ||
                                  patientData['school'] == '') {
                                isAuthenticated = false;
                              } else {
                                isAuthenticated = true;
                              }

                              _authenticate(
                                  context, patientData, isAuthenticated);
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
