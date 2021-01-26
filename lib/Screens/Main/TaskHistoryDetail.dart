import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/components/background.dart';
import 'package:flutter_qr_scan/Screens/Main/EditTask.dart';
import 'package:flutter_qr_scan/components/circle_image_container_firebase.dart';
import 'package:toast/toast.dart';

import 'MainScreen.dart';

class TaskHistoryDetail extends StatefulWidget {
  final String title;
  final String month;
  final String taskId;
  final String subTaskId;
  final String userId;

  TaskHistoryDetail(
      {Key key,
      this.title,
      this.month,
      this.taskId,
      this.subTaskId,
      this.userId})
      : super(key: key);

  @override
  _TaskHistoryDetailState createState() => _TaskHistoryDetailState();
}

class _TaskHistoryDetailState extends State<TaskHistoryDetail> {
  DatabaseReference _ref;
  var epochTime;

  String taskName = EMPTY_STRING;
  String labName = EMPTY_STRING;
  String type = EMPTY_STRING;
  String description = EMPTY_STRING;
  String place = EMPTY_STRING;
  String workStatus = EMPTY_STRING;
  String overTime = EMPTY_STRING;
  String technicianName = EMPTY_STRING;
  String date = EMPTY_STRING;
  String machineImage = NO_IMAGE;
  String signatureImage = NO_IMAGE;

  @override
  void initState() {
    super.initState();

    _ref = FirebaseDatabase.instance.reference().child(TASK_FIREBASE);
    epochTime = DateTime.now().toUtc().millisecondsSinceEpoch.toString();

    _initData(widget.month, widget.taskId, widget.subTaskId);
  }

  _initData(String month, String taskId, String subTaskId) async {
    DatabaseReference query = _ref.child(month).child(taskId).child(subTaskId);

    query.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;

      setState(() {
        taskName = defaultString(values[TASK_NAME_FIELD]);
        labName = defaultString(values[LAB_NAME_FIELD]);
        type = defaultString(values[TYPE_FIELD]);
        description = defaultString(values[DESCRIPTION_FIELD]);
        place = defaultString(values[PLACE_FIELD]);
        workStatus = defaultString(values[WORK_STATUS_FIELD]);
        overTime = defaultString(values[OVER_TIME_FIELD]);
        technicianName = defaultString(values[TECHNICIAN_NAME_FIELD]);
        date = defaultString(values[DATE_FIELD]);
        machineImage = values[MACHINE_IMAGE_FIELD];
        signatureImage = values[SIGNATURE_IMAGE_FIELD];
      });
    });
  }

  String defaultString(String org) {
    return org == EMPTY_STRING ? NO_DATA : org;
  }

  @override
  Widget build(BuildContext context) {
    String month = widget.month;
    String taskId = widget.taskId;
    String subTaskId = widget.subTaskId;
    String userId = widget.userId;
    String title = "$taskName";

    Size size = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    color: Colors.pink,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: size.height * 0.03),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        TASK_NAME_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          taskName,
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        LAB_NAME_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.055),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          labName,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        TECHNICIAN_NAME_HEADER,
                        style: TextStyle(
                          fontFamily: FONT_DEFAULT,
                          color: kPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.028),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          technicianName,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        TYPE_HEADER,
                        style: TextStyle(
                          fontFamily: FONT_DEFAULT,
                          color: kPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.079),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          type,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        DESCRIPTION_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.0575),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          description,
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        WORK_DAY_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.06),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          date,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        PLACE_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.078),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          place,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        WORK_STATUS_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.0518),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          workStatus,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        OVER_TIME_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.058),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          overTime,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        MACHINE_IMAGE_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.005),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        child: CircularImageFirebase(machineImage),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return DetailScreen(machineImage);
                          }));
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        SIGNATURE_IMAGE_HEADER,
                        style: TextStyle(
                            fontFamily: FONT_DEFAULT,
                            color: kPrimaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.005),
                  Column(
                    children: <Widget>[
                      GestureDetector(
                        child: CircularImageFirebase(signatureImage),
                        onTap: () {
                          if (signatureImage != NO_IMAGE) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return DetailScreen(signatureImage);
                            }));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              userId != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: [
                            FlatButton(
                              color: kPrimaryColor,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(8.0),
                              splashColor: kPrimaryColor,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                BUTTON_CANCEL_TEXT,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            FlatButton(
                              color: kPrimaryColor,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(8.0),
                              splashColor: kPrimaryColor,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditTask(
                                            month: month,
                                            taskId: taskId,
                                            subTaskId: subTaskId,
                                            userId: userId,
                                          )),
                                );
                              },
                              child: Text(
                                BUTTON_EDIT_TEXT,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            FlatButton(
                              color: kPrimaryColor,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(8.0),
                              splashColor: kPrimaryColor,
                              onPressed: () {
                                _showMaterialDialog(
                                    userId, taskId, subTaskId, month);
                              },
                              child: Text(
                                BUTTON_DELETE_TEXT,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  : FlatButton(
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
                      splashColor: kPrimaryColor,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        BUTTON_CANCEL_TEXT,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  _showMaterialDialog(
      String userId, String taskId, String subTaskId, String month) {
    showDialog(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: Text('Delete confirm?'),
              content: Text('Do you want delete task?'),
              actions: [
                FlatButton(
                  textColor: kPrimaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('CANCEL'),
                ),
                FlatButton(
                  textColor: kPrimaryColor,
                  onPressed: () {
                    deleteTask(userId, taskId, subTaskId, month);
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ));
  }

  void deleteTask(
      String userId, String taskId, String subTaskId, String month) {
    int taskSize = 0;
    int monthSize = 0;
    DatabaseReference _refTasks =
        FirebaseDatabase.instance.reference().child(TASK_FIREBASE);
    DatabaseReference _refPersonal =
        FirebaseDatabase.instance.reference().child(PERSONAL_INFO_FIREBASE);
    DatabaseReference _refMonth =
        FirebaseDatabase.instance.reference().child(MONTH_FIREBASE);
    DatabaseReference _refLastTask =
        FirebaseDatabase.instance.reference().child(LAST_TASK_FIREBASE);

    _refTasks.child(month).child(taskId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        taskSize += 1;
      });
      // Delete task
      if (taskSize > 1) {
        _refTasks.child(month).child(taskId).child(subTaskId).remove();
      } else {
        _refTasks.child(month).child(taskId).remove();
      }
    });

    // Delete personal task
    _refPersonal.child(userId).child(subTaskId).remove();

    // Update size task
    _refTasks.child(month).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        monthSize += value.length;
      });
      _refMonth
          .child(month)
          .child(TASK_SIZE_FIELD)
          .set(monthSize.toString() + TASK_CONTENT);
      _refMonth.child(month).child(SORT_FIELD).set(int.parse(epochTime) * -1);
    });

    // Delete last task
    _refLastTask
        .child(month)
        .child(taskId)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        if (key == TASK_SIZE_FIELD) {
          int taskSize = int.parse(value.toString().split(" ")[0]);
          if (taskSize == ONE_TASK_SIZE) {
            _refLastTask.child(month).child(taskId).remove();
          } else {
            _refLastTask
                .child(month)
                .child(taskId)
                .child(TASK_SIZE_FIELD)
                .set((taskSize - 1).toString() + TASK_CONTENT);
          }
        }
      });
    });
    Toast.show("Deleted task!", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return MainScreen(
          userId: userId,
        );
      }),
    );
  }
}

class DetailScreen extends StatelessWidget {
  DetailScreen(this.imageUrl);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              imageUrl,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
