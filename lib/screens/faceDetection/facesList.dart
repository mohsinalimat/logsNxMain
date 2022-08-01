import 'package:flutter/material.dart';
import 'package:logsnx/screens/faceDetection/saveFace.dart';
import 'package:logsnx/screens/faceDetection/saveFaceLive.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';

class FacesListScreen extends StatefulWidget {
  @override
  _FacesListScreenState createState() => _FacesListScreenState();
}

class _FacesListScreenState extends State<FacesListScreen> {
  var hrId;
  var companyId;
  var userId;
  var face;
  var loaded = false;
  getFaces() {
    print("h");
    EmployeeService().getMyFace(userId, companyId).then((value) {
      print(value);
      setState(() {
        loaded = true;
        if (value == false) {
          // face = null;
        } else {
          face = value;
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print("H");
    Auth().getUserId().then((u) {
      userId = u;
      Auth().getCompanyId().then((c) {
        companyId = c;
        this.getFaces();
      });
    });
    // Auth().getCompany().then((c) {
    //   Auth().getEmployee().then((e) {
    //     this.hrId = e['HrId'];
    //     this.companyId = c['companyid'];
    //     this.getFaces();
    //   });
    // });
  }

  Widget floating() {
    if (loaded && face == null) {
      return FloatingActionButton(
        backgroundColor: Color(0xFF444152),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RegisterFaceScreen(
                      checkIn: false,
                    )),
          ).then((value) {
            getFaces();
          });
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => SaveFaceLive()),
          // ).then((value) {
          //   getFaces();
          // });
        },
      );
    } else {
      return null;
    }
  }

  Widget isfaceIsthere() {
    if (loaded || face != null) {
      return Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
            width: 200,
            child: face == null
                ? Container()
                : Image.network("https://logsnx.s3.eu-west-2.amazonaws.com/" +
                    face["image"]),
          ),
          Container(
              width: 100,
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              color: face == null
                  ? Colors.transparent
                  : (face["accepted"] == false ? Colors.orange : Colors.green),
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: face == null
                  ? Container()
                  : Center(
                      child: face["accepted"] == false
                          ? Text("Pending",
                              style: TextStyle(color: Colors.white))
                          : Text("Approved",
                              style: TextStyle(color: Colors.white))))
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          title: Text("My Face"),
        ),
        floatingActionButton: floating(),
        body: Container(
            width: MediaQuery.of(context).size.width, child: isfaceIsthere()));
  }
}
