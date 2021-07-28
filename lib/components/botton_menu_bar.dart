import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Main/AddTask.dart';
import 'package:flutter_qr_scan/Screens/Main/AllTask.dart';
import 'package:flutter_qr_scan/Screens/Main/PersonalTask.dart';
import 'package:flutter_qr_scan/Screens/Main/UserManage.dart';
import 'package:flutter_qr_scan/navigation_bar/navigation_bar.dart';

import '../Constants/constants.dart';

class BottomMenuBar extends StatefulWidget {
  final int idx;
  final String userId;

  const BottomMenuBar({
    Key key,
    this.idx,
    this.userId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomMenuBarState();
  }
}

class _BottomMenuBarState extends State<BottomMenuBar> {
  int _selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    final String userId = widget.userId;

    final List<Widget> _children = [
      AllTask(
        title: ALL_TASKS_TEXT,
        userId: userId,
      ),
      PersonalTask(
        title: PERSONAL_TASK_TEXT,
        userId: userId,
      ),
      AddTask(
        title: ADD_TASK_TEXT,
        userId: userId,
      ),
      UserManage(
        title: USER_TEXT,
        userId: userId,
      ),
    ];

    return Scaffold(
      body: _children[_selectedItem],
      bottomNavigationBar: CustomBottomNavigationBar(
        iconList: [
          Icons.people,
          Icons.person,
          Icons.playlist_add_rounded,
          Icons.portrait_rounded
        ],
        onChange: (val) {
          setState(() {
            _selectedItem = val;
          });
        },
        defaultSelectedIndex: 0,
      ),
    );
  }
}
