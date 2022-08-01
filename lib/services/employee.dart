import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logsnx/services/config.dart';

class EmployeeService {
  var dio = new Dio();
  Future<dynamic> getEmployees(id, cid, {dep}) async {
    var url = Config.url +
        '/users/getSubUsers/' +
        id.toString() +
        '/' +
        cid.toString();
    if (dep != null) {
      url = Config.url +
        '/users/getSubUsers/' +
        id.toString() +
        '/' +
        cid.toString() + '/' + dep.toString();
    }
    
    print(url);
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }
  Future<dynamic> getUserById(id, cid) async {
    var url = Config.url +
        '/users/getUserById/' +
        id.toString() +
        '/' +
        cid.toString();
    print(url);
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getEmployeesWithLoc(id, cid) async {
    var url =
        Config.url + '/employeeswithlocations.php?id=' + id + '&cid=' + cid;
    var resp = await dio.get(url);
    print(resp.data);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> createSlot(data) async {
    var url = Config.url + '/users/createSlot';
    var resp = await dio.post(url, data: data);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> deleteSlot(id) async {
    var url = Config.url + '/users/deleteSlot/' + id.toString();
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getSlots(id, company) async {
    var url = Config.url + '/users/getSlots/' + id + '/' + company;
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getLog(id, cid, date) async {
    var url = Config.url + '/logs/get';
    print(url);
    var resp =
        await dio.post(url, data: {"user": id, "company": cid, "date": date});
    var d = json.decode(json.encode(resp.data));
    return d;
  }
  Future<dynamic> checkFence(data) async {
    var url = Config.url + '/logs/checkFence';
    print(url);
    var resp =
        await dio.post(url, data: data);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getAllLatLng(id, cid) async {
    var url = Config.url + '/all_lng_lat.php?id=' + id + '&cid=' + cid;
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getEmployeeDetails(id) async {
    var url = Config.url + '/users/getUserDetails/' + id;
    print(url);
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getMachines(cid) async {
    var url = Config.url + '/users/getMachines/' + cid.toString();
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> updateLocation(id, lat, lng) async {
    var url = Config.url + '/users/updateLocation/' + id;
    var resp;
    try {
      resp = await dio.post(url, data: {"latitude": lat, "longitude": lng});
      return resp.data;
    } on Exception {}
    // var d = json.decode(json.encode());
    // return resp.data;
  }

  Future<dynamic> addFace(data) async {
    var url = Config.url + '/users/addFace';
    var resp = await dio.post(url, data: data);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> allFaces(companyId, hrId) async {
    var url = Config.url +
        '/getallfaces.php?companyId=' +
        companyId +
        "&hrId=" +
        hrId;
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getMyFace(userId, cid) async {
    var url = Config.url +
        '/users/myFace/' +
        userId.toString() +
        "/" +
        cid.toString();
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getMyFaces(data) async {
    var url = Config.url + '/users/myFaces';
    var resp = await dio.post(url, data: data);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  // Future<dynamic> getMyFace(companyId, hrId) async {
  //   var url = Config.url +
  //       '/getallfaces.php?companyId=' +
  //       companyId +
  //       "&hrId=" +
  //       hrId;
  //   var resp = await dio.get(url);
  //   var d = json.decode(json.encode(resp.data));
  //   return d;
  // }

  Future<dynamic> compareFace(data) async {
    var url = Config.url + '/aws/compare';
    try {
      var resp = await dio.post(url, data: data);
      var d = json.decode(json.encode(resp.data));
      return d;
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<dynamic> getMacs(companyId) async {
    var url =
        Config.url + '/getVerifiedMacs.php?companyId=' + companyId.toString();
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getAllPendingFaces(cid) async {
    var url = Config.url + '/users/getPendingFaces/' + cid.toString();
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> faceDecision(id, accept) async {
    var url = Config.url +
        '/users/faceDecision/' +
        id.toString() +
        "/" +
        accept.toString();
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> logout(id, fcmToken) async {
    var url = Config.url + '/logout/' + id;
    var resp = await dio.post(url, data: {"fcmToken": fcmToken});
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> isVerified(id) async {
    var url = Config.url + '/users/isApprovedWithoutMac/' + id.toString();
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> getFences(c) async {
    var url = Config.url + '/users/getFences/' + c.toString();
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }

  Future<dynamic> checkWithFence(data) async {
    var url = Config.url + '/logs/create/fence';
    try {
      var resp = await dio.post(url, data: data);
      var d = json.decode(json.encode(resp.data));
      return d;
    } catch (e) {
      print(e);
      return {};
    }
  }
  Future<dynamic> uploadToS3(name, image) async {
    var url = Config.url + '/aws/imageToS3';
    var resp = await dio.post(url, data: {"name": name, "image": image});
    var d = json.decode(json.encode(resp.data));
    return d;
  }
  Future<dynamic> detectFaces(name) async {
    var url = Config.url + '/aws/detectFaces';
    var resp = await dio.post(url, data: {"name": name});
    var d = json.decode(json.encode(resp.data));
    return d;
  }
}
