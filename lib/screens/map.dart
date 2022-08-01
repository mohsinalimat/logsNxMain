import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong/latlong.dart';
import 'package:logsnx/screens/profile.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/employee.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  _showAlert(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  var empSrv = new EmployeeService();
  var auth = new Auth();
  var hodId;
  var userId;
  var companyId;
  List<dynamic> emps = [];
  List<Marker> markers = [];
  var cntrl = MapController();
  var selectedEmployee;
  var lat = 0.0;
  var lng = 0.0;
  _generateListOfEmployees(i) {
    print(emps[i]);
    return GestureDetector(
      onTap: () {
        if (this.emps[i]["latitude"] != null) {
          this.selectedEmployee = this.emps[i];
          setState(() {
            this.lat = double.parse(this.emps[i]["latitude"]);
            this.lng = double.parse(this.emps[i]["longitude"]);
          });
          this.cntrl.move(LatLng(this.lat, this.lng), 17.0);
        } else {
          _showAlert("No Location Found");
        }
      },
      child: Card(
          child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              width: 70,
              child: emps[i]["userDetails"]["gender"] == "Male"
                  ? Image.asset("assets/boy.png")
                  : Image.asset("assets/girl.png"),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    emps[i]["userDetails"]["firstName"] + " " + emps[i]["userDetails"]["lastName"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(emps[i]["userDetails"]["hrId"])
                ],
              ),
            ),
            Spacer(),
            emps[i]["latitude"] != null
                ? Container(
                    margin: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.location_on,
                    ),
                  )
                : Container()
          ],
        ),
      )),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getLocation();
    this.auth.getCompanyId().then((c) {
      this.auth.getUserId().then((e) {
        this.userId = e;
        this.companyId = c;
        this.empSrv.getEmployees(userId, companyId).then((a) {
          print(a);
          for (var item in a) {
            this.emps.add(item);
            this.old.add(item);
            if (item['longitude'] != "" && item['longitude'] != null) {
              this.markers.add(Marker(
                    width: 20.0,
                    height: 20.0,
                    point: LatLng(
                        double.parse(item['latitude']), double.parse(item['longitude'])),
                    builder: (ctx) => InkWell(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => ProfileScreen(
                        //           id: int.parse(item["EmployeeId"]))),
                        // );
                      },
                      child: Container(
                        child: Image.asset("assets/boy.png"),
                      ),
                    ),
                  ));
            }
          }
          setState(() {});
        });
      });
    });
  }

  getLocation() async {
    var loc = await this.auth.getLocation();
    if (loc[0] != null) {
      setState(() {
        this.lat = double.parse(loc[0]);
        this.lng = double.parse(loc[1]);
      });
      this.cntrl.move(LatLng(this.lat, this.lng), 13.0);
    }
  }

  var search = TextEditingController();
  var isSearch = false;
  var old = [];
  searchEmp() {

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height -
                      (MediaQuery.of(context).size.height / 2),
                  child: FlutterMap(
                    mapController: cntrl,
                    options: new MapOptions(
                      center: LatLng(this.lat, this.lng),
                      zoom: 13.0,
                    ),
                    layers: [
                      new TileLayerOptions(
                        urlTemplate: "https://api.tiles.mapbox.com/v4/"
                            "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
                        additionalOptions: {
                          'accessToken':
                              'pk.eyJ1IjoiYWJ1emFyMjQwNyIsImEiOiJjazl5a2xiZnAwcWcyM25vOGZ4MGR3eDU0In0.OwJfG7Xk4X9g_Sxt_zSObw',
                          'id': 'mapbox.streets',
                        },
                      ),
                      new MarkerLayerOptions(markers: this.markers),
                    ],
                  ),
                ),
                selectedEmployee == null
                    ? Container()
                    : AppBar(
                        title: Text(this.selectedEmployee["userDetails"]["firstName"] + " " + this.selectedEmployee["userDetails"]["lastName"]),
                        actions: <Widget>[
                          IconButton(
                            onPressed: () async {
                              this.selectedEmployee = null;
                              var loc = await this.auth.getLocation();
                              if (loc[0] != null) {
                                setState(() {
                                  this.lat = double.parse(loc[0]);
                                  this.lng = double.parse(loc[1]);
                                });
                                this
                                    .cntrl
                                    .move(LatLng(this.lat, this.lng), 13.0);
                              }
                            },
                            color: Colors.white,
                            icon: Icon(Icons.clear),
                          )
                        ],
                      ),
                // Positioned(
                //   bottom: 0,
                //   child: Container(
                //     width: MediaQuery.of(context).size.width,
                //     color: Colors.white,
                //     padding: EdgeInsets.only(left: 10, right: 10),
                //     child: TextField(
                //       decoration: InputDecoration(
                //         hintText: "Search Employee",
                //         suffixIcon: IconButton(
                //             icon: Icon(Icons.clear),
                //             onPressed: () {
                //               debugPrint('222');
                //             }),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            AnimatedContainer(
              duration: Duration(seconds: 1),
              padding: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width,
              height: (MediaQuery.of(context).size.height -
                      (MediaQuery.of(context).size.height / 2)) -
                  60,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(emps.length, (i) {
                  print(emps[i]);
                  return _generateListOfEmployees(i);
                }),
              )),
            )
          ],
        ),
      ),
    );
  }
}
