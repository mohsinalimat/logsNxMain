import 'package:flutter/material.dart';
import 'package:logsnx/screens/createSlot.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';

class NotificationSlots extends StatefulWidget {
  @override
  _NotificationSlotsState createState() => _NotificationSlotsState();
}

class _NotificationSlotsState extends State<NotificationSlots> {
  List<dynamic> slots = [];
  var empSrv = new EmployeeService();
  var auth = new Auth();
  var userId;
  var cId;
  bool loading = false;
  @override
  initState() {
    super.initState();
    this.getSlots();
  }

  getSlots() {
    setState(() {
      this.loading = true;
    });
    Auth().getUserId().then((u) {
      userId = u;
      Auth().getCompanyId().then((c) {
        cId = c;
        EmployeeService().getSlots(userId, cId).then((s) {
          setState(() {
            this.slots = s;
            this.loading = false;
          });
        });
      });
    });
  }

  String _generateTime(String time) {
    var ta = time.split(":");
    TimeOfDay td =
        new TimeOfDay(hour: int.parse(ta[0]), minute: int.parse(ta[1]));
    return td.format(context);
  }

  Widget _generateList() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(slots.length, (i) {
        return Card(
            child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: Color(0xFF444152),
                    borderRadius: BorderRadius.circular(100)),
                child: Center(
                  child: Text(
                    (i + 1).toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _generateTime(slots[i]['startTime']) +
                          " - " +
                          _generateTime(slots[i]['endTime']),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(slots[i]["users"].length.toString() +
                        " Employees Added")
                  ],
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit),
                color: Color(0xFF444152),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateSlot(
                              type: "edit",
                              slot: slots[i],
                            )),
                  ).then((a) {
                    getSlots();
                  });
                },
              )
            ],
          ),
        ));
      }),
    ));
    // return ;
  }

  _generateLoader() {
    return Center(
        child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF444152)),
    ));
  }

  _generateEmpty() {
    return Center(child: Text("No Slots Created"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          title: Text("Notification Slots"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateSlot(
                            type: "create",
                          )),
                ).then((a) {
                  getSlots();
                });
              },
            )
          ],
        ),
        body: Container(
            child: loading
                ? _generateLoader()
                : (slots.length == 0 ? _generateEmpty() : _generateList())));
  }
}
