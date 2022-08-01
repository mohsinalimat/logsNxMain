import 'package:flutter/material.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';

class MachineScreen extends StatefulWidget {
  @override
  _MachineScreenState createState() => _MachineScreenState();
}

class _MachineScreenState extends State<MachineScreen> {
  var empSrv = new EmployeeService();
  var auth = new Auth();
  var hodId;
  var companyId;
  List<dynamic> mach = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.auth.getCompanyId().then((c) {
      companyId = c;
      this.empSrv.getMachines(c).then((a) {
        this.mach = a;
        setState(() {});
      });
    });
  }

  _generateCard(i) {
    return InkWell(
      onTap: () {},
      child: Card(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              width: 30,
              height: 30,
              margin: EdgeInsets.only(right: 20, left: 10),
              decoration: BoxDecoration(
                  color: this.mach[i]["connected"] == true
                      ? Colors.green
                      : Colors.red,
                  borderRadius: BorderRadius.circular(100)),
              child: null,
            ),
            Container(
              padding: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width - 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    this.mach[i]["preferedName"],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(this.mach[i]["cloudId"] +
                      "(" +
                      this.mach[i]["preferedName"] +
                      ")")
                ],
              ),
            ),
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
        title: Text("Machines"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: List.generate(this.mach.length, (i) {
          return _generateCard(i);
        }),
      )),
    );
  }
}
