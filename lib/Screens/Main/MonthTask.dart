import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Main/TaskHistory.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';

class MonthTask extends StatefulWidget {
  final String title;
  final String month;
  MonthTask({
    Key key,
    this.title,
    this.month
  }) : super(key: key);

  @override
  _MonthTaskState createState() => _MonthTaskState();
}

class _MonthTaskState extends State<MonthTask> {
  DatabaseReference _ref;
  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance
        .reference()
        .child(LAST_TASK_FIREBASE);
  }


  @override
  Widget build(BuildContext context) {
    String month = widget.month;
    String title = "Month $month";

    Query query = _ref.child(month);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(child: Text(title ,style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.white),)),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.qr_code,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScanMain()),
                  );
                },
                tooltip: "Back",
              );
            },
          ),
        ],
        elevation: 50.0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                  Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context);
                },
              tooltip: "Back",
            );
          },
        ),
        brightness: Brightness.dark,
      ),
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: query,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map tasks = snapshot.value;
            return _buildTaskOnMonthItem(tasks: tasks, month: month);
          },
        ),
      ),
    );
  }

  Widget _buildTaskOnMonthItem({Map tasks, String month}) {
    String taskIdSub = tasks['taskId'].toString().length > 20
        ? tasks['taskId'].toString().substring(0, 20) + "..."
        : tasks['taskId'].toString();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      height: 95,
      color: Colors.pink[50],
      child: Row(
        children: [
          Icon(
            Icons.assignment_outlined,
            color: Theme.of(context).primaryColor,
            size: 50,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    SelectableText(
                      taskIdSub,
                      onTap: () => _taskHistory(month, tasks['taskId']),
                      style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      tasks['technicianName'],
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.pink,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      tasks['taskSize'],
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.pink,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]
      ),
    );
  }

  void _taskHistory(String month, String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskHistory(month: month, taskId: taskId,)),
    );
  }
}
