import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewPage extends StatelessWidget {
  final ImageProvider<Object> photoView;

  const PhotoViewPage({
    Key key,
    this.photoView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0.0,
          backgroundColor: Colors.black,
        ),
        body: Container(
          child: PhotoView(
            imageProvider: this.photoView,
          )),

        );

  }
}
