import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Screens/Main/AddTask.dart';
import 'package:flutter_qr_scan/Screens/Main/AllTask.dart';
import 'package:flutter_qr_scan/Screens/Main/PersonalTask.dart';
import 'package:flutter_qr_scan/Screens/Main/UserManage.dart';

class BottonMenuBar extends StatefulWidget {
  final int idx;
  final String userId;

  const BottonMenuBar({
    Key key,
    this.idx,
    this.userId,
  }) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return _BottonMenuBarState();
  }
}

class _BottonMenuBarState extends State<BottonMenuBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      AllTask(title: 'All Task'),
      PersonalTask(title: 'Personal Task'),
      AddTask(title: 'Add Task', userId: widget.userId,),
      UserManage(title: 'User'),
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
            icon: Icon(Icons.people),
            title: Text('All tasks'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Personal Task'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.playlist_add_rounded),
              title: Text('Add task')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.portrait_rounded),
              title: Text('Users'),
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