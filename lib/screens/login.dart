import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logsnx/screens/camera.dart';
import 'package:logsnx/screens/decisionMaker.dart';
import 'package:logsnx/screens/home.dart';
import 'package:logsnx/screens/tabs.dart';
import 'package:logsnx/services/auth.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  final Color backgroundColor1;
  final Color backgroundColor2;
  final Color highlightColor;
  final Color foregroundColor;
  final AssetImage logo;
  LoginScreen(
      {Key k,
      this.backgroundColor1,
      this.backgroundColor2,
      this.highlightColor,
      this.foregroundColor,
      this.logo});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var email = TextEditingController();
  var password = TextEditingController();
  var auth = new Auth();
  var loading = false;
  FirebaseMessaging fcm = FirebaseMessaging();
  _showAlert(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        decoration: new BoxDecoration(
          color: widget.backgroundColor1
          // gradient: new LinearGradient(
          //   begin: Alignment.centerLeft,
          //   end: new Alignment(
          //       1.0, 0.0), // 10% of the width, so there are ten blinds.
          //   colors: [
          //     widget.backgroundColor1,
          //     widget.backgroundColor2
          //   ], // whitish to gray
          //   // tileMode: TileMode.repeated, // repeats the gradient over the canvas
          // ),
        ),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 150.0, bottom: 100.0),
              child: Center(
                child: new Column(
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: Hero(
                        tag: "logo",
                        child: Image(
                          image: AssetImage("assets/logxnx1.png"),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: widget.foregroundColor,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.only(top: 10.0, bottom: 10.0, right: 00.0),
                    child: Icon(
                      Icons.alternate_email,
                      color: widget.foregroundColor,
                    ),
                  ),
                  new Expanded(
                    child: TextField(
                      controller: email,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        border: InputBorder.none,
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: widget.foregroundColor,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.only(top: 10.0, bottom: 10.0, right: 00.0),
                    child: Icon(
                      Icons.lock_open,
                      color: widget.foregroundColor,
                    ),
                  ),
                  new Expanded(
                    child: TextField(
                      controller: password,
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        border: InputBorder.none,
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0),
              alignment: Alignment.center,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  !loading
                      ? Expanded(
                          child: FlatButton(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          color: widget.highlightColor,
                          onPressed: () async {
                            if (email.text == '' && password.text == '') {
                              this._showAlert("Fill all fields");
                            } else {
                              loading = true;
                              setState(() {});
                              var token = await this.fcm.getToken();
                              var deviceType =
                                  Platform.isAndroid ? "Android" : "IOS";
                              this.auth.login({
                                "email": email.text,
                                "password": password.text,
                                "fcmToken": token,
                                "deviceType": deviceType
                              }).then((d) {
                                loading = false;
                                setState(() {});
                                if (d['result'] == "success") {
                                  var a = d["user"];
                                  print(a);
                                  this
                                      .auth
                                      .setLogin(
                                          json.encode(a).toString(),
                                          token,)
                                      .then((r) {
                                    if (a["latitude"] != null) {
                                      this.auth.saveMyLocation(
                                          a["latitude"], a["longitude"]);
                                    }
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                          transitionDuration:
                                              Duration(milliseconds: 1000),
                                          pageBuilder: (_, __, ___) =>
                                              DecisionMakerScreen()),
                                    );
                                  });
                                } else {
                                  this._showAlert("Invalid credentials");
                                }
                              });
                            }
                          },
                          child: Text(
                            "Log In",
                            style: TextStyle(color: widget.foregroundColor),
                          ),
                        ))
                      : CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFF9B622)),
                        ),
                ],
              ),
            ),
            // new Container(
            //   width: MediaQuery.of(context).size.width,
            //   margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
            //   alignment: Alignment.center,
            //   child: new Row(
            //     children: <Widget>[
            //       new Expanded(
            //         child: new FlatButton(
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 20.0, horizontal: 20.0),
            //           color: Colors.transparent,
            //           onPressed: () {
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => CameraScreen()),
            //             );
            //           },
            //           child: Text(
            //             "Forgot your password?",
            //             style: TextStyle(
            //                 color: this.foregroundColor.withOpacity(0.5)),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // new Expanded(
            //   child: Divider(),
            // ),
            // new Container(
            //   width: MediaQuery.of(context).size.width,
            //   margin: const EdgeInsets.only(
            //       left: 40.0, right: 40.0, top: 10.0, bottom: 20.0),
            //   alignment: Alignment.center,
            //   child: new Row(
            //     children: <Widget>[
            //       new Expanded(
            //         child: new FlatButton(
            //           padding: const EdgeInsets.symmetric(
            //               vertical: 20.0, horizontal: 20.0),
            //           color: Colors.transparent,
            //           onPressed: () => {},
            //           child: Text(
            //             "Don't have an account? Create One",
            //             style: TextStyle(
            //                 color: this.foregroundColor.withOpacity(0.5)),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    ));
  }
}
