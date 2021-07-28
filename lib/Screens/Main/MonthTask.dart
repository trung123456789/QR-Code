import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';
import 'package:intl/intl.dart';

import 'TaskHistoryDetail.dart';

class MonthTask extends StatefulWidget {
  final String title;
  final String month;
  final String userId;

  MonthTask({Key key, this.title, this.month, this.userId}) : super(key: key);

  @override
  _MonthTaskState createState() => _MonthTaskState();
}

class _MonthTaskState extends State<MonthTask> {
  int present = 0;
  int perPage = 15;
  int returnMaxNum = 0;

  List monthTasks = [];
  List itemCurrentPages = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> tasks = [];
  bool isLoading = false;
  bool hasMore = true;
  int taskLimit = 20;
  DocumentSnapshot lastTask;
  static ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    getTasks();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getTasks();
      }
    });
  }

  getTasks() async {
    var splitMonth = widget.month.split("-");
    var monAfter = int.parse(splitMonth[1]) + 1;

    var extTime = "-00 00:00:00";
    var lessThan = [
          splitMonth[0],
          monAfter.toString().length == 1
              ? "0" + monAfter.toString()
              : monAfter.toString()
        ].join("-") +
        extTime;

    if (!hasMore) {
      print('No More Tasks');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastTask == null) {
      querySnapshot = await firestore
          .collection('Tasks')
          .orderBy('updated_at')
          .where('updated_at',
              isGreaterThan: DateTime.parse(widget.month + extTime))
          .where('updated_at', isLessThan: DateTime.parse(lessThan))
          .limit(taskLimit)
          .get();
    } else {
      querySnapshot = await firestore
          .collection('Tasks')
          .orderBy('updated_at')
          .where('updated_at',
              isGreaterThan: DateTime.parse(widget.month + extTime))
          .where('updated_at', isLessThan: DateTime.parse(lessThan))
          .startAfterDocument(lastTask)
          .limit(taskLimit)
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
    if (querySnapshot.docs.length < taskLimit) {
      hasMore = false;
    }

    lastTask = querySnapshot.docs[querySnapshot.docs.length - 1];
    tasks.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String month = widget.month;
    String title = "$month";

    // Query query = _ref.child(month).orderByChild('sort');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          centerTitle: true,
          title: Center(
              child: Text(
            title,
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
        body: SafeArea(
            child: Column(children: [
          tasks.length == 0
              ? Container(
                  alignment: Alignment.center,
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey[300]),
                      borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No task is displayed!',
                    style: TextStyle(
                        // color: switchMode.getReverseTextColor
                        ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskList(task: tasks[index]);
                      })),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Loading...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: kPrimaryColor),
                  ),
                )
              : Container()
        ])));
  }

  Widget _buildTaskList({DocumentSnapshot task}) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    var timeList =
        formatter.format(task.get("updated_at").toDate()).toString().split(" ");
    var date = timeList[0];
    var time = timeList[1];

    return GestureDetector(
        onTap: () => _taskHistoryDetail(
            widget.month, task.get('task_id'), widget.userId),
        child: Container(
          margin: EdgeInsets.only(top: 20, bottom: 25),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 15,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(5),
                        )),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                              text: date,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: " " + time,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                )
                              ]),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey[300]),
                    borderRadius: BorderRadius.circular(20)),
                margin: EdgeInsets.only(right: 10, left: 30),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Task ID: ",
                          style: TextStyle(
                            color: Colors.black54,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          task.get("task_id"),
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black45,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_pin,
                          color: Colors.grey,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Owner: ",
                          style: TextStyle(
                            color: Colors.black87,
                            decoration: TextDecoration.none,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          task.get("technicican_name"),
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Place: ",
                          style: TextStyle(
                            color: Colors.black87,
                            decoration: TextDecoration.none,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Flexible(
                            child: new Container(
                          padding: new EdgeInsets.only(right: 13.0),
                          child: Text(
                            task.get("place"),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void _taskHistoryDetail(String month, String taskId, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskHistoryDetail(
                taskId: taskId,
                userId: userId,
              )),
    );
  }
}
