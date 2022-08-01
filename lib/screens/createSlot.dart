import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';

class CreateSlot extends StatefulWidget {
  var slot;
  var type;
  CreateSlot({this.slot, @required this.type});
  @override
  _CreateSlotState createState() => _CreateSlotState();
}

class _CreateSlotState extends State<CreateSlot> {
  TimeOfDay checkInStart = TimeOfDay.now();
  TimeOfDay checkInEnd = TimeOfDay.now();
  var empSrv = new EmployeeService();
  var auth = new Auth();
  var hodId;
  var companyId;
  var userId;
  List<dynamic> employess = [];
  bool allChecked = false;
  void inputTimeStart() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: checkInStart,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        checkInStart = picked;
      });
    }
  }

  void inputTimeEnd() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: checkInEnd,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        checkInEnd = picked;
      });
    }
  }

  @override
  initState() {
    super.initState();
    Auth().getUserId().then((u) {
      this.userId = u;
      Auth().getCompanyId().then((c) {
        this.companyId = c;
        Auth().getRole().then((role) async {
          var dep;
          if (role == "HOD") {
            dep = await Auth().getDepartment(); 
          }
          EmployeeService().getEmployees(userId, companyId, dep: dep).then((a) {
          print(a);
          if (widget.type == 'edit') {
            var ta = widget.slot['startTime'].split(":");
            this.checkInStart =
                new TimeOfDay(hour: int.parse(ta[0]), minute: int.parse(ta[1]));
            var te = widget.slot['endTime'].split(":");
            this.checkInEnd =
                new TimeOfDay(hour: int.parse(te[0]), minute: int.parse(te[1]));
            // print(widget.slot["users"]);
            for (var item in a) {
              var check = false;
              for (var item1 in widget.slot["users"]) {
                // print(item["uId"]["_id"]);
                // print(item1['user']);
                // print("-------");
                if (item["uId"] != null) {
                  if (item["uId"]["_id"] == item1['user']) {
                    check = true;
                    break;
                  }
                } else {
                  if (item["_id"] == item1['uD']) {
                    check = true;
                    break;
                  }
                }
              }
              if (item["uId"] != null) {
                employess.add({
                  "name": item["displayName"] == null
                      ? item["uId"]["username"]
                      : item["displayName"],
                  "id": item["uId"]["_id"],
                  "uD": item["_id"],
                  "hrId": item["hrId"],
                  "gender": item["gender"],
                  "checked": check
                });
              } else {
                employess.add({
                  "name": item["displayName"],
                  "id": null,
                  "uD": item["_id"],
                  "hrId": item["hrId"],
                  "gender": item["gender"],
                  "checked": check
                });
              }
            }
            this.isAllSelected();
          } else {
            for (var item in a) {
              print(item["gender"]);
              if (item["uId"] != null) {
                employess.add({
                  "name": item["displayName"] == null
                      ? item["uId"]["username"]
                      : item["displayName"],
                  "id": item["uId"]["_id"],
                  "uD": item["_id"],
                  "hrId": item["hrId"],
                  "gender": item["gender"],
                  "checked": false
                });
              } else {
                employess.add({
                  "name": item["displayName"],
                  "id": null,
                  "uD": item["_id"],
                  "hrId": item["hrId"],
                  "gender": item["gender"],
                  "checked": false
                });
              }
            }
            print(a);
          }
          setState(() {});
        });
      
        });
      
      });
    });
  }

  isAllSelected() {
    int checked = 0;
    for (var item in this.employess) {
      if (item["checked"]) {
        checked++;
      }
    }
    if (checked == employess.length) {
      setState(() {
        allChecked = true;
      });
    } else {
      setState(() {
        allChecked = false;
      });
    }
  }

  void _doDeleteConfirmation() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm Delete ?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (value) {
        this.empSrv.deleteSlot(widget.slot['_id'].toString()).then((value) {
          Navigator.of(context).pop();
        });
      }
    });
  }

  _generateListOfEmployees(i) {
    print(employess[i]["gender"]);
    return Card(
        child: Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            width: 70,
            child: employess[i]["gender"] == "Male"
                ? Image.asset("assets/boy.png")
                : Image.asset("assets/girl.png"),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  employess[i]["name"] != null ? employess[i]["name"] : "",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(employess[i]["hrId"] != null ? employess[i]["hrId"] : "")
              ],
            ),
          ),
          Spacer(),
          Checkbox(
            value: employess[i]["checked"],
            activeColor: Color(0xFF444152),
            onChanged: (bool value) {
              setState(() {
                employess[i]["checked"] = value;
              });
              isAllSelected();
            },
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          title: Text(widget.type == "create" ? "Create Slot" : "Update Slot"),
          actions: <Widget>[
            FlatButton(
                child: Text(
                  widget.type == "create" ? "Create" : "Save",
                ),
                onPressed: () {
                  var start_time = checkInStart.hour.toString() +
                      ":" +
                      checkInStart.minute.toString();
                  var end_time = checkInEnd.hour.toString() +
                      ":" +
                      checkInEnd.minute.toString();
                  var emps = [];
                  for (var item in this.employess) {
                    if (item["checked"] == true) {
                      emps.add({"user": item["id"], "uD": item["uD"]});
                    }
                  }
                  if (widget.type == "edit") {
                    var data = {
                      "start_time": start_time,
                      "end_time": end_time,
                      "user": userId,
                      "company": companyId,
                      "employees": json.encode(emps).toString(),
                      "type": "edit",
                      "slotid": widget.slot['_id']
                    };
                    print(data);
                    this.empSrv.createSlot(data).then((a) {
                      print(a);
                      Navigator.pop(context);
                    });
                  } else {
                    this.empSrv.createSlot({
                      "start_time": start_time,
                      "end_time": end_time,
                      "user": userId,
                      "company": companyId,
                      "employees": json.encode(emps).toString(),
                      "type": "create"
                    }).then((a) {
                      print(a);
                      Navigator.pop(context);
                    });
                  }
                }),
            widget.type == "edit"
                ? IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _doDeleteConfirmation();
                    },
                  )
                : Container()
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: 165,
              child: Card(
                  child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Select Slot:",
                      textAlign: TextAlign.right,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 30,
                              child: Center(
                                  child: Text(
                                "Start Time",
                              )),
                            ),
                            Text(""),
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 30,
                              child: Center(
                                  child: Text(
                                "End Time",
                              )),
                            ),
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                inputTimeStart();
                              },
                              child: Container(
                                width: (MediaQuery.of(context).size.width / 2) -
                                    30,
                                padding: EdgeInsets.all(8),
                                decoration:
                                    BoxDecoration(color: Color(0xFF444152)),
                                child: Center(
                                    child: Text(
                                  checkInStart.format(context),
                                  style: TextStyle(color: Colors.white),
                                )),
                              ),
                            ),
                            Text("-"),
                            InkWell(
                              onTap: () {
                                inputTimeEnd();
                              },
                              child: Container(
                                width: (MediaQuery.of(context).size.width / 2) -
                                    30,
                                padding: EdgeInsets.all(8),
                                decoration:
                                    BoxDecoration(color: Color(0xFF444152)),
                                child: Center(
                                    child: Text(
                                  checkInEnd.format(context),
                                  style: TextStyle(color: Colors.white),
                                )),
                              ),
                            ),
                          ],
                        )),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(left: 10, top: 12),
                                child: Text(
                                  "Employees List",
                                )),
                            Container(
                              child: Checkbox(
                                value: allChecked,
                                activeColor: Color(0xFF444152),
                                onChanged: (bool value) {
                                  setState(() {
                                    allChecked = value;
                                    for (var item in this.employess) {
                                      item["checked"] = allChecked;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              )),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 300,
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(employess.length, (i) {
                    return _generateListOfEmployees(i);
                  }),
                )))
          ],
        ));
  }
}
