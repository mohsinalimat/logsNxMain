import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:fancy_bottom_bar/fancy_bottom_bar.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ios_network_info/ios_network_info.dart';
import 'package:logsnx/screens/checkIn.dart';
import 'package:logsnx/screens/faceDetection/saveFace.dart';
import 'package:logsnx/screens/g_map.dart';
import 'package:logsnx/screens/home.dart';
import 'package:logsnx/screens/map.dart';
import 'package:logsnx/screens/profile.dart';
import 'package:logsnx/screens/settings.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/config.dart';
import 'package:logsnx/services/employee.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//     as bg;
import 'dart:convert';

JsonEncoder encoder = new JsonEncoder.withIndent("     ");

class TabsScreen extends StatefulWidget {
  bool isHod;
  TabsScreen({this.isHod});
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  var internet = true;
  var empSrv = new EmployeeService();
  var auth = new Auth();
  var userId;
  var hrId;
  var companyId;
  var totalTabs = 3;
  ScrollController scrollController;
  bool dialVisible = true;
  var hodTabs = [
    FancyBottomItem(
      icon: Icon(Icons.list),
      title: Text("Logs", style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    FancyBottomItem(
        icon: Icon(Icons.map),
        title: Text("Map", style: TextStyle(fontWeight: FontWeight.bold))),
    FancyBottomItem(
        icon: Icon(Icons.settings),
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold))),
  ];
  var noHodTabs = [
    FancyBottomItem(
        icon: Icon(Icons.list),
        title: Text("Logs", style: TextStyle(fontWeight: FontWeight.bold))),
    FancyBottomItem(
        icon: Icon(Icons.map),
        title: Text("Map", style: TextStyle(fontWeight: FontWeight.bold))),
    FancyBottomItem(
        icon: Icon(Icons.settings),
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold))),
  ];

  bool _isMoving;
  bool _enabled;
  String _motionActivity;
  String _odometer;
  String _content;
  String status = "";
  String geofenceState = 'N/A';
  var cntrl = MapController();
  var lat = 0.0;
  var lng = 0.0;
  var _currentIndex = 0;

  var macIsVerified = false;
  var macs = [];
  bool isWifi;

  // setupGeoFencing() {
  //   _isMoving = false;
  //   _enabled = false;
  //   _content = '';
  //   _motionActivity = 'UNKNOWN';
  //   _odometer = '0';
  //   // 1.  Listen to events (See docs for all 12 available events).
  //   bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
  //     print('[geofence] ${event.identifier}, ${event.action}');
  //     print(event.action);
  //     var f = event.identifier.split("-");
  //     var index = int.parse(f[1]);
  //     if (Config.geoFences != null) {
  //       var fence = Config.geoFences[index];
  //       var projects = fence["projects"];
  //       if (event.action == "ENTER") {
  //         if (projects.length == 0) {
  //         } else {
  //           String name = "Select Project, Fence Name: " + fence["name"];
  //           showModalBottomSheet(
  //               context: context,
  //               builder: (BuildContext bc) {
  //                 return Container(
  //                   child: new Wrap(children: [
  //                     Column(
  //                       children: <Widget>[
  //                         Container(
  //                             margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
  //                             child: Text(
  //                               name,
  //                               style: TextStyle(
  //                                   fontWeight: FontWeight.bold, fontSize: 20),
  //                             )),
  //                         Wrap(
  //                           children: List.generate(projects.length, (index) {
  //                             return ListTile(
  //                                 leading: Icon(Icons.work),
  //                                 title: new Text(projects[index]["name"]),
  //                                 onTap: () {
  //                                   print("he");
  //                                   Auth().saveCurrentProject(
  //                                       projects[index]["name"]);
  //                                   print("Helo");
  //                                   var data = {
  //                                     "user": userId,
  //                                     "company": companyId,
  //                                     "project": projects[index]["name"],
  //                                     "wifiName": fence["name"],
  //                                     "mode": "IN",
  //                                     "latlng": Config.lat + ", " + Config.lng
  //                                   };
  //                                   EmployeeService()
  //                                       .checkWithFence(data)
  //                                       .then((value) {
  //                                     _showAlert("Check In Successfully");
  //                                     Navigator.of(context).pop();
  //                                   });
  //                                 });
  //                           }),
  //                         ),
  //                         Container(
  //                           margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: <Widget>[
  //                               FloatingActionButton(
  //                                 child: Icon(Icons.close),
  //                                 backgroundColor: Colors.red,
  //                                 // color: Colors.red,
  //                                 onPressed: () {
  //                                   Navigator.of(context).pop();
  //                                 },
  //                               ),
  //                             ],
  //                           ),
  //                         )
  //                       ],
  //                     )
  //                   ]),
  //                 );
  //               });
  //         }
  //       } else if (event.action == "EXIT") {
  //         Auth().getCurrentProject().then((project) {
  //           if (project != null) {
  //             EmployeeService().checkWithFence({
  //               "user": userId,
  //               "company": companyId,
  //               "project": project,
  //               "wifiName": fence["name"],
  //               "mode": "OUT",
  //               "latlng": Config.lat + ", " + Config.lng
  //             }).then((value) {
  //               _showAlert("Check In Successfully");
  //               Navigator.of(context).pop();
  //             });
  //             bg.BackgroundGeolocation.removeGeofences().then((value) => {});
  //           }
  //         });
  //       }
  //       if (mounted) {
  //         setState(() {
  //           this.status = event.action;
  //         });
  //       }
  //     }
  //   });
  //   bg.BackgroundGeolocation.onLocation((bg.Location location) {
  //     print('[location] - $location');
  //     Config.lat = location.coords.latitude.toString();
  //     Config.lng = location.coords.longitude.toString();
  //     Auth().saveMyLocation(Config.lat, Config.lng);
  //     EmployeeService()
  //         .updateLocation(this.userId, Config.lat, Config.lng)
  //         .then((value) => null);
  //   });

  //   bg.BackgroundGeolocation.ready(bg.Config(
  //           desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
  //           distanceFilter: 5.0,
  //           stopOnTerminate: false,
  //           heartbeatInterval: 60,
  //           startOnBoot: true,
  //           // debug: true,
  //           // logLevel: bg.Config.,
  //           reset: true))
  //       .then((bg.State state) {
  //     _onClickEnable(true);
  //     setState(() {
  //       _enabled = state.enabled;
  //       _isMoving = state.isMoving;
  //     });
  //   });
  // }

  _showAlert(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  // void _onClickEnable(enabled) {
  //   if (enabled) {
  //     bg.BackgroundGeolocation.start().then((bg.State state) {
  //       print('[start] success $state');
  //       setState(() {
  //         _enabled = state.enabled;
  //         _isMoving = state.isMoving;
  //       });
  //     });
  //   } else {
  //     bg.BackgroundGeolocation.stop().then((bg.State state) {
  //       print('[stop] success: $state');
  //       // Reset odometer.
  //       bg.BackgroundGeolocation.setOdometer(0.0);

  //       setState(() {
  //         _odometer = '0.0';
  //         _enabled = state.enabled;
  //         _isMoving = state.isMoving;
  //       });
  //     });
  //   }
  // }

  @override
  initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });

    print("Heelo ");
    Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        this.internet = false;
      } else {
        this.internet = true;
      }
    });
    this.auth.getUserId().then((e) {
      this.userId = e;
      setState(() {});
    });
    if (!widget.isHod) {
      setState(() {
        totalTabs = 2;
      });
    }
    this.getLocation();
    Auth().getUserId().then((e) {
      this.userId = e;
      Auth().getCompanyId().then((c) {
        this.companyId = c;
        // getAllMacs();
        // setupGeoFencing();
      });
    });
  }

  showSelectionAlert() {
    showAlertDialog(BuildContext context) {
      // set up the buttons
      Widget cancelButton = FlatButton(
        child: Text("Cancel"),
        onPressed: () {},
      );
      Widget continueButton = FlatButton(
        child: Text("Continue"),
        onPressed: () {},
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("AlertDialog"),
        content: Text(
            "Would you like to continue learning how to use Flutter alerts?"),
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
  }

  checkConnectivity() async {
    var wifiBSSID = "";
    try {
      if (Platform.isIOS) {
        wifiBSSID = await IosNetworkInfo.bssid;
      } else {
        wifiBSSID = await Connectivity().getWifiBSSID();
      }
    } on PlatformException {
      wifiBSSID = '';
    }
    print(wifiBSSID);
    for (var item in macs) {
      String mc = item["mac"];
      if (mc.toLowerCase() == wifiBSSID) {
        setState(() {
          macIsVerified = true;
        });
        break;
      }
    }
  }

  getAllMacs() {
    print("hello Macs");
    EmployeeService().isVerified(userId).then((en) {
      print(en);
      if (en["wifiLogin"] == false) {
        this.isWifi = true;
        EmployeeService().getMacs(companyId).then((value) {
          setState(() {
            this.macs = value;
          });
          // print(value);
          checkConnectivity();
        });
      } else {
        setState(() {
          this.isWifi = false;
          macIsVerified = true;
        });
      }
      print(isWifi.toString());
    });
    // print("yo");
  }

  // setupGeoFences() {
  //   print("hello");
  //   EmployeeService().getFences(companyId).then((value) {
  //     Config.geoFences = [];
  //     for (var item in value) {
  //       if (item["company"] == companyId) {
  //         Config.geoFences.add(item);
  //       }
  //     }
  //     print(Config.geoFences);
  //     bg.BackgroundGeolocation.removeGeofences().then((value) {
  //       for (var i = 0; i < Config.geoFences.length; i++) {
  //         bg.BackgroundGeolocation.addGeofence(
  //           bg.Geofence(
  //               identifier: "MY-" + i.toString(),
  //               radius: double.parse(Config.geoFences[i]["radius"]),
  //               latitude: double.parse(Config.geoFences[i]["lat"]),
  //               notifyOnDwell: true,
  //               notifyOnEntry: true,
  //               notifyOnExit: true,
  //               longitude: double.parse(Config.geoFences[i]["lng"])),
  //         ).then((value) {});
  //       }
  //     });
  //   });
  // }

  ////
  // Event handlers
  //

  //Testing

  StreamSubscription<Position> positionStream;
  getLocation() async {
    var geolocator = GeolocatorPlatform.instance;
    geolocator.checkPermission().then((value) {
      print(value);
    });

    if (true) {
      // var locationOptions = LocationOptions(accuracy: LocationAccuracy.high);

      Config.positionStream = geolocator
          .getPositionStream(desiredAccuracy: LocationAccuracy.high)
          .listen((Position position) {
        if (position != null) {
          saveLocation(
              position.latitude.toString(), position.longitude.toString());
        }
      });
    } else {
      // location permission is not granted
      // user might have denied, but it's also possible that location service is not enabled, restricted, and user never saw the permission request dialog. Check the result.error.type for details.
    }
  }

  saveLocation(lat, lng) async {
    Config.lat = lat.toString();
    Config.lng = lng.toString();
    // print(lat);
    // print(lng);
    this.auth.saveMyLocation(lat, lng);
    if (internet) {
      // print("location");
      this.empSrv.updateLocation(this.userId, lat, lng).then((value) {
        // print(value);
      }).catchError((e) {
        // print(e);
      });
    }
  }

  int currentPage = 0;
  Widget getPage() {
    switch (currentPage) {
      case 0:
        return HomeScreen();
        break;
      case 1:
        return GMapScreen();
        break;
      case 2:
        return SettingScreen(
          isHod: widget.isHod,
        );
        break;
    }
  }

  Widget getEmpPage() {
    switch (currentPage) {
      case 0:
        return ProfileScreen(
          isMain: true,
        );
        break;
      case 1:
        return GMapScreen();
        break;
      case 2:
        return SettingScreen(
          isHod: widget.isHod,
        );
        break;
    }
  }

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  Widget buildBody() {
    return ListView.builder(
      controller: scrollController,
      itemCount: 30,
      itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      elevation: 0.0,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.easeIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.verified_user, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () {
            if (macIsVerified) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegisterFaceScreen(
                          checkIn: true,
                          isWifi: this.isWifi,
                        )),
              ).then((value) {
                // this.getLog();
              });
            } else {
              _showAlert("Your connected network is not verified");
            }
          },
          label: 'CHECK WITH FACE',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          // labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.person_pin_circle, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            // setupGeoFences();
          },
          label: 'CHECK WITH GEOFENCE',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          // labelBackgroundColor: Colors.green,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.isHod);
    return Scaffold(
      // floatingActionButton: buildSpeedDial(),
      body: widget.isHod ? getPage() : getEmpPage(),
      bottomNavigationBar: FancyBottomBar(
        elevation: 0.0,
        onItemSelected: (index) => setState(() {
          currentPage = index;
        }),
        selectedPosition: currentPage,
        items: widget.isHod ? hodTabs : noHodTabs,
      ),
      // bottomNavigationBar: FancyBottomNavigation(
      //   circleColor: Color(0xFF444152),
      //   inactiveIconColor: Color(0xFF444152),
      //   tabs: widget.isHod ? hodTabs : noHodTabs,
      //   onTabChangedListener: (position) {
      //     setState(() {
      //       currentPage = position;
      //     });
      //   },
      // ),
    );
  }
}
