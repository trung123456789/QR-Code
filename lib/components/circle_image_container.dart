import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CircularImage extends StatelessWidget {
  final PickedFile _image;

  CircularImage(this._image);

  @override
  Widget build(BuildContext context) {
    return _image != null
        ? ClipRRect(
            child: Image.file(
              File(_image.path),
              width: 300,
              height: 150,
              fit: BoxFit.fitHeight,
            ),
          )
        : Container(
            width: 300,
            height: 150,
            child: Image.asset(
              "assets/images/no_image.png",
              width: 300,
              height: 150,
              fit: BoxFit.fitHeight,
            ),
          );
  }
}
