import 'package:flutter/material.dart';
import 'package:logsnx/screens/decisionMaker.dart';
import 'package:logsnx/screens/school/menu.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/guardian.dart';

class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  var userId;
  List students = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth().getUserId().then((id) {
      userId = id;
      GuardianSrv().getStudents(id).then((d) {
        print(d);
        setState(() {
          students = d;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Students"),
        centerTitle: true,
        elevation: 0.0,
        actions: [
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
                    tag: "worktype1", child: Image.asset("assets/dad.png"))),
          )
        ],
      ),
      drawer: NavDrawer(),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
              children: List.generate(
                  students.length, (index) => _generateCard(index))),
        ),
      ),
    );
  }

  _generateCard(i) {
    print(students[i]);
    // var t = this.emps[i]["ioTime"];
    // var date = DateTime.parse(t);
    // print(date);
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
                  child: students[i]["uId"]["gender"] == "Female"
                      ? Image.asset("assets/girl.png")
                      : Image.asset("assets/boy.png"),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width - 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        students[i]["uId"]["username"],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(students[i]["companyId"]["name"])
                    ],
                  ),
                ),
                Spacer(),
                Container(margin: EdgeInsets.only(right: 15), child: Text(""))
              ],
            ),
          )),
    );
  }
}
