import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_network_info/ios_network_info.dart';
import 'package:logsnx/main.dart';
import 'package:logsnx/screens/faceDetection/facesList.dart';
import 'package:logsnx/screens/faceDetection/saveFace.dart';
import 'package:logsnx/screens/face_submissions.dart';
import 'package:logsnx/screens/geofence.dart';
import 'package:logsnx/screens/login.dart';
import 'package:logsnx/screens/machines.dart';
import 'package:logsnx/screens/newProfile.dart';
import 'package:logsnx/screens/notification_slots.dart';
import 'package:logsnx/screens/profile.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/config.dart';
import 'package:logsnx/services/employee.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingScreen extends StatefulWidget {
  bool isHod;
  SettingScreen({this.isHod});
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  var auth = new Auth();
  bool notNull(Object o) => o != null;
  var isExec = false;
  var mac_address = "";
  var wifiName = "";
  var companyId;
  var role = "";
  var comapnies = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isIOS) {
      try {
        IosNetworkInfo.bssid.then((value) {
          if (value != null) {
            setState(() {
              this.mac_address = value.toLowerCase();
            });
          }
        });
      } on PlatformException {
        setState(() {
          this.mac_address = "Not Found";
        });
      }
    } else {
      Connectivity().getWifiBSSID().then((value) {
        if (value != null) {
          setState(() {
            this.mac_address = value.toLowerCase();
          });
        }
      });
    }

    Connectivity().getWifiName().then((value) {
      if (value != null) {
        setState(() {
          this.wifiName = value;
        });
      }
    });
    // Auth().isExec().then((value) {
    //   setState(() {
    //     this.isExec = true;
    //   });
    //   print(this.isExec);
    // });
    getAllCompanies();
  }

  getAllCompanies() {
    Auth().getRole().then((role) {
      this.role = role;
      setState(() {});
    });
    Auth().getCompanyId().then((c) {
      print(c);
      this.companyId = c;
      Auth().getCompanies().then((value) {
        print(value);
        setState(() {
          this.comapnies = value;
        });
      });
    });
  }

  company(index) {
    print(comapnies[index]["companyId"]["_id"]);
    print(companyId);
    return Container(
      width: 200,
      // height: 107,
      child: Card(
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/suitcase.png"),
                  ),
                  // child: ,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 112,
                      child: Text(comapnies[index]["companyId"]["name"],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      comapnies[index]["roleId"]["name"],
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                )
              ],
            ),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(top: 6),
              // child:  ,
              child: comapnies[index]["companyId"]["_id"] == companyId
                  ? Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Colors.green,
                    )
                  : InkWell(
                      onTap: () {
                        print(comapnies[index]);
                        Auth().setActiveCompanyId(
                            comapnies[index]["companyId"]["_id"]);
                        Auth().setUserDetailsId(comapnies[index]["_id"]);
                        Auth().setRole(comapnies[index]["companyId"]["_id"]);
                        Auth().setDepartment(comapnies[index]["department"]);

                        getAllCompanies();
                        this.companyId = comapnies[index]["companyId"]["_id"];
                        setState(() {});
                      },
                      child: Container(
                          padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
                          child: Text("Activate")),
                    ),
            )
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        // backgroundColor: Color(0xFF444152),
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 18),
                    child: Text(
                      "Available Companies:",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Container(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(comapnies.length, (index) {
                          return company(index);
                        }),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 500,
              child: SettingsList(
                physics: NeverScrollableScrollPhysics(),
                backgroundColor: Colors.white,
                sections: [
                  SettingsSection(
                    tiles: [
                      role != "Employee"
                          ? SettingsTile(
                              title: 'Notification Slots',
                              leading: Icon(Icons.list),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NotificationSlots()),
                                );
                              },
                            )
                          : null,
                      SettingsTile(
                        title: 'Machines',
                        leading: Icon(Icons.devices),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MachineScreen()),
                          );
                        },
                      ),
                      // SettingsTile(
                      //   title: 'Geo Fencing Setup',
                      //   leading: Icon(Icons.photo_camera),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => GeoFenceScreen()),
                      //     );
                      //   },
                      // ),
                      SettingsTile(
                        title: 'My Face',
                        leading: Icon(Icons.photo_camera),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FacesListScreen()),
                          );
                        },
                      ),
                      role != "Employee" && role != "HOD"
                          ? SettingsTile(
                              title: 'Face Submissions',
                              leading: Icon(Icons.filter_list),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FaceSubmissions()),
                                );
                              },
                            )
                          : null,
                      // SettingsTile(
                      //   title: 'Coming Soon',
                      //   leading: Icon(Icons.more),
                      //   onTap: () {},
                      // ),
                    ].where(notNull).toList(),
                  ),
                  SettingsSection(
                    title: 'Profile',
                    tiles: [
                      SettingsTile(
                        title: 'Profile',
                        // subtitle: 'Edit',
                        leading: Icon(Icons.person),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewProfileScreen()),
                          );
                        },
                      ),
                      SettingsTile(
                        title: 'Logout',
                        leading: Icon(Icons.exit_to_app),
                        onTap: () {
                          showAlertDialog(context);

                          // Auth().getEmployee().then((value) {

                          // });
                        },
                      ),
                      // SettingsTile(
                      //     title: Platform.isIOS ? "" : "Connected Router",
                      //     subtitle: mac_address + " " + wifiName,
                      //     leading: Icon(Icons.info_outline),
                      //     onTap: null),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {
        Auth().getUserId().then((value) {
          Auth().myFcmToken().then((token) {
            EmployeeService().logout(value, token).then((b) {
              // Config.positionStream.cancel();
              this.auth.logout().then((a) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Redirector()),
                );
              });
            });
          });
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirm"),
      content: Text("You really want to logout?"),
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
