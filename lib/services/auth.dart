import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logsnx/services/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  var dio = new Dio();
  Future<dynamic> login(data) async {
    var url = Config.url + '/login';
    var resp = await dio.post(url, data: data);
    print(resp.data);
    var d = json.decode(json.encode(resp.data));
    return d;
  }
  Future<dynamic> companies(uid) async {
    var url = Config.url + '/companies/' + uid;
    var resp = await dio.get(url);
    var d = json.decode(json.encode(resp.data));
    return d;
  }
  

  Future<bool> setLogin(user, token, {type: "email"}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    // if (role["name"] == "Employee") {
    //   await prefs.setBool('isExec', false);
    //   await prefs.setBool('isHod', false);
    // } else if (role["name"] == "HOD") {
    //   await prefs.setBool('isHod', true);
    //   await prefs.setBool('isExec', false);
    // } else {
    //   await prefs.setBool('isExec', true);
    //   await prefs.setBool('isHod', true);
    // }
    await prefs.setString('user', user);
    // await prefs.setString('details', details);

    // await prefs.setString('company', company);
    await prefs.setString('fcmToken', token);
    // await prefs.setString('role', json.encode(role).toString());
    await prefs.setString('type', type);

    return true;
  }
  Future<bool> setCompanies(details) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('details', details);

    return true;
  }
  Future getCompanies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString('details'));
  }
  Future<bool> setActiveCompanyId(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('acid', id);
    return true;
  }
  Future<bool> setDepartment(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dep', id);
    return true;
  }
  Future<bool> setUserDetailsId(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('udid', id);
    return true;
  }
  Future<bool> setActiveType(type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ActiveType', type);
    return true;
  }
  Future<bool> setRole(cid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var details = json.decode(prefs.getString("details"));
    var role = "";
    for (var item in details) {
      if (item["companyId"]["_id"] == cid) {
        role = item["roleId"]["name"];
        break;
      }
    }
    await prefs.setString('role', role);
    return true;
  }
  Future<String> getActiveType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('ActiveType');
  }
  Future<String> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
  Future<String> getDepartment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('dep');
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('loggedIn') == null)
      return false;
    else
      return true;
  }

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    return true;
  }

  Future<dynamic> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // User user = User.fromJson(json.decode(prefs.getString('user')));
    return 0;
  }

  Future<dynamic> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = json.decode(prefs.getString("user"));
    return user["_id"];
  }

  Future<dynamic> myFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("fcmToken") == null) {
      return "";
    } else {
      return prefs.getString("fcmToken");
    }
  }

  Future<dynamic> getEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString('employee'));
  }

  Future<dynamic> getCompany() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString('company'));
  }

  Future<dynamic> getCompanyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    return prefs.getString('acid');

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var user = json.decode(prefs.getString("company"));
    // return user["_id"];
  }
  Future<dynamic> getUserDetailsId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    return prefs.getString('udid');
  }

  Future<dynamic> saveMyLocation(lat, lng) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lat', lat);
    await prefs.setString('lng', lng);
  }

  Future<dynamic> saveCurrentProject(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('project', name);
  }

  Future<dynamic> getCurrentProject() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('project');
  }

  Future<dynamic> getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return [prefs.getString('lat'), prefs.getString('lng')];
  }

  Future<bool> isHod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isHod");
  }

  Future<bool> isExec() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isExec");
  }
}
