# IntraOral Decay Detection App

This Flutter application utilizes the Flutter PyTorch library along with YOLOv5 models for detecting decayed teeth in intraoral images. It provides functionality to capture five different views of the teeth and determines the presence of decay as well as the number of decayed teeth.

## Getting Started

This project is based on a flutter App that is capable of detecting disease in human tooth like decayed tooth..

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Features

- Capture five different views of intraoral images:
  1. Upper Oclusal
  2. Lower Oclusal
  3. Right Lateral
  4. Left Lateral
  5. Frontal

- Utilizes YOLOv5 models for decay detection.
- Provides real-time feedback on the presence of decay and the number of decayed teeth.
- Offers a user-friendly interface for easy interaction.

## Installation

1. Clone the repository:
```bash
git clone https://github.com/MeDenTec/Tooth_decay_detection_in_intraoral_images.git
```

2. Navigate to the project directory:

3. Install dependencies:
```bash
flutter pub get
```

## Usage

### Flutter Run
1. Ensure that you have a device connected or an emulator running.
2. Run the application:
```bash
flutter run
```
3. Use the following credentials to login the App
```python
UserName => 'testuser@medentec.com'
Password => 'P@$$word'
```
4. Capture intraoral images from different views using the provided interface and get the detection results.
5. Here, label 'D' represents the Secondary decay and and label 'd' represents the Primary decay.

### Built apk
You can also download and install suitable apk version for your android device from the below link
``` Python
https://drive.google.com/drive/u/1/folders/1Xx-sJei7juAI5W1b9k5X4WwyJ-7aJXmc
 ```
## Acknowledgements

We would like to acknowledge the incredible contributions of the following individuals, whose expertise and collaboration made this project a success.

### Research Team
- **Dr. Fahad Umer**  
- **Dr. Niha Adnan**  
- **Syed Muhammad Faizan Ahmed** (AI Engineer)  
- **Huzaifa Ghori** (Developer)  

---

We are grateful for the efforts and dedication of the entire research team.


### App Screens
<p align="center">
<img src="https://github.com/user-attachments/assets/19247bcc-6351-454d-8e75-7b217e82b49c" width="20%" />
<img src="https://github.com/user-attachments/assets/bae75758-ce76-4838-9f0a-6a0eaa3d8637" width="20%" />
<img src="https://github.com/user-attachments/assets/f14ee199-d1c2-4ca0-bfef-0b9d82df2e96" width="21.4%" />
<img src="https://github.com/user-attachments/assets/450fb93e-db43-4fa9-8966-7b7f5b8e4cec" width="21.5%" />
</p>
<p align="center">
<img src="https://github.com/user-attachments/assets/064e4986-ab34-4347-9fe0-99afe9b4ab00" width="20%" />
<img src="https://github.com/user-attachments/assets/075af959-2299-42bb-9915-f80825ae1b6a" width="20%" />
<img src="https://github.com/user-attachments/assets/84fe1c57-604c-47e8-8b0e-d5b78cba1acf" width="20%" />
<img src="https://github.com/user-attachments/assets/b21024bf-7939-4f64-84e9-027ddb4f2ace" width="20%" />
</p>
<p align="center">
<img src="https://github.com/user-attachments/assets/8e9fede2-77b1-4588-9592-cb598edd0baf" width="20%" />
<img src="https://github.com/user-attachments/assets/20833942-f3f5-4810-8569-4e7976771819" width="20%" />
<img src="https://github.com/user-attachments/assets/a8824cd7-e4e3-4c1f-9eac-066e839c8bef" width="20%" />
<img src="https://github.com/user-attachments/assets/1157508b-8adc-4e11-ad03-57f8ac79f15f" width="20%" />
</p>
<p align="center">
<img src="https://github.com/user-attachments/assets/940d8600-4f38-4760-b7ce-35dad1cebc54" width="20%" />
<img src="https://github.com/user-attachments/assets/25eb75ae-af18-4534-b0f8-0c0893a9a731" width="20%" />
</p>





## Cutomization
### 1. YOLOv5 model training

You can train your own model on custom dataset using this YOLOv5 Colab Notebook

<a href="https://colab.research.google.com/github/ultralytics/yolov5/blob/master/tutorial.ipynb"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"></a>

### 2. Model Conversion & Optimization

Convert your model to torchscript format to run on smartphones.

```bash
!python export.py --weights "the weights of your model" --include torchscript --img 640 --optimize
```

### 3. Save models and labels

Save the best.torchscript and labels.txt files in the following directory. Remember to replace your label names in labels.txt file and update number of classes in loadModel() function homeScreen.dart.

```bash
assets:
- assets/models/best.torchscript
- assets/labels/labels.txt
```

```dart
  Future loadModel() async {
    String pathObjectDetectionModel = "assets/models/best.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
          // change the 2 with number of classes in your model I had almost 2 classes so I added 2 here.
          pathObjectDetectionModel,
          2, // Number of Classes
          640, // Image width
          640, // Image Height
          labelPath: "assets/labels/labels.txt");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }
  ```
