import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  dynamic _scanResults;
  CameraController _camera;
  File pickedImage;
  var imageFile;
  List<Rect> rect = new List<Rect>();
  bool isFaceDetected = false;

  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    // getRects();
  }

  Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

//   getRects(image) async {
//     // var awaitImage = await ImagePicker.pickImage(source: ImageSource.gallery);
//     imageFile = await image.readAsBytes();
//     imageFile = await decodeImageFromList(imageFile);
//     setState(() {
//       imageFile = imageFile;
//       pickedImage = image;
//     });
//     FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);
//     final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
//     final List<Face> faces = await faceDetector.processImage(visionImage);
//     if (rect.length > 0) {
//       rect = new List<Rect>();
//     }
//     for (Face face in faces) {
//       rect.add(face.boundingBox);
//       print(face.boundingBox.height);
//       final double rotY =
//           face.headEulerAngleY; // Head is rotated to the right rotY degrees
//       final double rotZ =
//           face.headEulerAngleZ; // Head is tilted sideways rotZ degrees
// //  print(‘the rotation y is ‘ + rotY.toStringAsFixed(2));
// //  print(‘the rotation z is ‘ + rotZ.toStringAsFixed(2));
//     }
//     print(faces.length);
//     setState(() {
//       isFaceDetected = true;
//     });
//   }

  void _initializeCamera() async {
    _camera = CameraController(
      await _getCamera(_direction),
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );
    await _camera.initialize();
    setState(() {});
    _camera.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;
      try {
        // print(image.format.group.index);
        Uint8List bytes = concatenatePlanes(image.planes);
        var file = File.fromRawPath(bytes);
        // final path = await getFilePath();
        // new File(path).writeAsBytes(bytes).then((File file) async {
        //   print("path: " + file.path);
        // });
        // getRects(file);
      } catch (e) {
        // await handleExepction(e)
      } finally {
        _isDetecting = false;
      }
    });
  }

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }

  Widget build(BuildContext context) {
    if (_camera == null) {
      return Container();
    } else {
      if (!_camera.value.isInitialized) {
        return Container();
      }
      return AspectRatio(
          aspectRatio: _camera.value.aspectRatio,
          child: CameraPreview(_camera));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _camera.dispose();
  }
}
