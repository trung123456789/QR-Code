import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/components/botton_menu_bar.dart';

class MainScreen extends StatelessWidget {
  final int idx;
  final String userId;

  const MainScreen({
    Key key,
    this.idx,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomMenuBar(userId: userId,),
    );
  }
}