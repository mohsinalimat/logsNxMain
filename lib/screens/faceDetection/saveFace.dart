import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logsnx/screens/faceDetection/previewImage.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';
import 'package:path_provider/path_provider.dart';

class RegisterFaceScreen extends StatefulWidget {
  var checkIn;
  var isWifi;
  var what;
  RegisterFaceScreen({this.checkIn, this.isWifi, this.what});
  @override
  _RegisterFaceScreenState createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> {
  CameraController controller;
  String videoPath;
  Timer timer;
  List<CameraDescription> cameras;
  int selectedCameraIdx;
  var userId;
  var companyId;
  List faces = [];
  String accessKey = "AKIAJHC7T3YXPAGA2GUQ",
      secretKey = "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",
      region = "eu-west-2";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print("Hi");
    Auth().getCompanyId().then((c) {
      Auth().getUserId().then((u) {
        userId = u;
        companyId = c;
        EmployeeService()
            .getMyFaces({"user": userId, "company": companyId}).then((value) {
          print(value);
          this.faces = value;
        });
      });
    });
    // Get the listonNewCameraSelected of available cameras.
    // Then set the first camera as selected.
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 1;
        });

        _onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldKey,
        body: Stack(children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: _cameraPreviewWidget(),
          ),
          Positioned(
              top: 30,
              left: 00,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
          Positioned(
              bottom: 20,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: widget.checkIn
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(100)),
                                child: _captureControlRowWidget(
                                    checkIn: true),
                              )),
                          // GestureDetector(
                          //     onTap: () {},
                          //     child: Container(
                          //       width: 70,
                          //       height: 70,
                          //       decoration: BoxDecoration(
                          //           color: Colors.red,
                          //           borderRadius: BorderRadius.circular(100)),
                          //       child: _captureControlRowWidget(
                          //           checkIn: true, what: 1),
                          //     )),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: 70,
                            height: 70,
                            child: null,
                          ),
                          GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(100)),
                                child: _captureControlRowWidget(),
                              )),
                          GestureDetector(
                            onTap: !widget.checkIn
                                ? () {
                                    getVideoFromGalary();
                                  }
                                : null,
                            child: Container(
                              width: 70,
                              height: 70,
                              child: !widget.checkIn
                                  ? Icon(
                                      Icons.image,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : Container(),
                            ),
                          ),
                        ],
                      ),
              ))
        ]));
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  // Display 'Loading' text when the camera is still loading.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null) {
      return Row();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return GestureDetector(
        onTap: _onSwitchCamera,
        child: Icon(
          _getCameraLensIcon(lensDirection),
          color: Colors.white,
        ));
  }

  /// Display the control bar with buttons to record videos.
  Widget _captureControlRowWidget({checkIn: false}) {
    if (!checkIn) {
      return GestureDetector(
          child: Icon(
            Icons.camera_enhance,
            color: Colors.white,
          ),
          onTap: controller != null && controller.value.isInitialized
              ? () {
                print("yo");
                  _onRecordButtonPressed(widget.what);
                }
              : () {});
    } else {
      return GestureDetector(
          child: Center(
            // child: Text(what == 1 ? "OUT" : "IN",
            //     style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold)),
            child: Icon(Icons.camera_alt, color: Colors.white),
          ),
          onTap: controller != null && controller.value.isInitialized
              ? () {
                  if (faces.length == 0) {
                    Fluttertoast.showToast(
                        msg: 'No Face Registered',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.red,
                        textColor: Colors.white);
                  } else {
                    _onRecordButtonPressed(widget.what);
                  }
                }
              : () {});
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription,
        Platform.isIOS ? ResolutionPreset.low : ResolutionPreset.low);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${controller.value.errorDescription}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed(what) {
    _startVideoRecording(what).then((String filePath) {});
  }

  Future<String> _startVideoRecording(what) async {
    if (!controller.value.isInitialized) {
      Fluttertoast.showToast(
          msg: 'Please wait',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.grey,
          textColor: Colors.white);

      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/faces';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/${currentTime}.png';

    try {
      await controller.takePicture(filePath);
      videoPath = filePath;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewImageScreen(
                imagePath: videoPath,
                checkIn: widget.checkIn,
                what: widget.what,
                isWifi: widget.isWifi,
                faces: faces)),
      ).then((value) {
        if (value != null) {
          Navigator.pop(context);
        }
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    Fluttertoast.showToast(
        msg: 'Error: ${e.code}\n${e.description}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  getVideoFromGalary() async {
    var filePath = await FilePicker.platform.pickFiles(type: FileType.image);
    if (filePath != null) {
      this.videoPath = filePath.files[0].path;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewImageScreen(
                  imagePath: videoPath,
                  checkIn: widget.checkIn,
                )),
      ).then((value) {
        if (value != null) {
          Navigator.of(context).pop(true);
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    this.controller.dispose();
    this.timer?.cancel();
  }
}
