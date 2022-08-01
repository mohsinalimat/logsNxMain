import 'dart:async';

import 'package:geolocator/geolocator.dart';

class Config {
  // static String url = "http://192.168.0.104:3001"; // HOME
    // static String url = "http://192.168.43.160:3000"; // Hotspot
    // static String url = "http://192.168.10.15:3000"; // Pindi Home

  // static String url = "http://172.20.10.3:8888/logsnx";
  // static String url = "http://appapi.logsnx.com";
  // static String url = "https://api.logsnx-db.logsnx.com"; // Online
    static String url = "https://api-v2.logsnx.com/"; // Online - V2

  // static String url = "http://192.168.1.5:3001"; // OFFICE

  static StreamSubscription<Position> positionStream;
  static String lat; 
  static String lng;
  static List geoFences;
}
