import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';
import 'package:flutter_qr_scan/Utils/Util.dart';
import 'package:flutter_qr_scan/components/select_time_dialog.dart';
import 'package:intl/intl.dart';

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
  String userName;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> tasks = [];
  bool isLoading = false;
  DocumentSnapshot lastTask;
  static ScrollController _scrollTaskController;
  ScrollController _scrollController = new ScrollController();
  List<Widget> dateList = [];
  DateTime now = new DateTime.now();
  DateTime dateSelected = new DateTime.now();
  final DateFormat formatterDate = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    Util.checkUser(widget.userId, context);
    _getDateOfWeeks(now);
    if (widget.userId != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      getTasks(formatter.format(now).toString());
    }
    _scrollTaskController = ScrollController();
  }

  getTasks(String day) async {
    tasks = [];
    var splitDate = day.split("-");
    var dayAfter = int.parse(splitDate[2]) + 1;

    var extTime = " 00:00:00";
    var lessThan = [
          splitDate[0],
          splitDate[1],
          dayAfter.toString().length == 1
              ? "0" + dayAfter.toString()
              : dayAfter.toString()
        ].join("-") +
        extTime;

    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    querySnapshot = await firestore
        .collection('Tasks')
        .orderBy('updated_at')
        .where('updated_at', isGreaterThan: DateTime.parse(day + extTime))
        .where('updated_at', isLessThan: DateTime.parse(lessThan))
        .get();

    querySnapshot.docs.forEach((doc) {
      if (doc.get('user_id').toString() == widget.userId) {
        tasks.add(doc);
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  _getDateOfWeeks(DateTime dateTime) {
    final random = Random();
    final date = DateTime(
      dateTime.year,
      dateTime.month,
    );
    final numDateOfMonths = Utils.lastDayOfMonth(date).day;
    final List<Widget> temp = [];
    final List<bool> historyTemp = [];
    for (var i = 1; i <= numDateOfMonths; i++) {
      final d = DateTime(dateTime.year, dateTime.month, i);
      temp.add(_buildDateColumn(
          DateFormat('E').format(d), i, i == dateTime.day ? true : false));
      historyTemp.add(random.nextBool());
    }
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollController.jumpTo((dateTime.day) * 52.0));
    setState(() {
      dateList = temp;
      dateSelected = dateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          centerTitle: true,
          title: Center(
              child: Text(
            "Personal Task",
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
        body: Column(children: <Widget>[
          Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final data = await showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    SelectTimeDialog(
                                        dateSelected: dateSelected));
                            setState(() {
                              _getDateOfWeeks(data);
                              dateSelected = data;
                              getTasks(formatterDate.format(dateSelected).toString());
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                                text: DateFormat(MONTH_NAME_FORMAT).format(
                                    new DateTime(
                                        dateSelected.year, dateSelected.month)),
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 22,
                                ),
                                children: [
                                  TextSpan(
                                    text: " ${dateSelected.year}",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                ]),
                          ),
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: () => {
                        _getDateOfWeeks(now),
                        getTasks(formatterDate.format(dateSelected).toString())
                      },
                      child: Text(
                        TO_DAY,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          // color: switchMode.getReverseTextColor,
                        ),
                      ),
                    )
                  ],
                ),
              )),
          Container(
            margin: EdgeInsets.only(top: 15, bottom: 30),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dateList,
              ),
            ),
          ),
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
                    'No Task On This Day!',
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                      controller: _scrollTaskController,
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
        ]));
  }

  Widget _buildTaskList({DocumentSnapshot task}) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    var timeList =
        formatter.format(task.get("updated_at").toDate()).toString().split(" ");
    var date = timeList[0];
    var time = timeList[1];

    return GestureDetector(
        onTap: () => _taskHistoryDetail(task.get('task_id'), widget.userId),
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
                          task.get("technicican_name") ?? '',
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

  void _taskHistoryDetail(String taskId, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskHistoryDetail(
                taskId: taskId,
                userId: userId,
              )),
    );
  }

  _choiceDate(int date) {
    for (var i = 0; i < dateList.length; i++) {
      if (i == date - 1) {
        var d = new DateTime(dateSelected.year, dateSelected.month, date);
        dateList[i] = _buildDateColumn(DateFormat('E').format(d), date, true);
      } else {
        var d = new DateTime(dateSelected.year, dateSelected.month, i + 1);
        dateList[i] = _buildDateColumn(DateFormat('E').format(d), i + 1, false);
      }
    }
    setState(() {
      dateList = dateList;
      dateSelected = new DateTime(dateSelected.year, dateSelected.month, date);
      getTasks(formatterDate.format(dateSelected).toString());
    });
  }

  GestureDetector _buildDateColumn(String weekDay, int date, bool isActive) {
    return GestureDetector(
        onTap: () => {_choiceDate(date)},
        child: Container(
          margin: EdgeInsets.only(left: 15, right: 15),
          decoration: isActive
              ? BoxDecoration(
                  color: Color(0xff402fcc),
                  borderRadius: BorderRadius.circular(10))
              : BoxDecoration(),
          height: 55,
          width: 35,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                weekDay,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.grey,
                    fontSize: 11),
              ),
              Text(
                date.toString(),
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: isActive ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ));
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
