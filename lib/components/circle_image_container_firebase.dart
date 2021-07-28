import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';

class CircularImageFirebase extends StatelessWidget {
  final String _image;
  final double _width;
  final double _height;

  CircularImageFirebase(this._image, this._width, this._height);

  @override
  Widget build(BuildContext context) {
    return _image != NO_IMAGE
        ? ClipRRect(
            child: Image.network(
              _image,
              width: _width,
              height: _height,
              fit: BoxFit.fitWidth,
            ),
          )
        : Container(
            width: _width,
            height: _height,
            child: Image.asset(
              "assets/images/no_image.png",
              width: _width,
              height: _height,
              fit: BoxFit.cover,
            ),
          );
  }
}
