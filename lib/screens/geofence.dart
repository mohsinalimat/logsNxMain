import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//     as bg;

import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/config.dart';
import 'package:logsnx/services/employee.dart';

JsonEncoder encoder = new JsonEncoder.withIndent("     ");

class GeoFenceScreen extends StatefulWidget {
  @override
  _GeoFenceScreenState createState() => _GeoFenceScreenState();
}

class _GeoFenceScreenState extends State<GeoFenceScreen> {
  bool _isMoving;
  bool _enabled;
  String _motionActivity;
  String _odometer;
  String _content;
  String status = "";
  String geofenceState = 'N/A';
  double latitude = 33.5498111;
  double longitude = 73.1245165;
  double radius = 100.0;
  var cntrl = MapController();
  var lat = 0.0;
  var lng = 0.0;
  List<Marker> markers = [];
  List<CircleMarker> circles = [];

  // Testing

  getLocation() async {
    var loc = await Auth().getLocation();
    if (loc[0] != null) {
      if (mounted) {
        setState(() {
          this.lat = double.parse(loc[0]);
          this.lng = double.parse(loc[1]);
        });

        this.markers[0] = Marker(
          width: 20.0,
          height: 20.0,
          point: LatLng(lat, lng),
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
        );
      }
    }
  }

  getInitialLocation() async {
    var loc = await Auth().getLocation();
    if (loc[0] != null) {
      if (mounted) {
        setState(() {
          this.lat = double.parse(loc[0]);
          this.lng = double.parse(loc[1]);
        });
        this.cntrl.move(LatLng(this.lat, this.lng), 16.5);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.markers.add(Marker());
    // this.setupGeoFencing();
    this.getInitialLocation();
    Timer.periodic(Duration(seconds: 2), (timer) {
      getLocation();
    });
    for (var i = 0; i < Config.geoFences.length; i++) {
      this.circles.add(CircleMarker(
          //radius marker
          point: LatLng(double.parse(Config.geoFences[i]["lat"]),
              double.parse(Config.geoFences[i]["lng"])),
          color: Colors.blue.withOpacity(0.3),
          borderStrokeWidth: 1.0,
          borderColor: Colors.blue,
          radius: double.parse(Config.geoFences[i]["radius"]) //radius
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login With Geofencing"),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.textsms),
          //   onPressed: () {
          //     // var f = 0;
          //     var index = 0;
          //     var fence = Config.geoFences[index];
          //     var projects = fence["projects"];
          //     if (projects.length == 1) {
          //       Auth().saveCurrentProject(projects[0]["name"]);
          //     } else {
          //       showModalBottomSheet(
          //           context: context,
          //           builder: (BuildContext bc) {
          //             return Container(
          //               child: new Wrap(children: [
          //                 Column(
          //                   children: <Widget>[
          //                     Container(
          //                         margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
          //                         child: Text(
          //                           "Select Project",
          //                           style: TextStyle(
          //                               fontWeight: FontWeight.bold,
          //                               fontSize: 20),
          //                         )),
          //                     Wrap(
          //                       children:
          //                           List.generate(projects.length, (index) {
          //                         return ListTile(
          //                             leading: Icon(Icons.work),
          //                             title: new Text(projects[index]["name"]),
          //                             onTap: () {
          //                               Auth().saveCurrentProject(
          //                                   projects[index]["name"]);
          //                             });
          //                       }),
          //                     ),
          //                     Container(
          //                       margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
          //                       child: Row(
          //                         mainAxisAlignment: MainAxisAlignment.center,
          //                         children: <Widget>[
          //                           FloatingActionButton(
                                      
          //                             child: Icon(Icons.close),
          //                             backgroundColor: Colors.red,
          //                             // color: Colors.red,
          //                             onPressed: () {
          //                               Navigator.of(context).pop();
          //                             },
          //                           ),
          //                         ],
          //                       ),
          //                     )
          //                   ],
          //                 )
          //               ]),
          //             );
          //           });
          //     }
          //   },
          // )
        ],
        // actions: <Widget>[Switch(value: _enabled, onChanged: _onClickEnable)],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: FlutterMap(
              mapController: cntrl,
              options: new MapOptions(
                  center: LatLng(this.lat, this.lng),
                  maxZoom: 16.5,
                  minZoom: 16.5
                  // zoom: 15.0,
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
                CircleLayerOptions(circles: circles)
              ],
            ),
          ),
        ],
      ),
    );
    //   return Scaffold(
    //     appBar:
    //         AppBar(title: const Text('Background Geolocation'), actions: <Widget>[
    //       Switch(value: _enabled, onChanged: _onClickEnable),
    //     ]),
    //     body: SingleChildScrollView(child: Text("Status: " + status)),
    //     bottomNavigationBar: BottomAppBar(
    //         child: Container(
    //             padding: const EdgeInsets.only(left: 5.0, right: 5.0),
    //             child: Row(
    //                 mainAxisSize: MainAxisSize.max,
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: <Widget>[
    //                   IconButton(
    //                     icon: Icon(Icons.gps_fixed),
    //                     onPressed: _onClickGetCurrentPosition,
    //                   ),
    //                   Text('$_motionActivity · $_odometer km'),
    //                   MaterialButton(
    //                       minWidth: 50.0,
    //                       child: Icon(
    //                           (_isMoving) ? Icons.pause : Icons.play_arrow,
    //                           color: Colors.white),
    //                       color: (_isMoving) ? Colors.red : Colors.green,
    //                       onPressed: _onClickChangePace)
    //                 ]))),
    //   );
    // }
  }
}
