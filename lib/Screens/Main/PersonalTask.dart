import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';
import 'package:flutter_qr_scan/Utils/Util.dart';

import 'TaskHistoryDetail.dart';

class PersonalTask extends StatefulWidget {
  final String title;
  final String userId;

  PersonalTask({
    Key key,
    this.title,
    this.userId,
  }) : super(key: key);

  @override
  _PersonalTaskState createState() => _PersonalTaskState();
}

class _PersonalTaskState extends State<PersonalTask> {
  DatabaseReference _ref, _refPersonal;
  String userName;
  List<String> listTaskText = [];
  List<TaskInfo> taskInfoList = [];

  int present = 0;
  int perPage = 15;
  int returnMaxNum = 0;

  List itemCurrentPages = [];

  @override
  void initState() {
    super.initState();
    Util.checkUser(widget.userId, context);
    _ref = FirebaseDatabase.instance.reference().child(TASK_FIREBASE);
    _refPersonal =
        FirebaseDatabase.instance.reference().child(PERSONAL_INFO_FIREBASE);
    if (widget.userId != null) {
      getDataPersonal(widget.userId);
    }
  }

  Future<void> getDataPersonal(String userId) async {
    await _refPersonal.child(userId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values != null) {
        values.forEach((key, value) {
          Map<dynamic, dynamic> val = value;
          val.forEach((k, v) {
            listTaskText.add(v);
          });
        });
      }
    });
    for (final lc in listTaskText) {
      var arr = lc.split(SLASH);
      await _ref
          .child(arr[0])
          .child(arr[1])
          .child(arr[2])
          .orderByChild('sort')
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        TaskInfo taskInfo = new TaskInfo();
        taskInfo.subTaskId = values[TASK_ID_FIELD];
        taskInfo.technicianName = values[TECHNICIAN_NAME_FIELD];
        taskInfo.workStatus = values[WORK_STATUS_FIELD];
        taskInfo.date = values[DATE_FIELD];
        taskInfo.month = arr[0];
        taskInfo.taskId = arr[1];
        taskInfoList.add(taskInfo);
      });
    }
    setState(() {
      taskInfoList.sort((a, b) => b.date.compareTo(a.date));
      if ((present + perPage) > taskInfoList.length) {
        itemCurrentPages
            .addAll(taskInfoList.getRange(present, taskInfoList.length));
        present = taskInfoList.length;
      } else {
        itemCurrentPages
            .addAll(taskInfoList.getRange(present, present + perPage));
        present = present + perPage;
      }
    });
  }

  void loadMore() {
    Util.checkUser(widget.userId, context);
    setState(() {
      if ((present + perPage) > taskInfoList.length) {
        itemCurrentPages
            .addAll(taskInfoList.getRange(present, taskInfoList.length));
        present = taskInfoList.length;
      } else {
        itemCurrentPages
            .addAll(taskInfoList.getRange(present, present + perPage));
        present = present + perPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Center(
            child: Text(
          "Personal Task",
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
                  Util.checkUser(widget.userId, context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ScanMain(
                              userId: userId,
                            )),
                  );
                },
                tooltip: "Back",
              );
            },
          ),
        ],
        elevation: 50.0,
        brightness: Brightness.dark,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            loadMore();
          }
        },
        child: ListView.builder(
          itemCount: itemCurrentPages.length,
          itemBuilder: (context, index) {
            final item = itemCurrentPages[index];
            return (index == itemCurrentPages.length) ?
            Container(
              color: Colors.greenAccent,
              child: FlatButton(
                child: Text("Load More"),
                onPressed: () {
                  loadMore();
                },
              ),
            ) : Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.all(10),
              height: 115,
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
                            item.subTaskId,
                            onTap: () => _taskHistoryDetail(item.month,
                                item.taskId, item.subTaskId, userId),
                            style: TextStyle(
                                fontSize: 20,
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
                            item.technicianName,
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
                            item.date,
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
                            "workStatus: ${item.workStatus}",
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
          },
        ),
      ),
    );
  }

  void _taskHistoryDetail(
      String month, String taskId, String subTaskId, String userId) {
    Util.checkUser(widget.userId, context);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskHistoryDetail(
                month: month,
                taskId: taskId,
                subTaskId: subTaskId,
                userId: userId,
              )),
    );
  }
}

class TaskInfo {
  String subTaskId;
  String workStatus;
  String date;
  String technicianName;
  String taskId;
  String month;
}
