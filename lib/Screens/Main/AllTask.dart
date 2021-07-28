import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/MessageConstants.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Main/MonthTask.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';
import 'package:flutter_qr_scan/Utils/Util.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:toast/toast.dart';

import '../../Constants/constants.dart';

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
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> months = [];
  List<DocumentSnapshot> exportTasks = [];
  bool isLoading = false;
  bool hasMore = true;
  int monthLimit = 20;
  DocumentSnapshot lastMonth;
  static ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    Util.checkUser(widget.userId, context);
    _scrollController = ScrollController();
    getMonths();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getMonths();
      }
    });
  }

  getMonths() async {
    if (!hasMore) {
      print('No More Months');
      return;
    }

    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastMonth == null) {
      querySnapshot = await firestore
          .collection('Months')
          .orderBy('updated_at')
          .limit(monthLimit)
          .get();
    } else {
      querySnapshot = await firestore
          .collection('Months')
          .orderBy('updated_at')
          .startAfterDocument(lastMonth)
          .limit(monthLimit)
          .get();
      print(1);
    }
    if (querySnapshot.docs.length == 0) {
      hasMore = false;
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (querySnapshot.docs.length < monthLimit) {
      hasMore = false;
    }
    lastMonth = querySnapshot.docs[querySnapshot.docs.length - 1];
    months.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          centerTitle: true,
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
        body: SafeArea(
            child: Column(children: [
          Expanded(
            child: months.length == 0
                ? Center(
                    child: Text('No Data...'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      return _buildMonthInfoItem(
                          month: months[index], userId: userId);
                    }),
          ),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Loading...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                )
              : Container()
        ])));
  }

  Widget _buildMonthInfoItem({DocumentSnapshot month, String userId}) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    return GestureDetector(
        onTap: () => _monthTask(month.get("name"), userId),
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 15, left: 12, right: 12),
          padding: EdgeInsets.all(10),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  offset: Offset(7, 7),
                  blurRadius: 9,
                  color: kPrimaryColor.withOpacity(0.2),
                  spreadRadius: 3),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    month.get("name"),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    month.get("tasks").toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 15),
                  ),
                ],
              ),
              Container(
                child: Column(children: getTextWidgets(8)),
                height: 100,
                // color: Colors.grey.withOpacity(0.5),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    // width: MediaQuery.of(context).size.width - 250,
                    child: Text(
                      "Time: " + month.get("name"),
                      style: TextStyle(color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.av_timer,
                        color: Colors.grey,
                        size: 20,
                      ),
                      Container(
                        // width: MediaQuery.of(context).size.width - 160,
                        child: Text(
                          "Last time: " +
                              formatter
                                  .format(month.get("updated_at").toDate())
                                  .toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.app_registration,
                        color: Colors.grey,
                        size: 20,
                      ),
                      Text(
                        "Tasks: " + month.get("tasks").toString(),
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      )
                    ],
                  ),
                ],
              ),
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
                      _showMaterialDialog(month.get("name"));
                    },
                    tooltip: "Back",
                  );
                },
              ),
            ],
          ),
        ));
  }

  List<Widget> getTextWidgets(int len) {
    List<Widget> list = [];
    for (var i = 0; i < len; i++) {
      list.add(new Container(
        height: 5,
        width: 5,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
        ),
      ));
      list.add(new SizedBox(
        height: 5,
      ));
    }
    return list;
  }

  _showMaterialDialog(String month) {
    showDialog(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: Text(EXPORT_CONFIRM),
              content: Text(EXPORT_CONTENT),
              actions: [
                TextButton(
                  onPressed: () {
                    Util.checkUser(widget.userId, context);
                    Navigator.pop(context);
                  },
                  child: Text(BUTTON_CANCEL_TEXT,
                      style: const TextStyle(color: kPrimaryColor)),
                ),
                TextButton(
                  onPressed: () {
                    Util.checkUser(widget.userId, context);
                    _exportToCsv(month);
                    Navigator.pop(context);
                  },
                  child: Text(BUTTON_ACCEPT_TEXT,
                      style: const TextStyle(color: kPrimaryColor)),
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

  Future<void> addUser() {
    CollectionReference months =
        FirebaseFirestore.instance.collection('Months');
    for (var i = 100; i >= 1; i--) {
      months
          .doc('2022-' + i.toString())
          .set({
            'name': '2022-' + i.toString(),
            'tasks': i,
            'updated_at': DateTime.now()
          })
          .then((value) => print("Month Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }
  }

  void _exportToCsv(String month) async {
    log('month: $month');
    String header =
        "Technician Name,Task ID,Task Name,Place,Lab Name,Description,Type,Work Status,Over Time,Machine Image,Signature Image,Date\n";
    List<String> csvDataList = [];
    csvDataList.add(header);
    final directory = await getExternalStorageDirectory();
    var splitMonth = month.split("-");
    var monAfter = int.parse(splitMonth[1]) + 1;

    var extTime = "-00 00:00:00";
    var lessThan = [
          splitMonth[0],
          monAfter.toString().length == 1
              ? "0" + monAfter.toString()
              : monAfter.toString()
        ].join("-") +
        extTime;

    QuerySnapshot querySnapshot;
    querySnapshot = await firestore
        .collection('Tasks')
        .where('updated_at', isGreaterThan: DateTime.parse(month + extTime))
        .where('updated_at', isLessThan: DateTime.parse(lessThan))
        .orderBy('updated_at')
        .get();
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    querySnapshot.docs.forEach((doc) {
      String date = formatter.format(doc.get(DATE_FIELD).toDate()).toString();
      String workStatus = doc.get(WORK_STATUS_FIELD);
      String technicianName = doc.get(TECHNICIAN_NAME_FIELD);
      String overTime = doc.get(OVER_TIME_FIELD);
      String description = doc.get(DESCRIPTION_FIELD);
      String labName = doc.get(LAB_NAME_FIELD);
      String place = doc.get(PLACE_FIELD);
      String type = doc.get(TYPE_FIELD);
      String taskId = doc.get(TASK_ID_FIELD);
      String taskName = doc.get(TASK_NAME_FIELD);
      String machineImage = doc.get(MACHINE_IMAGE_FIELD);
      String signatureImage = doc.get(SIGNATURE_IMAGE_FIELD);

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

    /// Write to a file
    final pathOfTheFileToWrite = directory.path + "/$month.csv";
    File file = File(pathOfTheFileToWrite);
    file.writeAsString(csvDataList.join(''));

    Toast.show("Exported to CSV failed!", context,
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
