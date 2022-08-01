import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ios_network_info/ios_network_info.dart';
import 'package:logsnx/screens/decisionMaker.dart';
import 'package:logsnx/screens/faceDetection/saveFace.dart';
import 'package:logsnx/screens/profile.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var empSrv = new EmployeeService();
  var auth = new Auth();
  var hodId;
  var userId;
  var companyId;
  List<dynamic> emps = [];
  var date = DateTime.now();
  String today;
  bool loading = true;
  var macIsVerified = false;
  var macs = [];
  bool isWifi;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      this.today = "${date.toLocal()}".split(' ')[0];
    });
    this.auth.getCompanyId().then((c) {
      this.auth.getUserId().then((e) {
        this.userId = e;
        this.companyId = c;
        setState(() {});
        this.getLog();
        // this.getAllMacs();
      });
    });
  }

  getAllMacs() {
    // EmployeeService().isVerified(userId).then((en) {
    //   print(en);
    //   if (en["wifiLogin"] == false) {
    //     this.isWifi = true;
    //     // EmployeeService().getMacs(companyId).then((value) {
    //     //   setState(() {
    //     //     this.macs = value;
    //     //   });
    //     //   // print(value);
    //     //   checkConnectivity();
    //     // });
    //   } else {
    //     setState(() {
    //       this.isWifi = false;
    //       macIsVerified = true;
    //     });
    //   }
    //   print(isWifi.toString());
    // });
    // print("yo");
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

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2000, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != date)
      setState(() {
        date = picked;
      });
    if (picked != null) {
      getLog();
    }
  }

  getLog() {
    setState(() {
      loading = true;
    });
    this
        .empSrv
        .getLog(this.userId.toString(), this.companyId.toString(),
            this.date.toString())
        .then((a) {
      print(a);
      Auth().getRole().then((value) {
        if (value == "Employee" || value == "Student") {
          this.emps = [];
          for (var item in a) {
            print(item);
            print(userId);
            if (item["user"]["_id"] == userId) {
              this.emps.add(item);
            }
          }
        } else {
          this.emps = a;
        }
      });
      setState(() {
        loading = false;
      });
    });
  }

  _generateCard(i) {
    var t = this.emps[i]["ioTime"];
    var date = DateTime.parse(t);
    print(date);
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => ProfileScreen(
        //           id: int.parse(this.emps[i]["user"]["EmployeeId"]))),
        // );
      },
      child: Card(
          elevation: 0.0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
                  width: 65,
                  child: emps[i]["user"] != null
                      ? (emps[i]["user"]["gender"] == "Female"
                          ? Image.asset("assets/girl.png")
                          : Image.asset("assets/boy.png"))
                      : (emps[i]["uD"]["gender"] == "Female"
                          ? Image.asset("assets/girl.png")
                          : Image.asset("assets/boy.png")),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width - 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        (this.emps[i]['user'] != null
                                ? this.emps[i]['user']["username"]
                                : this.emps[i]['uD']["displayName"]) +
                            ", Checked " +
                            (emps[i]["ioMode"] == "IN" ? "In" : "Out"),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(this.emps[i]["project"] == null
                          ? (this.emps[i]["verifyMode"] +
                              ", " +
                              this.emps[i]["deviceId"])
                          : this.emps[i]["project"])
                    ],
                  ),
                ),
                Spacer(),
                Container(
                    margin: EdgeInsets.only(right: 15),
                    child: Text(DateFormat('kk:mm').format(date),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfd27eb))))
              ],
            ),
          )),
    );
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Container(
              margin: EdgeInsets.only(left: 10),
              width: 50,
              child:
                  Hero(tag: "logo", child: Image.asset("assets/logxnx1.png"))),
          // leading: FlatButton(
          //   child: Image.asset("assets/checkin.png"),
          //   onPressed: () {
          //     if (macIsVerified) {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => RegisterFaceScreen(
          //                   checkIn: true,
          //                   isWifi: this.isWifi,
          //                 )),
          //       ).then((value) {
          //         this.getLog();
          //       });
          //     } else {
          //       _showAlert("Your connected network is not verified");
          //     }
          //   },
          // ),
          // backgroundColor: Colors.white,
          // title: Text(
          //   "LogsNX",
          //   style: TextStyle(fontSize: 25),
          // ),
          title: FlatButton(
            child: Text(
                (today == "${date.toLocal()}".split(' ')[0])
                    ? "Today"
                    : (DateFormat.yMMMd().format(date)),
                style: TextStyle(fontSize: 20)),
            onPressed: () {
              _selectDate(context);
            },
          ),
          centerTitle: true,
          elevation: 0.0,
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Auth().setActiveType("NONE");
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 1000),
                      pageBuilder: (_, __, ___) => DecisionMakerScreen()),
                );
              },
              child: Container(
                  margin: EdgeInsets.only(left: 5),
                  width: 30,
                  child: Hero(
                      tag: "worktype",
                      child: Image.asset("assets/suitcase.png"))),
            )
          ],
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF444152)),
              ))
            : Container(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    child: emps.length == 0
                        ? Container(
                            margin: EdgeInsets.only(top: 100),
                            child: Center(
                              child: Text(
                                "No Logs Found",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(emps.length, (i) {
                              return _generateCard(i);
                            }),
                          ))));
  }
}
