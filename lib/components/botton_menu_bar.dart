import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Main/AddTask.dart';
import 'package:flutter_qr_scan/Screens/Main/AllTask.dart';
import 'package:flutter_qr_scan/Screens/Main/PersonalTask.dart';
import 'package:flutter_qr_scan/Screens/Main/UserManage.dart';

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
  int _currentIndex = 0;

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
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
            ),
            title: Text(
              ALL_TASKS_TEXT,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            title: Text(
              PERSONAL_TASK_TEXT,
            ),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.playlist_add_rounded,
              ),
              title: Text(
                ADD_TASK_TEXT,
              )),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.portrait_rounded,
            ),
            title: Text(
              USER_TEXT,
            ),
          )
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
