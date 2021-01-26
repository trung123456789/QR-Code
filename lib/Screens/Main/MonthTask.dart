import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Models/MonthTaskInfo.dart';
import 'package:flutter_qr_scan/Screens/Main/TaskHistory.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';

class MonthTask extends StatefulWidget {
  final String title;
  final String month;
  final String userId;
  MonthTask({Key key, this.title, this.month, this.userId}) : super(key: key);

  @override
  _MonthTaskState createState() => _MonthTaskState();
}

class _MonthTaskState extends State<MonthTask> {
  DatabaseReference _ref;
  int present = 0;
  int perPage = 15;
  int returnMaxNum = 0;

  List monthTasks = [];
  List itemCurrentPages = [];

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.reference().child(LAST_TASK_FIREBASE);
    initialValue(widget.month);
  }

  Future<void> initialValue(String month) async {
    Query _refExcu = _ref.child(month).orderByChild('sort');
    await _refExcu.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        MonthTaskInfo monthTaskInfo = new MonthTaskInfo();
        monthTaskInfo.task_id = value['taskId'].toString();
        monthTaskInfo.task_name = value['taskName'].toString();
        monthTaskInfo.technician_name = value['technicianName'].toString();
        monthTaskInfo.task_size = value['taskSize'].toString();
        monthTaskInfo.task_date = value['date'].toString();
        monthTasks.add(monthTaskInfo);
      });
    });

    setState(() {
      monthTasks.sort((a, b) => b.task_date.compareTo(a.task_date));
      if ((present + perPage) > monthTasks.length) {
        itemCurrentPages
            .addAll(monthTasks.getRange(present, monthTasks.length));
        present = monthTasks.length;
      } else {
        itemCurrentPages
            .addAll(monthTasks.getRange(present, present + perPage));
        present = present + perPage;
      }
    });
  }

  void loadMore() {
    setState(() {
      if ((present + perPage) > monthTasks.length) {
        itemCurrentPages
            .addAll(monthTasks.getRange(present, monthTasks.length));
        present = monthTasks.length;
      } else {
        itemCurrentPages
            .addAll(monthTasks.getRange(present, present + perPage));
        present = present + perPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String month = widget.month;
    String userId = widget.userId;
    String title = "Month $month";

    // Query query = _ref.child(month).orderByChild('sort');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Center(
            child: Text(
          title,
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        )),
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            loadMore();
          }
        },
        child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: itemCurrentPages.length,
            itemBuilder: (context, index) {
              return (index == itemCurrentPages.length)
                  ? Container(
                      color: Colors.greenAccent,
                      child: FlatButton(
                        child: Text("Load More"),
                        onPressed: () {
                          loadMore();
                        },
                      ),
                    )
                  : _buildTaskOnMonthItem(
                      monthTaskInfo: itemCurrentPages[index],
                      month: month,
                      userId: userId);
            }),
      ),
    );
  }

  Widget _buildTaskOnMonthItem(
      {MonthTaskInfo monthTaskInfo, String month, String userId}) {
    String taskIdSub = monthTaskInfo.task_name.toString().length > 20
        ? monthTaskInfo.task_name.toString().substring(0, 20) + "..."
        : monthTaskInfo.task_name.toString();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      height: 112,
      color: Colors.white,
      child: Row(children: [
        Icon(
          Icons.assignment_outlined,
          color: kPrimaryColor,
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
                    onTap: () =>
                        _taskHistory(month, monthTaskInfo.task_id, userId),
                    style: TextStyle(
                        fontSize: 25,
                        color: kPrimaryColor,
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
                    monthTaskInfo.technician_name,
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
                    monthTaskInfo.task_date,
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
                    monthTaskInfo.task_size,
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
      ]),
    );
  }

  void _taskHistory(String month, String taskId, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskHistory(
                month: month,
                taskId: taskId,
                userId: userId,
              )),
    );
  }
}
