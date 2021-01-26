import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/login_screen.dart';

class Util {
  static Future<void> checkUser(String userId, BuildContext context) async {
    DatabaseReference _refUserInfo =
        FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);

    Query _refExcu = _refUserInfo.child(userId);
    await _refExcu.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }
}
