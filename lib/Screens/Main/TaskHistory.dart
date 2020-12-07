
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Main/TaskHistoryDetail.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';

class TaskHistory extends StatefulWidget {
  final String title;
  final String month;
  final String taskId;
  final String userId;
  TaskHistory({
    Key key,
    this.title,
    this.month,
    this.taskId,
    this.userId,
  }) : super(key: key);

  @override
  _TaskHistoryState createState() => _TaskHistoryState();
}

class _TaskHistoryState extends State<TaskHistory> {
  DatabaseReference _ref;
  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance
        .reference()
        .child(TASK_FIREBASE);
  }


  @override
  Widget build(BuildContext context) {
    String month = widget.month;
    String taskId = widget.taskId;
    String title = "$taskId";

    Query query = _ref.child(month).child(taskId);

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
              icon: Icon(Icons.arrow_back),
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
            return _buildTaskOnMonthItem(tasks: tasks);
          },
        ),
      ),
    );
  }

  Widget _buildTaskOnMonthItem({Map tasks}) {
    String month = widget.month;
    String taskId = widget.taskId;
    String userId = widget.userId;
    String workStatus = tasks['workStatus'];
    String taskIdSub = tasks['taskId'].toString().length > 20
        ? tasks['taskId'].toString().substring(0, 20) + "..."
        : tasks['taskId'].toString();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      height: 115,
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
                      onTap: () => _taskHistoryDetail(month, taskId, tasks['taskId'], userId),
                      style: TextStyle(
                          fontSize: 20,
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
                      tasks['date'],
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
                      "workStatus: $workStatus",
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

  void _taskHistoryDetail(String month, String taskId, String subTaskId, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskHistoryDetail(month: month, taskId: taskId, subTaskId: subTaskId, userId: userId,)),
    );
  }
}
