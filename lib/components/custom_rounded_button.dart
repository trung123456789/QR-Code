import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';

class CustomRoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color textColor;
  final double width, height;

  const CustomRoundedButton({
    Key key,
    this.text,
    this.press,
    this.textColor = Colors.white,
    this.width = 100,
    this.height = 35,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: kPrimaryColor,
          ),
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(
                decoration: TextDecoration.none,
                color: textColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
