import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';

class NotifyLogin extends StatelessWidget {
  final String notify;
  final Icon icon;
  const NotifyLogin({
    Key key,
    this.icon,
    this.notify,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        icon,
        Text(
          notify,
          style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
