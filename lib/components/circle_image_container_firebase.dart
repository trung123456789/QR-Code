import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';

class CircularImageFirebase extends StatelessWidget {
  final String _image;

  CircularImageFirebase(this._image);

  @override
  Widget build(BuildContext context) {
    return _image != NO_IMAGE
        ? ClipRRect(
            child: Image.network(
              _image,
              width: 200,
              height: 100,
              fit: BoxFit.fitWidth,
            ),
          )
        : Container(
            width: 200,
            height: 100,
            child: Image.asset(
              "assets/images/no_image.png",
              width: 200,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
  }
}
