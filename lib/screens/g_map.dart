import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logsnx/screens/faceDetection/saveFace.dart';
// import 'package:latlong/latlong.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/config.dart';
import 'package:logsnx/services/employee.dart';
import 'package:toggle_switch/toggle_switch.dart';

class GMapScreen extends StatefulWidget {
  @override
  _GMapScreenState createState() => _GMapScreenState();
}

class _GMapScreenState extends State<GMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Circle> circles = {};
  Set<Marker> markers = {};
  BitmapDescriptor img;
  var companyId;
  var userId;
  var isLocationAvail = false;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(Config.lat != null ? double.parse(Config.lat) : 25.1972018,
        Config.lng != null ? double.parse(Config.lng) : 55.2721877),
    zoom: 16,
  );

  CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(Config.lat != null ? double.parse(Config.lat) : 25.1972018,
          Config.lng != null ? double.parse(Config.lng) : 55.2721877),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  getSubEmployees() async {
    EmployeeService().getEmployees(userId, companyId).then((value) {
      print(value);
      value.forEach((item) {
        if (item["uId"] != null) {
          print(item["uId"]["latitude"]);
          if (item["uId"]["latitude"] != null) {
            this.markers.add(Marker(
                markerId: MarkerId(item["uId"]["_id"]),
                onTap: () {},
                // alpha: 10.0,
                infoWindow: InfoWindow(
                    title: item["uId"]["username"] == null
                        ? ""
                        : item["uId"]["username"]),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRose),
                position: LatLng(double.parse(item["uId"]["latitude"]),
                    double.parse(item["uId"]["longitude"]))));
          }
          setState(() {});
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // GoogleMapPolyUtil.containsLocation(point: , polygon: Circle())
    // GeoFenc

    Auth().getUserId().then((u) {
      this.userId = u;
      Auth().getCompanyId().then((c) async {
        companyId = c;
        Auth().getRole().then((value) {
          if (value == "Admin") {
            this.getSubEmployees();
          }
        });

        print("I am here");
        if (Config.lat != null) {
          this.isLocationAvail = true;
          this.markers.add(Marker(
              flat: true,
              markerId: MarkerId(u),
              onTap: () {},
              // alpha: 10.0,
              infoWindow: InfoWindow(title: "You"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              position:
                  LatLng(double.parse(Config.lat), double.parse(Config.lng))));
        }
        setState(() {});

        EmployeeService().getFences(c).then((fs) {
          print(fs);
          Config.geoFences = fs;
          for (var i = 0; i < Config.geoFences.length; i++) {
            this.circles.add(Circle(
                //radius marker
                center: LatLng(double.parse(Config.geoFences[i]["lat"]),
                    double.parse(Config.geoFences[i]["lng"])),
                fillColor: Colors.blue.withOpacity(0.3),
                strokeWidth: 1,
                strokeColor: Colors.blue,
                radius: double.parse(Config.geoFences[i]["radius"]),
                circleId: CircleId(Config.geoFences[i]["_id"]) //radius
                ));
          }
          setState(() {});
        });
      });
    });

    // _controller
  }

  _showAlert(text) {
    Fluttertoast.showToast(
      msg: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: GoogleMap(
          mapType: MapType.satellite,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          mapToolbarEnabled: false,
          circles: circles,
          markers: markers,
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: check,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
      bottomSheet: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: 50,
                child: FlatButton(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  color: Color(0xFF000000),
                  onPressed: () {
                    EmployeeService().checkFence({
                      "lat": Config.lat,
                      "lng": Config.lng,
                      "cid": companyId,
                      "userId": userId,
                      "type": "fence"
                    }).then((d) {
                      if (!isLocationAvail) {
                        _showAlert("Your Location is not enabled");
                      } else if (!d["settings"]["fenceLoginEnabled"]) {
                        _showAlert("Checkin with fence is not enabled");
                      } else {
                        if (d["fences"] == 0 &&
                            !d["settings"]["outsideFence"]) {
                          _showAlert("You are not in any fence");
                        } else {
                          var projects = d["projects"];
                          var check = 0;
                          var textField = TextEditingController();
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext bc) {
                                return Container(
                                  margin: EdgeInsets.fromWindowPadding(
                                      WidgetsBinding.instance.window.viewInsets,
                                      WidgetsBinding
                                          .instance.window.devicePixelRatio),
                                  child: new Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Center(
                                              child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 0),
                                                child: ToggleSwitch(
                                                  activeBgColor:
                                                      Color(0xFF444152),
                                                  activeFgColor: Colors.white,
                                                  inactiveBgColor: Colors.white,
                                                  inactiveFgColor: Colors.black,
                                                  initialLabelIndex: check,

                                                  // icons: [Icons.transit_enterexit, Icons.remove_circle],
                                                  labels: [
                                                    'IN',
                                                    'OUT',
                                                  ],
                                                  onToggle: (i) {
                                                    setState(() {
                                                      check = i;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  10, 0, 10, 20),
                                            ),
                                            Wrap(
                                              children: d["fences"] == 0
                                                  ? [
                                                      Text(
                                                          "Project Name (Optional)"),
                                                      Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .8,
                                                          child: TextField(
                                                            controller:
                                                                textField,
                                                          ))
                                                    ]
                                                  : List.generate(
                                                      projects.length, (index) {
                                                      return ListTile(
                                                          leading:
                                                              Icon(Icons.work),
                                                          title: new Text(projects[
                                                                      index]
                                                                  ["name"] +
                                                              " - " +
                                                              projects[index]
                                                                      ["fence"]
                                                                  ["name"]),
                                                          onTap: () {
                                                            print("he");
                                                            Auth().saveCurrentProject(
                                                                projects[index]
                                                                    ["name"]);
                                                            print("Helo");
                                                            var data = {
                                                              "user": userId,
                                                              "company":
                                                                  companyId,
                                                              "project":
                                                                  projects[
                                                                          index]
                                                                      ["name"],
                                                              "wifiName": projects[
                                                                          index]
                                                                      ["fence"]
                                                                  ["name"],
                                                              "mode": check == 0
                                                                  ? "IN"
                                                                  : "OUT",
                                                              "latlng":
                                                                  Config.lat +
                                                                      ", " +
                                                                      Config.lng
                                                            };
                                                            print(check);
                                                            EmployeeService()
                                                                .checkWithFence(
                                                                    data)
                                                                .then((value) {
                                                              print(value);
                                                              if (check == 0) {
                                                                _showAlert(
                                                                    "Check In Successfully");
                                                              } else {
                                                                _showAlert(
                                                                    "Check Out Successfully");
                                                              }

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            });
                                                          });
                                                    }),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 20, 0, 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  FloatingActionButton(
                                                    child: Icon(Icons.close),
                                                    backgroundColor: Colors.red,
                                                    // color: Colors.red,
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: d["fences"] != 0
                                                        ? 0
                                                        : 20,
                                                  ),
                                                  d["fences"] != 0
                                                      ? Container()
                                                      : FloatingActionButton(
                                                          child:
                                                              Icon(Icons.send),
                                                          backgroundColor:
                                                              Colors.green,
                                                          // color: Colors.red,
                                                          onPressed: () {
                                                            print("he");
                                                            Auth()
                                                                .saveCurrentProject(
                                                                    textField
                                                                        .text);
                                                            print("Helo");
                                                            var data = {
                                                              "user": userId,
                                                              "company":
                                                                  companyId,
                                                              "project":
                                                                  textField
                                                                      .text,
                                                              "wifiName":
                                                                  textField
                                                                      .text,
                                                              "mode": check == 0
                                                                  ? "IN"
                                                                  : "OUT",
                                                              "latlng":
                                                                  Config.lat +
                                                                      ", " +
                                                                      Config.lng
                                                            };
                                                            print(check);
                                                            EmployeeService()
                                                                .checkWithFence(
                                                                    data)
                                                                .then((value) {
                                                              print(value);
                                                              if (check == 0) {
                                                                _showAlert(
                                                                    "Check In Successfully");
                                                              } else {
                                                                _showAlert(
                                                                    "Check Out Successfully");
                                                              }

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            });
                                                          },
                                                        ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ]),
                                );
                              });
                        }
                      }

                      // print(value);
                    });
                  },
                  child: Text(
                    "Checkin With Geofence",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                height: 50,
                child: FlatButton(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  // color: Colors.red,
                  onPressed: () {
                    EmployeeService().checkFence({
                      "lat": Config.lat,
                      "lng": Config.lng,
                      "cid": companyId,
                      "userId": userId,
                      "type": "fence"
                    }).then((d) {
                      print(d);
                      if (!isLocationAvail) {
                        _showAlert("Your Location is not enabled");
                      } else if (!d["settings"]["faceLoginEnabled"]) {
                        _showAlert("Checkin with face is not enabled");
                      } else {
                        if (d["fences"] == 0 &&
                            !d["settings"]["outsideFence"]) {
                          _showAlert("You are not in any fence");
                        } else {
                          var projects = d["projects"];
                          var check = 0;
                          var textField = TextEditingController();
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext bc) {
                                return Container(
                                  child: new Wrap(children: [
                                    Column(
                                      children: <Widget>[
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0),
                                            child: ToggleSwitch(
                                              activeBgColor: Color(0xFF444152),
                                              activeFgColor: Colors.white,
                                              inactiveBgColor: Colors.white,
                                              inactiveFgColor: Colors.black,
                                              initialLabelIndex: check,
                                              labels: [
                                                'IN',
                                                'OUT',
                                              ],
                                              onToggle: (i) {
                                                check = i;
                                              },
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              10, 0, 10, 20),
                                        ),
                                        Wrap(
                                          children: d["fences"] == 0
                                              ? [
                                                  Text(
                                                      "Project Name (Optional)"),
                                                  Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .8,
                                                      child: TextField(
                                                        controller: textField,
                                                      ))
                                                ]
                                              : List.generate(projects.length,
                                                  (index) {
                                                  return ListTile(
                                                      leading: Icon(Icons.work),
                                                      title: new Text(
                                                          projects[index]
                                                                  ["name"] +
                                                              " - " +
                                                              projects[index]
                                                                      ["fence"]
                                                                  ["name"]),
                                                      onTap: () {
                                                        print("he");
                                                        Auth()
                                                            .saveCurrentProject(
                                                                projects[index]
                                                                    ["name"]);
                                                        print("Helo");
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RegisterFaceScreen(
                                                                      checkIn:
                                                                          true,
                                                                      isWifi:
                                                                          false,
                                                                      what:
                                                                          check)),
                                                        ).then((value) {
                                                          // this.getLog();
                                                        });

                                                        // var data = {
                                                        //   "user": userId,
                                                        //   "company": companyId,
                                                        //   "project": projects[index]
                                                        //       ["name"],
                                                        //   "wifiName": projects[index]
                                                        //       ["fence"]["name"],
                                                        //   "mode":
                                                        //       check == 0 ? "IN" : "OUT",
                                                        //   "latlng": Config.lat +
                                                        //       ", " +
                                                        //       Config.lng
                                                        // };
                                                        // print(check);
                                                        // EmployeeService()
                                                        //     .checkWithFence(data)
                                                        //     .then((value) {
                                                        //   print(value);
                                                        //   if (check == 0) {
                                                        //     _showAlert(
                                                        //         "Check In Successfully");
                                                        //   } else {
                                                        //     _showAlert(
                                                        //         "Check Out Successfully");
                                                        //   }

                                                        //   Navigator.of(context).pop();
                                                        // });
                                                      });
                                                }),
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 20, 0, 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              FloatingActionButton(
                                                child: Icon(Icons.close),
                                                backgroundColor: Colors.red,
                                                // color: Colors.red,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              SizedBox(
                                                width:
                                                    d["fences"] != 0 ? 0 : 20,
                                              ),
                                              d["fences"] != 0
                                                  ? Container()
                                                  : FloatingActionButton(
                                                      child: Icon(Icons.send),
                                                      backgroundColor:
                                                          Colors.green,
                                                      // color: Colors.red,
                                                      onPressed: () {
                                                        Auth()
                                                            .saveCurrentProject(
                                                                textField.text);
                                                        print("Helo");
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RegisterFaceScreen(
                                                                      checkIn:
                                                                          true,
                                                                      isWifi:
                                                                          false,
                                                                      what:
                                                                          check)),
                                                        ).then((value) {
                                                          // this.getLog();
                                                        });
                                                      },
                                                    ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ]),
                                );
                              });
                        }
                      }

                      // print(value);
                    });

                    // print("Yo");
                    // EmployeeService().checkFence({
                    //   "lat": Config.lat,
                    //   "lng": Config.lng,
                    //   "cid": companyId
                    // }).then((d) {
                    //   if (d["fences"] > 0) {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => RegisterFaceScreen(
                    //                 checkIn: true,
                    //                 isWifi: false,
                    //               )),
                    //     ).then((value) {
                    //       // this.getLog();
                    //     });
                    //   } else {
                    //     _showAlert("You are not in any fence");
                    //   }
                    // });
                  },
                  child: Text("Checkin With Face"),
                ),
              ),
            ]),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
