import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logsnx/screens/school/logs.dart';
import 'package:logsnx/screens/tabs.dart';
import 'package:logsnx/services/auth.dart';

class DecisionMakerScreen extends StatefulWidget {
  @override
  _DecisionMakerScreenState createState() => _DecisionMakerScreenState();
}

class _DecisionMakerScreenState extends State<DecisionMakerScreen> {
  var companies = [];
  var loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth().getUserId().then((value) {
      Auth().companies(value).then((c) {
        this.companies = c;
        setState(() {
          this.loading = false;
        });
        Auth().setCompanies(json.encode(c).toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ClipPath(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.2,
              color: Color(0xFF444152),
            ),
            clipper: CustomClipPath(),
          ),
          Container(
            alignment: Alignment.topCenter,
            height: MediaQuery.of(context).size.height / 2.2,
            child: Container(
              width: MediaQuery.of(context).size.width - 140,
              // height: 150,
              child: Image.asset("assets/blubs.png"),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            height: MediaQuery.of(context).size.height / 2.15,
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: Color(0xFF444152),
                  border: Border.all(color: Color(0xFFF9B622), width: 4),
                  borderRadius: BorderRadius.circular(100)),
              width: 150,
              height: 150,
              child:
                  Hero(tag: "logo", child: Image.asset("assets/logxnx1.png")),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 25),
                    child: Text(
                      "CHOOSE YOUR PATH",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  loading
                      ? Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          color: Colors.orange,
                          child: Text(
                            "WAIT",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          color: Colors.green,
                          child: Text(
                            "READY",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      selectionBox("WORK", "assets/suitcase.png", 0xFFF9B622, 1,
                          "worktype"),
                      selectionBox("SCHOOL", "assets/dad.png", 0xFF444152, 2,
                          "worktype1")
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  selectionBox(text, img, color, type, tag) {
    return GestureDetector(
      onTap: () {
        if (type == 1) {
          if (companies.length > 0) {
            Auth().getCompanyId().then((value) {
              if (value == null) {
                Auth().setActiveCompanyId(companies[0]["companyId"]["_id"]);
                Auth().setUserDetailsId(companies[0]["_id"]);
                Auth().setRole(companies[0]["companyId"]["_id"]);
                Auth().setDepartment(companies[0]["department"]);
              }
              Auth().setActiveType("WORK");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TabsScreen(
                          isHod: true,
                        )),
              );
            });
          } else {
            Fluttertoast.showToast(
                msg: "Sorry, you are not part of any company");
          }
          // Auth().isHod().then((e) {
          //   if (e) {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => TabsScreen(
          //                 isHod: true,
          //               )),
          //     );
          //   } else {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => TabsScreen(
          //                 isHod: false,
          //               )),
          //     );
          //   }
          // });
        } else {
          Auth().setActiveType("SCHOOL");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentLogScreen()),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 15, 15, 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                width: 150,
                decoration: BoxDecoration(
                    color: Color(color),
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.all(40),
                child: Hero(tag: tag, child: Image.asset(img))),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  var radius = 10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
