// import 'package:aws_ai/aws_ai.dart';
// import 'package:aws_s3/aws_s3.dart';
import 'dart:convert';
import 'dart:io';

// import 'package:amazon_s3_cognito/amazon_s3_cognito.dart';
// import 'package:amazon_s3_cognito/aws_region.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
// import 'package:image_crop/image_crop.dart';
import 'package:logsnx/screens/tabs.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/config.dart';
import 'package:logsnx/services/employee.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class PreviewImageScreen extends StatefulWidget {
  var imagePath;
  var checkIn;
  var what;
  var isWifi;
  List faces;
  PreviewImageScreen(
      {@required this.imagePath,
      this.checkIn,
      this.what,
      this.isWifi,
      this.faces});
  @override
  _PreviewImageScreenState createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {
  List<Rect> rect = new List<Rect>();
  bool isFaceDetected = false;
  var imageFile;
  var hrId;
  var userId;

  var companyId;
  var uploading = false;
  File sourceImagefile;
  String accessKey = "AKIAJHC7T3YXPAGA2GUQ",
      secretKey = "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",
      region = "eu-west-2";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth().getCompanyId().then((c) {
      Auth().getUserId().then((e) {
        this.userId = e;
        this.companyId = c;
      });
    });
    detectFaces();
  }

  detectFaces() async {
    // if (widget.checkIn) {
    //   compareFace();
    // } else {
    //   uploadFace();
    // }

    // this.sourceImagefile = File(widget.imagePath);

    // RekognitionHandler rekognition =
    //     new RekognitionHandler(accessKey, secretKey, region);
    // Future<String> labelsArray = rekognition.detectFaces(sourceImagefile);
    // labelsArray.then((value) {
    //   var v = json.decode(value);
    //   var fd = v["FaceDetails"];
    //   var faces = fd.length;
    //   if (faces == 0) {
    //     _showAlert("No Face Detected");
    //     Timer(Duration(seconds: 2), () {
    //       Navigator.of(context).pop();
    //     });
    //   } else if (faces > 1) {
    //     _showAlert("More Than One Face Detected");
    //     Timer(Duration(seconds: 2), () {
    //       Navigator.of(context).pop();
    //     });
    //   } else if (faces == 1) {
    //     print(fd);
    //   }
    //   print(v);
    // });
    var file = File(widget.imagePath);
    imageFile = await file.readAsBytes();
    imageFile = await decodeImageFromList(imageFile);
    if (Platform.isIOS) {
      setState(() {
        uploading = true;
      });
      var name = DateTime.now().millisecondsSinceEpoch.toString();
      final bytes = file.readAsBytesSync();

      String img64 = base64Encode(bytes);
      EmployeeService().uploadToS3(name + ".png", img64).then((value) {
        print(value);
        EmployeeService().detectFaces(name + ".png").then((faces) {
          if (faces["length"] == 1) {
            if (widget.checkIn) {
              compareFace(name + ".png");
            } else {
              uploadFace(name + ".png");
            }
          } else if (faces["length"] > 1) {
            _showAlert("More than one face detected");
            Navigator.pop(context);
          } else {
            _showAlert("No Face Found");
            Navigator.pop(context);
          }
        });
      });
    } else {
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFile(file);
      final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
      final List<Face> faces = await faceDetector.processImage(visionImage);
      faceDetector.close();
      if (rect.length > 0) {
        rect = new List<Rect>();
      }
      for (Face face in faces) {
        rect.add(face.boundingBox);
        final double rotY =
            face.headEulerAngleY; // Head is rotated to the right rotY degrees
        final double rotZ =
            face.headEulerAngleZ; // Head is tilted sideways rotZ degrees
      }

      setState(() {
        isFaceDetected = true;
      });
      if (rect.length == 1) {
        setState(() {
          uploading = true;
        });
        var name = DateTime.now().millisecondsSinceEpoch.toString();
        final bytes = file.readAsBytesSync();

        String img64 = base64Encode(bytes);
        EmployeeService().uploadToS3(name + ".png", img64).then((value) {
          print(value);
          if (widget.checkIn) {
            compareFace(name + ".png");
          } else {
            uploadFace(name + ".png");
          }
        });

        // AwsS3 awsS3 = AwsS3(
        //     awsFolderPath: "",
        //     file: file,
        //     fileNameWithExt: name + ".png",
        //     poolId: "eu-west-2:4a4cf664-2d32-417a-bcb7-f907205a1e7e",
        //     region: Regions.EU_WEST_2,
        //     bucketName: "logsnx");
        // String uploadedImageUrl;
        // try {
        //   try {
        //     uploadedImageUrl = await awsS3.uploadFile;
        //     debugPrint("Result :'$uploadedImageUrl'.");
        //   } on PlatformException {
        //     _showAlertBox(context, uploadedImageUrl);
        //     debugPrint("Result :'$uploadedImageUrl'.");
        //   }
        // } on PlatformException catch (e) {
        //   _showAlertBox(context, uploadedImageUrl);

        //   debugPrint("Failed :'${e.message}'.");
        // }

        // String uploadedImageUrl;

        // AmazonS3Cognito.upload(
        //         file.path,
        //         "logsnx",
        //         "eu-west-2:4a4cf664-2d32-417a-bcb7-f907205a1e7e",
        //         name + ".png",
        //         AwsRegion.EU_WEST_2,
        //         AwsRegion.EU_WEST_2)
        //     .catchError(
        //         (onError) => {_showAlertBox(context, json.encode(onError))})
        //     .then((value) {
        //       // _showAlertBox(context, json.encode(value));
        //   uploadedImageUrl = value;
        //   if (widget.checkIn) {
        //     compareFace(name + ".png");
        //   } else {
        //     uploadFace(name + ".png");
        //   }
        // });

        // try {
        //   try {
        //     // uploadedImageUrl = await ;
        //     debugPrint("Result :'$uploadedImageUrl'.");
        //   } on PlatformException {
        //     _showAlertBox(context, json.encode(uploadedImageUrl));
        //     debugPrint("Result :'$uploadedImageUrl'.");
        //     return null;
        //   }
        // } on PlatformException catch (e) {
        //   _showAlertBox(context, json.encode(uploadedImageUrl));

        //   debugPrint("Failed :'${e.message}'.");
        //   return null;
        // }

        // String uploadedImageUrl = await awsS3.uploadFile;
        // uploadedImageUrl = await AmazonS3Cognito.upload(
        //         file.path,
        //         "logsnx",
        //         "eu-west-2:4a4cf664-2d32-417a-bcb7-f907205a1e7e",
        //         name + ".png",
        //         AwsRegion.EU_WEST_2,
        //         AwsRegion.EU_WEST_2);
        // print(uploadedImageUrl);
        // print(rect[0]);
        // try {
        //   ImageCrop.requestPermissions().then((value) {
        //     ImageCrop.cropImage(
        //       file: File(widget.imagePath),
        //       area: rect[0],
        //     ).then((value) {
        //       print(value);
        //       print(value.path);
        //     });
        //   });
        // } on Exception catch (e) {
        //   print(e);
        // }

        // if (widget.checkIn) {
        //   compareFace(name + ".png");
        // } else {
        //   uploadFace(name + ".png");
        // }
      } else {
        _showAlert("No Face Found");
        Navigator.pop(context);
      }
    }
  }

  void _showAlertBox(BuildContext context, String data) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("S3 Error Test"),
              content: Text(data),
            ));
  }

  _showAlert(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  uploadFace(image) async {
    // var file;
    // File fl = File(widget.imagePath);
    // final dir = await path_provider.getTemporaryDirectory();
    // final targetPath = dir.absolute.path + "/temp.png";
    // // print(fl.lengthSync());
    // // File fl1 = await FlutterImageCompress.compressAndGetFile(
    // //     fl.absolute.path, targetPath,
    // //     format: CompressFormat.png, quality: 10);
    // // print(fl1.lengthSync());

    // String fileName = fl.path.split('/').last;
    // file = await MultipartFile.fromFile(
    //   fl.path,
    //   filename: fileName,
    // );
    // var data = {"image": file};
    // var fd = FormData.fromMap(data);
    EmployeeService().addFace(
        {"company": companyId, "user": userId, "image": image}).then((value) {
      if (value["message"] == "Face Added") {
        _showAlert("Face Added Successfully For Registeration");
        Navigator.pop(context, true);
      } else {
        _showAlert(value["message"]);
        Navigator.pop(context, true);
      }
    });
  }

  compareFace(image) async {
    // File sourceImagefile, targetImagefile; //load source and target images in those File objects

    // RekognitionHandler rekognition =
    //     new RekognitionHandler(accessKey, secretKey, region);
    // Future<String> labelsArray =
    //     rekognition.compareFaces(sourceImagefile, targetImagefile);
    // var file;
    // File fl = File(widget.imagePath);
    // final dir = await path_provider.getTemporaryDirectory();
    // final targetPath = dir.absolute.path + "/temp.png";
    // // print(fl.lengthSync());
    // // File fl1 = await FlutterImageCompress.compressAndGetFile(
    // //     fl.absolute.path, targetPath,
    // //     format: CompressFormat.png, quality: 50,);
    // // print(fl1.lengthSync());
    // String fileName = fl.path.split('/').last;
    // file = await MultipartFile.fromFile(
    //   fl.path,
    //   filename: fileName,
    // );
    // var data = {"image": file};
    // var fd = FormData.fromMap(data);
    String wifiName = await Connectivity().getWifiName();
    var mode = "OUT";
    print(widget.what);
    if (widget.what == 0) {
      mode = "IN";
    }
    var latlng = "";
    if (!widget.isWifi) {
      latlng = Config.lat + "," + Config.lng;
    }
    var project = await Auth().getCurrentProject();
    print(project);
    // if
    EmployeeService().compareFace({
      "company": companyId,
      "user": userId,
      "image": image,
      "mode": mode,
      "project": project,
      "wifiname": wifiName,
      "latlng": latlng
    }).then((value) {
      print(value);
      if (value["result"] == true) {
        if (widget.what == 0) {
          _showAlert("Check In Successfull");
        } else {
          _showAlert("Check Out Successfull");
        }
        Navigator.pop(context, true);
      } else {
        _showAlert("Face Not Recognized");
        Navigator.pop(context, true);
      }
    });
  }

  void _showDialog(check) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              Text("Checked " + check + " Successfully")
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isFaceDetected
          ? Center(child: Text("Detecting Face"))
          : Stack(
              children: <Widget>[
                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Container(
                      width: imageFile.width.toDouble(),
                      height: imageFile.height.toDouble(),
                      child: CustomPaint(
                        painter: FacePainter(rect: rect, imageFile: imageFile),
                      ),
                    ),
                  ),
                ),
                uploading
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white.withAlpha(80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF444152)),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Text(
                                "Recognizing",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 25),
                              ),
                            )
                          ],
                        ))
                    : Container(),
                Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      title: Text("Face Detection Result"),
                      // actions: <Widget>[
                      //   (rect.length > 1 || rect.length == 0)
                      //       ? IconButton(
                      //           icon: Icon(Icons.refresh),
                      //           onPressed: () {
                      //             Navigator.pop(context);
                      //           },
                      //         )
                      //       : IconButton(
                      //           icon: Icon(Icons.file_upload),
                      //           onPressed: () {
                      //             if (widget.checkIn) {
                      //               compareFace();
                      //             } else {
                      //               uploadFace();
                      //             }
                      //           },
                      //         )
                      // ],
                    ),
                    body: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 20,
                      color: (rect.length > 1 || rect.length == 0)
                          ? Colors.red
                          : Colors.green,
                      child: Center(
                          child: Text(
                        rect.length == 0
                            ? "No Face Detected"
                            : rect.length > 1
                                ? "More Than One Face Detected"
                                : "Successfully Detected",
                        style: TextStyle(color: Colors.white),
                      )),
                    )),
              ],
            ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Rect> rect;
  var imageFile;

  FacePainter({@required this.rect, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }

    for (Rect rectangle in rect) {
      canvas.drawRect(
        rectangle,
        Paint()
          ..color = Colors.teal
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
