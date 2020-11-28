import 'dart:io';

import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final File _image;

  CircularImage(this._image);

  @override
  Widget build(BuildContext context) {
    return _image != null
        ? ClipRRect(
            child: Image.file(
              _image,
              width: 100,
              height: 100,
              fit: BoxFit.fitHeight,
            ),
          )
        : Container(
            width: 100,
            height: 100,
            child: Image.asset(
              "assets/images/no_image.png",
              width: 100,
              height: 100,
              fit: BoxFit.fitHeight,
            ),
          );
  }
}
