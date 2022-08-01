import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logsnx/services/auth.dart';
import 'package:logsnx/services/config.dart';
import 'package:logsnx/services/employee.dart';

class NewProfileScreen extends StatefulWidget {
  @override
  _NewProfileScreenState createState() => _NewProfileScreenState();
}

class _NewProfileScreenState extends State<NewProfileScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};
  var companyId;
  var userId;
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(Config.lat != null ? double.parse(Config.lat) : 25.1972018,
        Config.lng != null ? double.parse(Config.lng) : 55.2721877),
    zoom: 16,
  );

  CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(Config.lat != null ? double.parse(Config.lat) : 25.1972018,
          Config.lng != null ? double.parse(Config.lng) : 55.2721877),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  var user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth().getUserId().then((u) {
      this.userId = u;
      Auth().getCompanyId().then((c) async {
        companyId = c;
        EmployeeService().getUserById(userId, companyId).then((value) {
          print(value);
          this.user = value;
          setState(() {});
        });
        this.markers.add(Marker(
            flat: true,
            markerId: MarkerId(u),
            onTap: () {},
            // alpha: 10.0,
            infoWindow: InfoWindow(title: "You"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
            position:
                LatLng(double.parse(Config.lat), double.parse(Config.lng))));
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          // color: Colors.red,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  // padding: EdgeInsets.fromLTRB(30, 0, 20, 0),
                  // color: Colors.red,
                  height: 150,
                  child: user == null
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFF9B622)),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                margin: EdgeInsets.fromLTRB(40, 0, 0, 0),
                                width: 100,
                                height: 100,
                                child: Image.asset(
                                  "assets/dad.png",
                                  fit: BoxFit.cover,
                                )
                                // child: user["uId"]["image"] == null ? Image.asset("assets/dad.png", fit: BoxFit.cover,) : Image.network(Config.url +  "web/uploads/" + user["uId"]["image"], fit: BoxFit.cover,),
                                ),
                            Container(
                                margin: EdgeInsets.fromLTRB(40, 0, 0, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user["displayName"] != null ? user["displayName"]: user["uId"]["username"],
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    Container(
                                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Text(user["roleId"]["name"],
                                            style: TextStyle(fontSize: 12))),
                                    Container(
                                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Text(user["hrId"] != null ? user["hrId"] : "",
                                            style: TextStyle(fontSize: 12))),
                                    Container(
                                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Text(user["department"] != null ? user["department"]["name"] : "",
                                            style: TextStyle(fontSize: 12))),
                                    Container(
                                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Text(user["designation"] != null ? user["designation"]["name"]: "",
                                            style: TextStyle(fontSize: 12))),
                                  ],
                                ))
                          ],
                        )),
              Config.lat != null
                  ? Container(
                      height: MediaQuery.of(context).size.height - 292,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
                      child: GoogleMap(
                        mapType: MapType.satellite,
                        initialCameraPosition: _kGooglePlex,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        mapToolbarEnabled: false,
                        markers: markers,
                      ),
                    )
                  : Center(
                      child: Text("Location not enabled"),
                    ),
            ],
          )),
    );
  }
}
