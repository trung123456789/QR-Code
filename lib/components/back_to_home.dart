import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';

class BackToHome extends StatelessWidget {
  final bool login;
  final Function press;
  const BackToHome({
    Key key,
    this.login = true,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: press,
          child: Text(
            BACK_TO_HOME,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
