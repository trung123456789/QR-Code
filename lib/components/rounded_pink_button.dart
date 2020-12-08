import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';

class RoundedPinkButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  const RoundedPinkButton({
    Key key,
    this.text,
    this.press,
    this.color = Colors.white,
    this.textColor = kPrimaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          color: color,
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
