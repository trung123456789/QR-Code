import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Util {
  static Future<void> checkUser(String userId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userIdOnstore = prefs.getString('userId');

    if (userIdOnstore == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }

    CollectionReference user = FirebaseFirestore.instance.collection('User');
    user
        .where('login_id', isEqualTo: userId)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (!doc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      });
    });
  }
}
