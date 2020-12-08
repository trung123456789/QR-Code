import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';

class RoundedNormalButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  const RoundedNormalButton({
    Key key,
    this.text,
    this.press,
    this.color = kNormalColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
      child: Center(
        child: Ink(
          decoration: const ShapeDecoration(
            color: kPrimaryColor,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(Icons.add),
            color: Colors.white,
            onPressed: () {press();},
          ),
        ),
      ),
      padding: EdgeInsets.all(16),
      shape: CircleBorder(),
    );
  }
}
