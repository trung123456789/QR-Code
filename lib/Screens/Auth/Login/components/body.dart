import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/components/background.dart';
import 'package:flutter_qr_scan/Screens/Main/MainScreen.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';
import 'package:flutter_qr_scan/components/have_not_an_account_acheck.dart';
import 'package:flutter_qr_scan/components/notify_login.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:flutter_qr_scan/components/rounded_input_field.dart';
import 'package:flutter_qr_scan/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatefulWidget {
  final String title;
  String userId;

  Body({
    Key key,
    this.title,
    this.userId,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool visibility = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "LOGIN",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: kPrimaryColor,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/undraw_contract_uy56.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              controller: _idController,
              hintText: "ID",
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              controller: _passwordController,
              onChanged: (value) {},
            ),
            visibility ? NotifyLogin(
              icon: Icon(
                Icons.warning_amber_sharp,
                color: Colors.pink,
                size: 18.0,
              ),
              notify: ' Wrong ID or password!',
            ) : new Container(),
            RoundedButton(
              text: "LOGIN",
              press: () {
                goToMainScreen();
              },
            ),
            SizedBox(height: size.height * 0.03),
            HaveNotAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ScanMain(
                        text: LOGIN_CHECK,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setAuthority(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setString("userId", userId);
  }

  void goToMainScreen() {
    String id = _idController.text;
    String password = _passwordController.text;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore
        .collection('User')
        .where('login_id', isEqualTo: id)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          if (doc != null && doc.get('password') == password) {
            setAuthority(id);
            setState(() {
              visibility = false;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return MainScreen(userId: id,);
                },
              ),
            );
          } else {
            setState(() {
              visibility = true;
            });
          }
        });
      });
    });
  }
}
