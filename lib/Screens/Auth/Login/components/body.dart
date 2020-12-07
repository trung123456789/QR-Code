import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';
import 'package:flutter_qr_scan/components/notify_login.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/components/background.dart';
import 'package:flutter_qr_scan/Screens/Main/MainScreen.dart';
import 'package:flutter_qr_scan/components/have_not_an_account_acheck.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:flutter_qr_scan/components/rounded_input_field.dart';
import 'package:flutter_qr_scan/components/rounded_password_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login_screen.dart';

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
  final TextEditingController _yourIDController = TextEditingController();
  final TextEditingController _yourPasswordController = TextEditingController();
  DatabaseReference _refUserInfo =
      FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/undraw_mobile_login_ikmv.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              controller: _yourIDController,
              hintText: "Your ID",
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              controller: _yourPasswordController,
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
    String yourId = _yourIDController.text;
    String yourPassword = _yourPasswordController.text;

    _refUserInfo.child(yourId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values != null && values['yourPassword'] == yourPassword) {
        setAuthority(yourId);
        setState(() {
          visibility = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return MainScreen(userId: yourId,);
            },
          ),
        );
      } else {
        setState(() {
          visibility = true;
        });
      }
    });
  }
}
