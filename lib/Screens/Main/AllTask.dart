import 'dart:developer';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/MessageConstants.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Models/AllTaskInfo.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/login_screen.dart';
import 'package:flutter_qr_scan/Screens/Main/MonthTask.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';
import 'package:flutter_qr_scan/Utils/Util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:toast/toast.dart';

class AllTask extends StatefulWidget {
  final String title;
  final String userId;

  AllTask({
    Key key,
    this.title,
    this.userId,
  }) : super(key: key);

  @override
  _AllTaskState createState() => _AllTaskState();
}

class _AllTaskState extends State<AllTask> {
  Query _ref;

  int present = 0;
  int perPage = 15;
  int returnMaxNum = 0;

  List allTasks = [];
  List itemCurrentPages = [];

  @override
  void initState() {
    super.initState();
    Util.checkUser(widget.userId, context);
    _ref = FirebaseDatabase.instance.reference().child(MONTH_FIREBASE);
    initialValue();
  }

  Future<void> initialValue() async {
    Query _refExcu = _ref.orderByChild('sort');
    await _refExcu.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        AllTaskInfo allTaskInfo = new AllTaskInfo();
        allTaskInfo.all_month = value['month'].toString();
        allTaskInfo.task_size = value['taskSize'].toString();
        allTasks.add(allTaskInfo);
      });
    });

    setState(() {
      allTasks.sort((a, b) => b.all_month.compareTo(a.all_month));
      if ((present + perPage) > allTasks.length) {
        itemCurrentPages.addAll(allTasks.getRange(present, allTasks.length));
        present = allTasks.length;
      } else {
        itemCurrentPages.addAll(allTasks.getRange(present, present + perPage));
        present = present + perPage;
      }
    });
  }

  void loadMore() {
    Util.checkUser(widget.userId, context);
    setState(() {
      if ((present + perPage) > allTasks.length) {
        itemCurrentPages.addAll(allTasks.getRange(present, allTasks.length));
        present = allTasks.length;
      } else {
        itemCurrentPages.addAll(allTasks.getRange(present, present + perPage));
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
            "All Task",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
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
                      MaterialPageRoute(
                          builder: (context) => ScanMain(
                                userId: userId,
                              )),
                    );
                  },
                );
              },
            ),
          ],
          elevation: 50.0,
          brightness: Brightness.dark,
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              loadMore();
            }
          },
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: (present <= allTasks.length)
                  ? itemCurrentPages.length + 1
                  : itemCurrentPages.length,
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
                    : _buildMonthInfoItem(
                        allTaskInfo: itemCurrentPages[index], userId: userId);
              }),
        ));
  }

  Widget _buildMonthInfoItem({AllTaskInfo allTaskInfo, String userId}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      height: 70,
      color: Colors.white,
      child: Row(children: [
        Icon(
          Icons.assignment_outlined,
          color: kPrimaryColor,
          size: 40,
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
                    allTaskInfo.all_month,
                    onTap: () => _monthTask(allTaskInfo.all_month, userId),
                    style: TextStyle(
                        fontSize: 18,
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
                    width: 10,
                  ),
                  Text(
                    allTaskInfo.task_size,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.pink,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        /*3*/
        Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.download_rounded,
                color: Colors.red[500],
                size: 40,
              ),
              onPressed: () {
                Util.checkUser(widget.userId, context);
                _showMaterialDialog(allTaskInfo.all_month);
              },
              tooltip: "Back",
            );
          },
        ),
      ]),
    );
  }

  _showMaterialDialog(String month) {
    showDialog(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: Text(EXPORT_CONFIRM),
              content: Text(EXPORT_CONTENT),
              actions: [
                FlatButton(
                  textColor: kPrimaryColor,
                  onPressed: () {
                    Util.checkUser(widget.userId, context);
                    Navigator.pop(context);
                  },
                  child: Text(BUTTON_CANCEL_TEXT),
                ),
                FlatButton(
                  textColor: kPrimaryColor,
                  onPressed: () {
                    Util.checkUser(widget.userId, context);
                    _exportToCsv(month);
                    Navigator.pop(context);
                  },
                  child: Text(BUTTON_ACCEPT_TEXT),
                ),
              ],
            ));
  }

  void _monthTask(String month, String userId) {
    Util.checkUser(userId, context);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MonthTask(
                month: month,
                userId: userId,
              )),
    );
  }

  void _exportToCsv(String month) async {
    log('month: $month');
    String header =
        "Technician Name,Task ID,Task Name,Place,Lab Name,Description,Type,Work Status,Over Time,Machine Image,Signature Image,Date\n";
    List<String> csvDataList = List<String>();
    csvDataList.add(header);
    DatabaseReference _ref =
        FirebaseDatabase.instance.reference().child(TASK_FIREBASE).child(month);
    final directory = await getExternalStorageDirectory();

    _ref.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        value.forEach((k, v) {
          String date = v[DATE_FIELD];
          String workStatus = v[WORK_STATUS_FIELD];
          String technicianName = v[TECHNICIAN_NAME_FIELD];
          String overTime = v[OVER_TIME_FIELD];
          String description = v[DESCRIPTION_FIELD];
          String labName = v[LAB_NAME_FIELD];
          String place = v[PLACE_FIELD];
          String type = v[TYPE_FIELD];
          String taskId = v[TASK_ID_FIELD];
          String taskName = v[TASK_NAME_FIELD];
          String machineImage = v[MACHINE_IMAGE_FIELD];
          String signatureImage = v[SIGNATURE_IMAGE_FIELD];

          String record = sprintf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", [
            technicianName,
            taskId,
            taskName,
            place,
            labName,
            description,
            type,
            workStatus,
            overTime,
            machineImage,
            signatureImage,
            date
          ]);
          csvDataList.add(record);
        });
      });

      /// Write to a file
      final pathOfTheFileToWrite = directory.path + "/$month.csv";
      File file = File(pathOfTheFileToWrite);
      file.writeAsString(csvDataList.join(''));
    });
    Toast.show("Exported to CSV!", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  void _updateBKData(String month) async {
    log('month: $month');
    DatabaseReference _ref =
        FirebaseDatabase.instance.reference().child(TASK_FIREBASE).child(month);
    DatabaseReference _refLastTask = FirebaseDatabase.instance
        .reference()
        .child(LAST_TASK_FIREBASE)
        .child(month);

    _ref.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        String taskIdTemp = key;
        value.forEach((k, v) {
          String subTaskId = k;
          // _ref
          //     .child(taskIdTemp)
          //     .child(subTaskId)
          //     .child(TASK_NAME_FIELD)
          //     .set(v['taskId']);

          Map<String, String> lastTask = {
            TASK_ID_FIELD: taskIdTemp,
            TASK_NAME_FIELD: v['taskName'],
            LAB_NAME_FIELD: v['labName'],
            TECHNICIAN_NAME_FIELD: v['technicianName'],
            DATE_FIELD: v['date'],
            SORT_FIELD: v['sort'].toString(),
            TASK_SIZE_FIELD: "1 tasks",
          };
          _refLastTask.child(taskIdTemp).set(lastTask);
        });
      });
    });
  }
}
