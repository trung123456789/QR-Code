import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/login_screen.dart';
import 'package:flutter_qr_scan/Screens/Main/MainScreen.dart';
import 'package:flutter_qr_scan/Screens/QrScan/DetailQR/detail_qr_screen.dart';
import 'package:flutter_qr_scan/components/back_to_home.dart';
import 'package:flutter_qr_scan/components/rounded_pink_button.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'background.dart';

class ScanMain extends StatelessWidget {
  String text;
  String userId;

  ScanMain({
    Key key,
    @required this.text,
    this.userId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: size.height * 0.03),
              Image.asset(
                "assets/images/qr-code.png",
                width: size.width * 0.4,
              ),
              SizedBox(height: size.height * 0.03),
              Text(
                "Scan the QR code on the machine and",
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              Text(
                " watch your history fixed",
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              SizedBox(height: size.height * 0.15),
              RoundedPinkButton(
                text: "SCAN QR CODE",
                press: () {
                  _scan(context);
                },
              ),
              SizedBox(height: size.height * 0.02),
              BackToHome(
                login: false,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return text == LOGIN_CHECK ? LoginScreen() : MainScreen();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _scan(BuildContext context) async {
    String barcode = await scanner.scan();
    if (barcode == "wonderwoman") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailQRScreen()),
      );
    }
  }
}
