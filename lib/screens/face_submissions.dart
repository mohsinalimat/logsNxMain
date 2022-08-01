import 'package:flutter/material.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';

class FaceSubmissions extends StatefulWidget {
  @override
  _FaceSubmissionsState createState() => _FaceSubmissionsState();
}

class _FaceSubmissionsState extends State<FaceSubmissions> {
  List pending = [];
  var loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth().getCompanyId().then((cid) {
      EmployeeService().getAllPendingFaces(cid).then((pen) {
        print(pen);
        setState(() {
          this.pending = pen;
        });
      });
    });
  }

  decisionFace(id, accepted) {
    setState(() {
      this.loading = true;
    });
    print(id);
    print(accepted);
    EmployeeService().faceDecision(id, accepted).then((value) {
      loading = false;
      pending.removeRange(0, 1);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Face Submissions"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text(
              pending.length.toString(),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: pending.length > 0
              ? Column(
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height - 240,
                              // width: 250,
                              margin: EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  "https://logsnx.s3.eu-west-2.amazonaws.com/" +
                                      pending[0]["image"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              // margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      child: Text(
                                    pending[0]["user"]['username'],
                                    style: TextStyle(fontSize: 18),
                                  )),
                                  // Text(pending[0]["user"]["userDetails"]["hrId"])
                                ],
                              ),
                            )
                          ],
                        )),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlineButton(
                            borderSide: BorderSide(color: Colors.green, width: 2),
                            shape: StadiumBorder(),
                            onPressed: loading
                                ? null
                                : () {
                                    decisionFace(pending[0]["_id"], 1);
                                  },
                            child: Text(
                              "Accept",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          OutlineButton(
                            borderSide: BorderSide(color: Colors.red, width: 2),
                            shape: StadiumBorder(),
                            onPressed: loading
                                ? null
                                : () {
                                    decisionFace(pending[0]["_id"], 2);
                                  },
                            child: Text(
                              "Reject",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : Center(
                  child: Text("No Faces Pending"),
                ),
        ),
      ),
    );
  }
}
