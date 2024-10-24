// model.dart
import 'package:flutter_pytorch/flutter_pytorch.dart';

late ModelObjectDetection objectModel;

// Function to load the model
Future<void> loadModel() async {
  try {
    objectModel = await FlutterPytorch.loadObjectDetectionModel(
      "assets/models/best.torchscript", // Update with your model path
      2, // Number of classes in the model
      640,
      640,
      labelPath: "assets/labels/labels.txt",
    );
    print("Model loaded successfully");
  } catch (e) {
    print("Error loading model: $e");
  }
}
