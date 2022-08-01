import 'package:flutter/material.dart';
import 'package:logsnx/screens/school/logs.dart';
import 'package:logsnx/screens/school/students.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Student Logs',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.cover, image: AssetImage('assets/school.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text('Student Logs'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => StudentLogScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.supervised_user_circle_sharp),
            title: Text('My Students'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                    pageBuilder: (_, __, ___) => StudentListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
