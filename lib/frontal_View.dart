import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dmft_app/utils.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:async';
import 'model.dart';
import 'dart:isolate';

class FrontalViewScreen extends StatefulWidget {
  final String doctorName;
  final Map<String, dynamic> patientData;
  final String patientId;
  const FrontalViewScreen(
      {Key? key,
      required this.doctorName,
      required this.patientData,
      required this.patientId})
      : super(key: key);

  @override
  FrontalViewScreenState createState() => FrontalViewScreenState();
}

void runSpawning(List<dynamic> args) async {
  SendPort sendPort = args[0];
  String imagePath = args[1];
  double conf_score = args[2];
  ModelObjectDetection objectModel = args[3];
  RootIsolateToken rootToken = args[4];
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  try {
    // Example: Load a model or run a prediction here
    var result = await runPrediction(imagePath, conf_score, objectModel);

    // Send the result back to the main thread
    sendPort.send(result);
  } catch (e) {
    sendPort.send("Error: $e");
  }
}

// Prediction function (heavy computation)
Future<Map<String, dynamic>> runPrediction(String imagePath, double confScore,
    ModelObjectDetection objectModel) async {
  try {
    var objDetect = await objectModel.getImagePrediction(
      await File(imagePath).readAsBytes(),
      minimumScore: confScore,
      IOUThershold: 0.6,
    );
    print(objDetect);
    return {"objectModel": objDetect};
  } catch (e) {
    if (e is PlatformException) {
      print("Only supported for Android, Error: $e");
    } else {
      print("Error: $e");
    }
    throw e;
  }
}

class FrontalViewScreenState extends State<FrontalViewScreen> {
  // var doctorName = "Dr. Fahad Umer"; // Replace with the doctor's name
  late String doctorName;
  late double dynamic_height;
  final ImagePicker _picker = ImagePicker();
  late ModelObjectDetection _objectModel;
  List<ResultObjectDetection?> objDetect = [];
  List rects = [];
  bool firststate = false;
  late String picURL = '';
  late String aiPicURL = '';
  bool message = true;
  late bool _isLoading = false;
  bool _detectionFlag = false;
  bool _activeCamera = false;
  File? _imageFile;
  // String baseName = 'TestImage';
  Set<int> _selectedTeethAI = <int>{}; // Track selected teeth for AI Analysis
  Set<int> _selectedTeethDoc = <int>{}; // Track selected teeth for Findings
  @override
  void initState() {
    super.initState();
    doctorName = widget.doctorName;
    _loadSelectedTeeth();

    // loadModel();
    _objectModel = objectModel;
  }

  Future<void> updateHeight(double heightVal) async {
    print(heightVal);
    if (this.mounted) {
      setState(() {
        dynamic_height = heightVal;
      });
    }
  }

  Future<XFile?> cropImage(File pickedImage) async {
    CroppedFile? cropped = await ImageCropper()
        .cropImage(sourcePath: pickedImage.path, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Crop to focus oral cavity',
          toolbarWidgetColor: Colors.black,
          toolbarColor: Colors.white)
    ]);

    // Convert CroppedFile to File
    // File croppedFile = File(cropped!.path);
    if (cropped == null) {
      return null;
    }
    pickedImage.delete();
    // Convert File to XFile
    XFile croppedXF = XFile(cropped.path);

    return croppedXF;
  }

  Future<void> _pickImage() async {
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _isLoading = true;
    });
    if (pickedImage == null) {
      return;
    }
    XFile? croppedImage = await cropImage(File(pickedImage.path));
    // XFile? croppedImage = await cropImage(File(pickedImage.path));
    // print(croppedImage);
    // setState(() {
    //   _imageFile = croppedImage;
    // });
    // final filePath = '/storage/emulated/0/Download/img.jpg';

    // XFile? croppedImage = await cropImage(File(filePath));

    _imageFile = File(croppedImage!.path);
    double imageDimensions = await getImageDimensions(_imageFile!);
    await updateHeight(imageDimensions);
    final path =
        "${widget.patientData['name']}-${widget.patientData['age']}-${widget.patientData['city']}";
    await runObjectDetection(croppedImage, path);
    // print(_imageFile!.path);
  }

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);

  Future<String> saveToFile(List<dynamic> objDetect, String baseName) async {
    List tempList = [];
    // Get the directory for storing files
    Directory? appDir = await getTemporaryDirectory();

    // Define the directory where you want to save the image
    Directory targetDir = Directory('${appDir.path}/DMFT/output');
    if (!targetDir.existsSync()) {
      // Create the directory if it doesn't exist
      targetDir.createSync(recursive: true);
    }
    // final baseNametxt = baseName.replaceAll('.jpg', '.txt');
    // String filePath = '${targetDir.path}/$baseNametxt';
    String filePath = '${targetDir.path}/$baseName.txt';

    // Open the file for writing
    File file = File(filePath);
    IOSink sink = file.openWrite(mode: FileMode.append);

    // Iterate through the objDetect list and write each element to the file
    for (var element in objDetect) {
      // Convert element to a string representation
      String elementString = jsonEncode({
        "score": element?.score,
        "className": element?.className,
        "class": element?.classIndex,
        "rect": {
          "left": element?.rect.left,
          "top": element?.rect.top,
          "width": element?.rect.width,
          "height": element?.rect.height,
          "right": element?.rect.right,
          "bottom": element?.rect.bottom,
        },
      });

      // Write the string to the file
      sink.writeln(elementString);
      rects.add(
        {
          "className": element?.className,
          "rect": {
            "left": element?.rect.left,
            "top": element?.rect.top,
            "width": element?.rect.width,
            "height": element?.rect.height,
            "right": element?.rect.right,
            "bottom": element?.rect.bottom,
          }
        },
      );
    }
    // Close the file
    await sink.close();
    setState(() {
      _detectionFlag = true;
      _isLoading = false;
      rects = tempList;
    });
    return filePath;
  }

  void handleTimeout() {
    // callback function
    // Do some work.
    setState(() {
      firststate = true;
    });
  }

  Future<void> saveTxtToPicked(List<dynamic> objDetect, String txtPath) async {
    final params = SaveFileDialogParams(sourceFilePath: txtPath);
    await FlutterFileDialog.saveFile(params: params);
  }

  Future<void> runObjectDetection(image, path) async {
    setState(() {
      firststate = false;
      message = false;
    });
    var conf_score = double.parse(await fetchConfidence());
    String uniqueNum = '${DateTime.now().millisecondsSinceEpoch}';
    // Perform object detection on the saved image

    final ReceivePort receivePort = ReceivePort();
    var rootToken = RootIsolateToken.instance!;

    try {
      await Isolate.spawn(runSpawning, [
        receivePort.sendPort,
        image.path,
        conf_score,
        _objectModel,
        rootToken
      ]);
      print("Isolate spawned");
    } on Object {
      print("Error in Isolate");
      receivePort.close();
    }
    final res = await receivePort.first;
    print(res);
    objDetect = res['objectModel'];
    // objDetect = await objectModel.getImagePrediction(
    //   await File(image.path).readAsBytes(),
    //   minimumScore: conf_score,
    //   IOUThershold: 0.6,
    // );

    Map<String?, int?> classFrequencies = {};

    for (var element in objDetect) {
      // Update class frequencies
      classFrequencies[element?.className] =
          (classFrequencies[element?.className] ?? 0) + 1;
    }
    // Save the image to the specified directory
    String baseName = '$path-$uniqueNum';
    // await saveImageToDirectory(File(croppedImage.path), baseName);

    String txtPath = await saveToFile(objDetect, baseName);
    var pictureUrl = await Future.wait([
      uploadFileForUsers(File(image!.path), "$path-frontalView",
          "$path-frontalView-$uniqueNum", rects, true)
    ]);

    Future.wait([
      uploadFileForUsers(File(txtPath), "$path-frontalView",
          "$path-frontalView-$uniqueNum", rects, false)
    ]);
    // await saveTxtToPicked(objDetect, txtPath);
    setState(() {
      picURL = pictureUrl[0][0];
      aiPicURL = pictureUrl[0][1];
      message = true;
    });
  }

  Future<void> _loadSelectedTeeth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedTeethAI = prefs.getStringList('selectedTeethAI');
    List<String>? selectedTeethDoc = prefs.getStringList('selectedTeethDoc');

    if (selectedTeethAI != null) {
      setState(() {
        _selectedTeethAI = selectedTeethAI.map((e) => int.parse(e)).toSet();
      });
    }

    if (selectedTeethDoc != null) {
      setState(() {
        _selectedTeethDoc = selectedTeethDoc.map((e) => int.parse(e)).toSet();
      });
    }
  }

  Future<void> _saveSelectedTeeth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'selectedTeethAI', _selectedTeethAI.map((e) => e.toString()).toList());
    prefs.setStringList('selectedTeethDoc',
        _selectedTeethDoc.map((e) => e.toString()).toList());
  }

  // make array like [[55,54,53],[85,84,83],[18,17,16,15,14,13], [48,47,46,45,44,43]]
  List<List<int>> teeth = [
    [52, 51, 61, 62],
    [82, 81, 71, 72],
    [13, 12, 11, 21, 22, 23],
    [43, 42, 41, 31, 32, 33]
  ];

  Map<String, dynamic> dictTeeth = {
    "52": false,
    "51": false,
    "61": false,
    "62": false,
    "82": false,
    "81": false,
    "71": false,
    "72": false,
    "13": false,
    "12": false,
    "11": false,
    "21": false,
    "22": false,
    "23": false,
    "43": false,
    "42": false,
    "41": false,
    "31": false,
    "32": false,
    "33": false
  };

// write function that will use dictTeeth as a template and create new dictionary with the same keys but value of some keys is true which will be present in given list
// for example if given list is [52, 51, 61, 62] then the new dictionary will be {"52": true, "51": true, "61": true, "62": true, "82": false, "81": false, "71": false, "72": false, "13": false, "12": false, "11": false, "21": false, "22": false, "23": false, "43": false, "42": false, "41": false, "31": false, "32": false, "33": false}
  Map<String, dynamic> createDict(List<int> selectedTeeth) {
    Map<String, dynamic> newDict = {};
    for (var key in dictTeeth.keys) {
      newDict[key] = selectedTeeth.contains(int.parse(key));
    }
    return newDict;
  }

  Future<void> _resetTeethSelections() async {
    setState(() {
      _selectedTeethAI.clear();
      _selectedTeethDoc.clear();
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedTeethAI');
    await prefs.remove('selectedTeethDoc');
  }

  void _toggleSelection(int tooth, String section) {
    setState(() {
      if (section == 'AI') {
        if (_selectedTeethAI.contains(tooth)) {
          _selectedTeethAI.remove(tooth);
        } else {
          _selectedTeethAI.add(tooth);
        }
      } else if (section == 'DOC') {
        if (_selectedTeethDoc.contains(tooth)) {
          _selectedTeethDoc.remove(tooth);
        } else {
          _selectedTeethDoc.add(tooth);
        }
      }
      _saveSelectedTeeth(); // Save state whenever a selection changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor:
      //     Color.fromARGB(255, 209, 237, 255), // Red background color
      body: SingleChildScrollView(
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
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Back',
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
                      width: 100.0, // Adjust the size if needed
                      height: 100.0, // Adjust the size if needed
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15), // Added some space from the top
              // Title
              const Text(
                'Clincal Examination',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF109CCF),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5), // Added some space from the top
              const Text(
                'Frontal View',
                style: TextStyle(
                  fontSize: 32,
                  color: Color(0xFF109CCF),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15), // Added some space from the top
              // Dental View Buttons
              // use teeth variable to dynamically create buttons
              for (int j = 0; j < teeth.length; j++)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                            width: 20), // Space at the start of the row
                        for (int i = 0; i < teeth[j].length; i++)
                          Row(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(Size(
                                      35.0, 80.0)), // Adjust width and height
                                  elevation: WidgetStateProperty.all(10),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                                  backgroundColor: WidgetStateProperty.all(
                                      _selectedTeethDoc.contains(teeth[j][i])
                                          ? Colors.green
                                          : Color(0xFF109CCF)),
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 5)),
                                ),
                                onPressed: () =>
                                    _toggleSelection(teeth[j][i], 'DOC'),
                                child: Container(
                                  width:
                                      45.0, // Width for content inside button
                                  height: 80.0,
                                  padding: EdgeInsets.all(0),
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                          image: AssetImage(
                                              'assets/images/teethcropped.png'),
                                          width: 25.0, // Adjusted image size
                                          height: 25.0),
                                      Text(
                                        '${teeth[j][i]}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24, // Adjusted font size
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Add space between buttons, but not after the last button
                              if (i < teeth[j].length - 1) SizedBox(width: 10),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 10), // Space between rows
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _activeCamera,
                    onChanged: (bool? value) {
                      setState(() {
                        _activeCamera = value!;
                      });
                    },
                  ),
                  const Text(
                    'Clinical examination performed',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF109CCF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Space at the end
              // draw straight line
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                height: 2,
                color: const Color(0xFF109CCF),
              ),
              const SizedBox(height: 10), // Space at the end
              const Text(
                'AI Analysis & Findings',
                style: TextStyle(
                  fontSize: 32,
                  color: Color(0xFF109CCF),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10), // Space at the end
              GestureDetector(
                onTap: _activeCamera
                    ? _pickImage
                    : () => showDialogClinicalExamination(context),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // This gives you the width of the parent container
                    double containerWidth = constraints.maxWidth;

                    // Set the dynamic height based on the width and a custom aspect ratio

                    return Container(
                      width: containerWidth,
                      height: _detectionFlag == true
                          ? containerWidth * dynamic_height
                          : 300.0 // You can adjust the aspect ratio
                      ,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF9E9E9E),
                          width: 3,
                        ),
                      ),
                      child: _detectionFlag == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: _objectModel.renderBoxesOnImage(
                                  _imageFile as File, objDetect))
                          : _isLoading
                              ? Center(
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF109CCF)),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: _pickImage,
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20), // Space at the end
              for (int j = 0; j < teeth.length; j++)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                            width: 20), // Space at the start of the row
                        for (int i = 0; i < teeth[j].length; i++)
                          Row(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  minimumSize: WidgetStateProperty.all(Size(
                                      35.0, 80.0)), // Adjust width and height
                                  elevation: WidgetStateProperty.all(10),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                                  backgroundColor: WidgetStateProperty.all(
                                      _selectedTeethAI.contains(teeth[j][i])
                                          ? const Color.fromARGB(
                                              255, 32, 77, 34)
                                          : Color(0xFF109CCF)),
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 5)),
                                ),
                                onPressed: () =>
                                    _toggleSelection(teeth[j][i], 'AI'),
                                child: Container(
                                  width:
                                      45.0, // Width for content inside button
                                  height: 80.0,
                                  padding: EdgeInsets.all(0),
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                          image: AssetImage(
                                              'assets/images/teethcropped.png'),
                                          width: 25.0, // Adjusted image size
                                          height: 25.0),
                                      Text(
                                        '${teeth[j][i]}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24, // Adjusted font size
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Add space between buttons, but not after the last button
                              if (i < teeth[j].length - 1) SizedBox(width: 10),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 10), // Space between rows
                  ],
                ),

              const SizedBox(height: 20), // Space at the end
              SizedBox(
                width: 400.0,
                height: 60.0,
                child: ElevatedButton(
                  onPressed: () {
                    if (picURL == "" && aiPicURL == "") {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Please Wait'),
                            content: const Text(
                                'Please wait, data is uploading. \n Make Sure Internet speed is good.'),
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
                    set_view_status("FrontalView");
                    delTempFiles(_imageFile!.path);
                    submitAndResetSelections(
                      selectedTeethAI: _selectedTeethAI,
                      selectedTeethDoc: _selectedTeethDoc,
                      teethTemplate: dictTeeth,
                      resetTeeth: _resetTeethSelections,
                      toConvertFunction: createDict,
                      patientId: widget.patientId,
                      picUrl: picURL,
                      aiPicUrl: aiPicURL,
                      isRetractor: widget.patientData['isRetractor'],
                      view: "Frontal_View",
                      context: context,
                    );
                    // navigate back tor
                    // Navigator.push(
                    //         context,
                    //         MaterialPageRoute(builder: (context) => DentalViewSelectionScreen()),
                    //       );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    backgroundColor: aiPicURL != "" && picURL != ""
                        ? Color(0xFF109CCF)
                        : const Color.fromARGB(255, 105, 105, 105),
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
