import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logsnx/services/config.dart';

class GuardianSrv {
  var dio = new Dio();
  Future<dynamic> getStudents(id) async {
    var url = Config.url +
        '/web/employee/list/student';
    print(url);
    var resp = await dio.post(url, data: {"id": id});
    var d = json.decode(json.encode(resp.data));
    return d;
  }
  Future<dynamic> getLogs(id) async {
    var url = Config.url +
        '/web/employee/student';
    print(url);
    var resp = await dio.post(url, data: {"id": id});
    var d = json.decode(json.encode(resp.data));
    return d;
  }
}
