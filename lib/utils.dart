import 'dart:ui' as ui;
import 'dart:async'; // Import for Timer
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dmft_app/registerPatient.dart';
import 'package:permission_handler/permission_handler.dart';

// import firebase_auth package
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import package firebase firestore database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

// Future<void> clearCache() async {
//   await DefaultCacheManager().emptyCache();
//   print("Cache Cleared!");
// }

Future<void> showAlertDialogSuccessful(BuildContext context) async {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      "Record submitted successfully.",
      textAlign: TextAlign.center,
    ),
    content: Image.asset(
      'assets/images/successful.png',
      width: 100.0, // Adjust the size if needed
      height: 100.0, // Adjust the size if needed
    ),
  );
  Timer(Duration(seconds: 3), () async {
    String doctorName = await fetchDoctorName();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RegisterPatientScreen(doctorName: doctorName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Right to left dissolve animation
          const begin = Offset(1.0, 0.0); // Start from the right
          const end = Offset.zero; // End at the center
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAlertDialogSubmit(BuildContext context) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(
      "No",
      style: TextStyle(color: Color(0xFF109CCF)),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(
    child: Text(
      "Yes",
      style: TextStyle(color: Color(0xFF109CCF)),
    ),
    onPressed: () {
      Navigator.pop(context);
      showAlertDialogSuccessful(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Are you sure?"),
    content: Text("Are you sure to submit the form?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void submitAndResetSelections({
  required Set<int> selectedTeethAI,
  required Set<int> selectedTeethDoc,
  required Map<String, dynamic> teethTemplate,
  required Function resetTeeth,
  required Function toConvertFunction,
  required String patientId,
  required String view,
  required String picUrl,
  required String aiPicUrl,
  required BuildContext context,
  required String isRetractor,
}) {
  // Print selected teeth for the current screen
  // print('Selected Teeth for AI Analysis: $selectedTeethAI');
  final selectedTeethAIDict = toConvertFunction(selectedTeethAI.toList());
  // print('Selected Teeth for Doctor Findings: $selectedTeethDoc');
  final selectedTeethDocDict = toConvertFunction(selectedTeethDoc.toList());

  // print(selectedTeethAIDict);
  // print(selectedTeethDocDict);
  Map<String, dynamic> resultData = {
    'patId': patientId,
    'imageUrl': picUrl,
    'aiImageUrl': aiPicUrl,
    'createdAt': DateTime.now().toString(),
    'results': {
      'ai': selectedTeethAIDict,
      'doc': selectedTeethDocDict,
    }
  };
  // print(resultData);
  dumpgenData(resultData, "${patientId}_${isRetractor}", "${view}");

  // Reset the selections
  resetTeeth();

  if (selectedTeethAI.isEmpty && selectedTeethDoc.isEmpty) {
    // print('All selections are reset.');
    Navigator.pop(context);
  }
}

Future<bool> signInEmailPassword(String email, String password) async {
  try {
    final userloggedin = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // print('User logged in: ${userloggedin.user?.uid}');
    if (userloggedin.user != null) {
      return true;
    }
    return false;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      // print('No user found for that email.');
      return false;
    } else if (e.code == 'wrong-password') {
      return false;
    }
  }
  return false;
}

// write a function that will check if the user is signed or not?
Future<String> isUserSignedIn() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // print('User is signed in: ${currentUser.uid}');
    return currentUser.email!;
  }
  // print('User is not signed in');
  return "Not Signed In";
}

Future<double> getImageDimensions(File imageFile) async {
  final image = FileImage(imageFile);
  final completer = Completer<ui.Image>();
  image
      .resolve(const ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(info.image);
  }));

  final ui.Image img = await completer.future;
  // print('Width: ${img.width}, Height: ${img.height}');
  var ratio = img.height.toDouble() / img.width.toDouble();
  return ratio;
}

Future<List> uploadFileForUsers(File file, String patientName, String fileName,
    List rects, bool isReact) async {
  // ignore: non_constant_identifier_names
  String URL = "";
  String URL2 = "";
  // print(rects);
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    print(currentUserId);
    if (currentUserId == null) {
      // print('User is not signed in');
    print(patientName);
      return ["User is not signed in"];
    }
    final storageRef = FirebaseStorage.instance.ref();
    // print(file);
    if (!file.path.contains("txt")) {
      final imgExtension = file.path.split('.').last;
      final uploadRef = storageRef.child(
          'MeDenTec/${currentUser?.email}/$patientName/$fileName.$imgExtension');
      var x = await uploadRef.putFile(file);
      var downloadURL = await x.ref.getDownloadURL();
      URL = downloadURL;
      print('File uploaded successfully. Download URL: $downloadURL');
    }
    if (isReact) {
      final uploadRef = storageRef.child(
          'MeDenTec/${currentUser?.email}/$patientName/${fileName}_AI.jpg');
      // var x = await uploadRef.putFile(file);
      URL2 = await drawBoxesFromJsonAndUpload(file, rects, uploadRef.fullPath)
          as String;
      print('AI File uploaded successfully.');
    }
    if (file.path.contains("txt")) {
      final uploadRef = storageRef
          .child('MeDenTec/${currentUser?.email}/$patientName/$fileName.txt');
      await uploadRef.putFile(file);
      print('Text File uploaded successfully');
    }
    if (URL2 != "") {
      return [URL, URL2];
    }
    return [URL];
  } catch (e) {
    // print('Failed to upload image: $e');
    return ["Failed to upload image"]; // Add a return statement here
  }
}

// function for sign up
Future<bool> signUpEmailPassword(String email, String password) async {
  try {
    final userloggedin =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // print('User logged in: ${userloggedin.user?.uid}');
    if (userloggedin.user != null) {
      return true;
    }
    return false;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      // print('No user found for that email.');
      return false;
    } else if (e.code == 'wrong-password') {
      // print('Wrong password provided for that user.');
      return false;
    }
  }
  return false;
}

// function for sign out
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

//  function for dumping the data for regsitgering doctor, random ID, name email
Future<void> dumpData(String name, String email) async {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) {
    // print('User is not signed in');
    return;
  }
  if (name.contains("Dr.") ||
      name.contains("Dr") ||
      name.contains("dr.") ||
      name.contains("dr")) {
    name = name;
  } else {
    name = "Dr. $name";
  }
  await dumpDoctorList(name);
  var doc_id = await getDoctorId();
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('doctors').doc("${email}_$currentUserId").set({
    'id': "${email}_$currentUserId",
    'createdAt': DateTime.now().toString(),
    'refId': doc_id,
    'name': name,
    'email': email,
  });
}

//  fetch doctor name from firestore
Future<String> fetchDoctorName() async {
  await Future.delayed(Duration(seconds: 1));
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  // print(currentUserId);
  if (currentUserId == null) {
    // print('User is not signed in');
    return "No Name";
  }
  // print("${currentUserEmail}_${currentUserId}");
  final firestore = FirebaseFirestore.instance;
  final doctorData = await firestore
      .collection('doctors')
      .doc("${currentUserEmail}_${currentUserId}")
      .get();
  if (doctorData.exists) {
    print(doctorData.get('name'));
    return doctorData.get('name');
  }
  return "No Name";
}

Future<String> fetchDoctorId() async {
  await Future.delayed(Duration(seconds: 1));
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  if (currentUserId == null) {
    // print('User is not signed in');
    return "No Name";
  }
  final firestore = FirebaseFirestore.instance;
  final doctorData = await firestore
      .collection('doctors')
      .doc("${currentUserEmail}_$currentUserId")
      .get();
  if (doctorData.exists) {
    // print(doctorData.get('id'));
    return doctorData.get('id');
  }
  return "No Name";
}

Future<String> getDoctorRefId(docId) async {
  final firestore = FirebaseFirestore.instance;
  final doctorData = await firestore.collection('doctors').doc(docId).get();
  if (doctorData.exists) {
    // print(doctorData.get('refId'));
    return doctorData.get('refId');
  }
  return "No Name";
}

Future<String> getAllSchools(schlId) async {
  final firestore = FirebaseFirestore.instance;
  final schoolsData = await firestore.collection('schools').get();
  for (var doc in schoolsData.docs) {
    if (schlId == doc.get('school_name')) {
      return doc.get('id');
    }
  }
  return "No Name";
}

//  function for dumping the data for regsitgering doctor, random ID, name email
Future<Map> dumpPatientData(Map<String, dynamic> patientData) async {
  String uniqueNum = '${DateTime.now().millisecondsSinceEpoch}';
  final currentUserId = await fetchDoctorId();
  var patRetCode = '';
  final firestore = FirebaseFirestore.instance;
  final patientCountData =
      await firestore.collection('pat_count').doc("pat_count").get();
  var pat_count = 0;

  if (patientCountData.exists) {
    var pat_count = patientCountData.get('pat_count');
    pat_count = int.parse(pat_count.toString()) + 1;
    await firestore.collection('pat_count').doc("pat_count").set({
      'pat_count': pat_count,
    });
  } else {
    await firestore.collection('pat_count').doc("pat_count").set({
      'pat_count': 1,
    });
  }
  var patRefId = patientCountData.get('pat_count').toString().padLeft(3, '00');
  var docRefId = await getDoctorRefId(currentUserId);
  var schRefId = await getAllSchools(patientData['school']);
  if (patientData['isRetractor'] == "Without Retractor") {
    patRetCode = "00";
  } else {
    patRetCode = "01";
  }
  // print("pat_count =====>${patientCountData.get('pat_count')}");
  var completeId = "${schRefId}-${docRefId}-${patRefId}-${patRetCode}";
  // print(completeId);
  await firestore
      .collection('patients')
      .doc(
          "${patientData['name']}_${patientData['fatherMotherName']}_${patientData['isRetractor']}_${uniqueNum}")
      .set({
    'createdAt': DateTime.now().toString(),
    'docId': currentUserId,
    'refId': patientCountData.get('pat_count').toString().padLeft(3, '00'),
    'id':
        "${patientData['name']}_${patientData['fatherMotherName']}_${completeId}_${uniqueNum}",
    'name': patientData['name'],
    'father/mother_Name': patientData['fatherMotherName'],
    'age': patientData['age'],
    'dentition': patientData['dentition'],
    'gender': patientData['gender'],
    'city': patientData['city'],
    'isRetractor': patientData['isRetractor'],
    'school_id': patientData['school'],
  });
  return {
    'id':
        "${patientData['name']}_${patientData['fatherMotherName']}_${completeId}_${uniqueNum}",
    'refId': patientCountData.get('pat_count').toString().padLeft(3, '00'),
    'retractId': patRetCode
  };
}

// get schools_list array from reference collection /schools_lists/schools_lists
Future<List<dynamic>> fetchSchoolsList() async {
  final firestore = FirebaseFirestore.instance;
  final schoolsListData = await firestore.collection('schools_list').get();
  List<dynamic> schoolsList = [];
  schoolsListData.docs.forEach((element) {
    schoolsList = element.get('schools_list');
  });
  return schoolsList;
}

Future<List<dynamic>> fetchDoctorList() async {
  final firestore = FirebaseFirestore.instance;
  final schoolsListData = await firestore.collection('doctors_list').get();
  List<dynamic> schoolsList = [];
  schoolsListData.docs.forEach((element) {
    schoolsList = element.get('doctors_list');
  });
  return schoolsList;
}

// set schools_list array from reference collection /schools_lists/schools_lists
Future<bool> dumpSchoolsList(String schoolName) async {
  final firestore = FirebaseFirestore.instance;
  var school_list = await fetchSchoolsList();
  if (school_list.contains(schoolName)) {
    return false;
  }
  school_list.add(schoolName);
  await firestore.collection('schools_list').doc('schools_list').set({
    'schools_list': school_list,
  });
  return true;
}

Future<bool> dumpDoctorList(String schoolName) async {
  final firestore = FirebaseFirestore.instance;
  var school_list = await fetchDoctorList();
  // if (school_list.contains(schoolName)) {
  //   return false;
  // }
  school_list.add(schoolName);
  await firestore.collection('doctors_list').doc('doctors_list').set({
    'doctors_list': school_list,
  });
  return true;
}

Future<String> getSchoolIdByName(String schoolName) async {
  final firestore = FirebaseFirestore.instance;
  var temList = [];
  final schoolsListData = await firestore
      .collection('schools')
      .where('school_name', isEqualTo: schoolName)
      .get()
      .then((snapshot) {
    snapshot.docs.forEach((element) {
      temList.add(element.get('id'));
    });
  });
  // print(temList);

  return temList[0].toString();
}

Future<String> getDoctorIdByEmail() async {
  final firestore = FirebaseFirestore.instance;
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  var tempList = [];
  // print(currentUserEmail);
  final schoolsListData = await firestore
      .collection('doctors')
      .where('email', isEqualTo: currentUserEmail)
      .get()
      .then((snapshot) {
    snapshot.docs.forEach((element) {
      tempList.add(element.get('refId'));
    });
  });
  return tempList[0].toString();
}

Future<String> getSchoolId() async {
  var raw_id = "001";
  var school_list = await fetchSchoolsList();
  var length = school_list.length;

  final school_id = (int.parse(raw_id) + length).toString().padLeft(2, '00');
  return school_id;
}

Future<String> getDoctorId() async {
  var raw_id = "01";
  var school_list = await fetchDoctorList();
  var length = school_list.length;

  final school_id = (int.parse(raw_id) + length).toString().padLeft(2, '00');
  return school_id.toString();
}

Future<String> dumpschoolData(Map<String, dynamic> schooldData, context) async {
  String uniqueNum = '${DateTime.now().millisecondsSinceEpoch}';
  final currentUserId = await fetchDoctorId();
  final school_id = await getSchoolId();
  final firestore = FirebaseFirestore.instance;
  bool school_check = await dumpSchoolsList(schooldData['school_name']);
  if (!school_check) {
    return "Failed";
  }
  await firestore.collection('schools').doc("${school_id}").set({
    'docId': currentUserId,
    'id': "${school_id}",
    'createdAt': DateTime.now().toString(),
    'school_name': schooldData['school_name'],
    'school_address': schooldData['school_address']
  });
  return "${school_id}";
}

//  function for dumping the data for regsitgering doctor, random ID, name email
Future<void> dumpgenData(
    Map<String, dynamic> data, String path, String view) async {
  var currentUserId = await fetchDoctorId();
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('results').doc(currentUserId).set({
    'id': currentUserId,
    'createdAt': DateTime.now().toString(),
  });

  await firestore
      .collection('results')
      .doc(currentUserId)
      .collection(currentUserId)
      .doc("${path}")
      .set({'id': data['patId']});

  await firestore
      .collection('results')
      .doc(currentUserId)
      .collection(currentUserId)
      .doc("${path}")
      .collection(view)
      .doc(view)
      .set(data);
}

// get all patients name and return in a list
Future<List<dynamic>> fetchAllPatients() async {
  final currentUserId = await fetchDoctorId();
  final firestore = FirebaseFirestore.instance;
  final patientsData = await firestore
      .collection('patients')
      .where('docId', isEqualTo: currentUserId)
      .get();
  List<dynamic> patients = [];
  patientsData.docs.forEach((element) {
    patients.add(element.get('name'));
  });
  return patients;
}

//  set confidence

Future<void> dumpConfidence(
    Map<String, dynamic> data, BuildContext context) async {
  // print(data);
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('confidence').doc("confidence").set(data);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Successful'),
        content: Text(
            'Confidence value ${data['confidence'].toString() as String} set successfully'),
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

//  get confidence
Future<String> fetchConfidence() async {
  final firestore = FirebaseFirestore.instance;
  final confidenceData =
      await firestore.collection('confidence').doc("confidence").get();
  if (confidenceData.exists) {
    // print(confidenceData.get('confidence'));
    return confidenceData.get('confidence').toString();
  }
  return 'Confidence value 0.1 ~ 0.9';
}

Future<String> fetchPatientCount() async {
  final firestore = FirebaseFirestore.instance;
  final confidenceData =
      await firestore.collection('pat_count').doc("pat_count").get();
  if (confidenceData.exists) {
    // print(confidenceData.get('pat_count'));
    return confidenceData.get('pat_count').toString();
  }
  return 'Patient Count 0';
}

Future<void> showDialogClinicalExamination(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Clinical Examination Required'),
        content: Text('Perform clinical examination first.'),
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

Future<String> drawBoxesFromJsonAndUpload(
    File imageFile, List<dynamic> jsonData, String storagePath) async {
  // Load the image
  final imageBytes = await imageFile.readAsBytes();
  final image = img.decodeImage(imageBytes);
  // print("--------------------jsondata---------------");
  // print(jsonData);
  // print("--------------------jsondata---------------");
  if (image == null) {
    throw Exception('Failed to decode image');
  }

  // Get image dimensions
  final imageWidth = image.width;
  final imageHeight = image.height;

  // Draw each bounding box on the image
  for (var item in jsonData) {
    final rect = item['rect'] as Map<String, dynamic>;

    // Convert normalized coordinates to pixel values
    final double leftNorm = rect['left'] as double;
    final double topNorm = rect['top'] as double;
    final double widthNorm = rect['width'] as double;
    final double heightNorm = rect['height'] as double;

    final int left = (leftNorm * imageWidth).toInt();
    final int top = (topNorm * imageHeight).toInt();
    final int width = (widthNorm * imageWidth).toInt();
    final int height = (heightNorm * imageHeight).toInt();

    // Draw a rectangle on the image
    img.drawRect(image, left, top, left + width, top + height,
        img.getColor(255, 0, 0, 255));
    img.drawString(
        image, img.arial_24, left, top - 30, item['className'] as String);
  }
  // Save the image with the bounding boxes
  final newImageBytes = img.encodeJpg(image, quality: 70);

  // Upload to Firebase Storage
  final storageRef = FirebaseStorage.instance.ref().child(storagePath);
  var x = await storageRef.putData(Uint8List.fromList(newImageBytes));
  return await x.ref.getDownloadURL();
}

// set all view status
void set_view_status(String view) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(view, 1);
  print("View Status Set");
}

void clearViewStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

void delTempFiles(String file) async {
  var permit = await Permission.storage.request();
  print(file);
  if (permit.isGranted) {
    final filex = File(file);
    filex.delete();
  }

  print("Temp Files Deleted");
}
