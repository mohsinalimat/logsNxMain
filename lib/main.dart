import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logsnx/providers/notifications.dart';
import 'package:logsnx/screens/decisionMaker.dart';
import 'package:logsnx/screens/login.dart';
import 'package:logsnx/screens/school/logs.dart';
import 'package:logsnx/screens/school/students.dart';
import 'package:logsnx/screens/tabs.dart';
import 'package:logsnx/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  PushNotificationsManager fn = new PushNotificationsManager();

  @override
  Widget build(BuildContext context) {
    fn.init();
    return MaterialApp(
      title: 'LogsNX',
      theme: ThemeData(
          primarySwatch: Colors.grey,
          fontFamily: "lato",
          accentColor: Color(0xFF444152),
          primaryColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: Redirector(),
    );
  }
}

class Redirector extends StatefulWidget {
  @override
  _RedirectorState createState() => _RedirectorState();
}

class _RedirectorState extends State<Redirector> {
  var auth = new Auth();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.auth.isLoggedIn().then((a) {
      if (a) {
        // this.auth.isHod().then((e) {
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
        Auth().getActiveType().then((at) {
          print(at);
          if (at == "WORK") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => TabsScreen(
                        isHod: true,
                      )),
            );
          } else if (at == "SCHOOL") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentLogScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DecisionMakerScreen()),
            );
          }
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen(
                    backgroundColor1: Color(0xFF444152),
                    backgroundColor2: Color(0xFF6f6c7d),
                    highlightColor: Color(0xfff9b428),
                    foregroundColor: Colors.white,
                    logo: new AssetImage("assets/images/full-bloom.png"),
                  )),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
