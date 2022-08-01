import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ios_network_info/ios_network_info.dart';
import 'package:latlong/latlong.dart';
import 'package:logsnx/screens/faceDetection/saveFace.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';

class ProfileScreen extends StatefulWidget {
  String id;
  bool isMain;
  ProfileScreen({this.id, this.isMain = false});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var empSrv = new EmployeeService();
  var auth = new Auth();
  var hodId;
  var userId;
  var companyId;
  List<dynamic> emps = [];
  var employee;
  var designation;
  var lat = 0.0;
  var lng = 0.0;
  bool loading = false;
  var macIsVerified = false;
  var macs = [];
  bool isWifi;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.auth.getCompanyId().then((c) {
      this.auth.getUserId().then((e) {
        this.userId = e;
        this.companyId = c;
        if (widget.isMain) {
          getAllMacs();
        }
        String id;
        if (widget.id == null) {
          getLocation();
          id = e;
        } else {
          id = widget.id;
        }
        setState(() {
          loading = true;
        });
        this.empSrv.getEmployeeDetails(id.toString()).then((a) {
          print(a);
          this.emps = a['log'];
          this.employee = a['user'];
          if (widget.id != null) {
            if (this.employee["latitude"] != null) {
              this.lat = double.parse(this.employee["latitude"]);
              this.lng = double.parse(this.employee["longitude"]);
            }
          }
          this.designation = employee["userDetails"]['designation'];
          this.loading = false;
          setState(() {});
        });
      });
    });
  }

  getLocation() async {
    var loc = await this.auth.getLocation();
    print(loc);
    if (loc[0] != null) {
      setState(() {
        this.lat = double.parse(loc[0]);
        this.lng = double.parse(loc[1]);
      });
    }
  }

  _createDetailCard(title, value) {
    return Container(
      width: (MediaQuery.of(context).size.width * 0.5) - 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(value == null ? "" : value)
        ],
      ),
    );
  }

  _generateCard(i) {
    var t = this.emps[i]["ioTime"];
    var date = DateTime.parse(t);
    return Card(
        child: Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Checked " + (emps[i]["ioMode"] == "IN" ? "In" : "Out"),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
              margin: EdgeInsets.only(right: 15),
              child: Text(DateFormat.yMd().add_jm().format(date),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFFfd27eb))))
        ],
      ),
    ));
  }

  getAllMacs() {
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
    String wifiName = await Connectivity().getWifiName();
    // _showAlert(
    //     "Mac: " + wifiBSSID.toString() + " Name: " + wifiName.toString());
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

  _showAlert(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            widget.isMain
                ? FlatButton(
                    child: Container(
                        width: 30, child: Image.asset("assets/checkin.png")),
                    onPressed: () {
                      if (macIsVerified) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterFaceScreen(
                                    checkIn: true,
                                    isWifi: this.isWifi,
                                  )),
                        );
                      } else {
                        _showAlert("Your connected network is not verified");
                      }
                    },
                  )
                : Container()
          ],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              employee == null
                  ? Container()
                  : employee["userDetails"]["gender"] == "Male"
                      ? Image.asset(
                          "assets/boy.png",
                        )
                      : Image.asset(
                          "assets/girl.png",
                        ),
              Text(employee != null
                  ? (" " + employee["userDetails"]['firstName'] + " " + employee["userDetails"]['lastName'])
                  : "Loading Profile ...")
            ],
          ),
          centerTitle: false,
        ),
        body: this.employee == null
            ? Container()
            : Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                        child: Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _createDetailCard("HrId", employee["userDetails"]["hrId"]),
                                _createDetailCard("Date Of Joining",
                                    "Not Added"),
                              ],
                            )),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _createDetailCard(
                                    "Address", ""),
                                _createDetailCard("Designation",
                                    designation["name"]),
                              ],
                            ))
                      ],
                    )),
                  ),
                  DefaultTabController(
                      length: 2,
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Color(0xFF444152),
                            child: TabBar(
                              indicatorColor: Colors.white,
                              tabs: [
                                Tab(icon: Icon(Icons.list)),
                                Tab(icon: Icon(Icons.map)),
                              ],
                            ),
                          ),
                          Container(
                            height: widget.isMain
                                ? MediaQuery.of(context).size.height - 324
                                : MediaQuery.of(context).size.height - 264,
                            child: TabBarView(
                              children: [
                                Container(
                                    child: SingleChildScrollView(
                                  child: Column(
                                    children:
                                        List.generate(this.emps.length, (i) {
                                      return _generateCard(i);
                                    }),
                                  ),
                                )),
                                employee == null
                                    ? Container()
                                    : Container(
                                        child: (lat == 0.0 || lat == null)
                                            ? Center(
                                                child: Text(
                                                    "Location Not Added Yet"))
                                            : FlutterMap(
                                                options: new MapOptions(
                                                  center: LatLng(lat, lng),
                                                  zoom: 15.0,
                                                ),
                                                layers: [
                                                  new TileLayerOptions(
                                                    urlTemplate:
                                                        "https://api.tiles.mapbox.com/v4/"
                                                        "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
                                                    additionalOptions: {
                                                      'accessToken':
                                                          'pk.eyJ1IjoiYWJ1emFyMjQwNyIsImEiOiJjazl5a2xiZnAwcWcyM25vOGZ4MGR3eDU0In0.OwJfG7Xk4X9g_Sxt_zSObw',
                                                      'id': 'mapbox.streets',
                                                    },
                                                  ),
                                                  new MarkerLayerOptions(
                                                      markers: [
                                                        Marker(
                                                          width: 30.0,
                                                          height: 30.0,
                                                          point: LatLng(
                                                              this.lat,
                                                              this.lng),
                                                          builder: (ctx) =>
                                                              InkWell(
                                                            onTap: () {
                                                              print(employee[
                                                                  'latitude']);
                                                            },
                                                            child: Container(
                                                              child: Image.asset(
                                                                  "assets/boy.png"),
                                                            ),
                                                          ),
                                                        )
                                                      ]),
                                                ],
                                              ))
                              ],
                            ),
                          )
                        ],
                      ))
                ],
              ));
  }
}
