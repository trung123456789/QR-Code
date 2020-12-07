import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/components/background.dart';
import 'package:flutter_qr_scan/Screens/Main/EditTask.dart';
import 'package:flutter_qr_scan/components/circle_image_container_firebase.dart';

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

  String labName = "";
  String type = "";
  String description = "";
  String place = "";
  String workStatus = "";
  String overTime = "";
  String technicianName = "";
  String date = "";
  String machineImage = "No Image";
  String signatureImage = "No Image";

  @override
  void initState() {
    super.initState();

    _ref = FirebaseDatabase.instance.reference().child(TASK_FIREBASE);
  }

  _initData(String month, String taskId, String subTaskId) async {
    DatabaseReference query = _ref.child(month).child(taskId).child(subTaskId);

    query.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;

      setState(() {
        labName = defaultString(values['labName']);
        type = defaultString(values['type']);
        description = defaultString(values['description']);
        place = defaultString(values['place']);
        workStatus = defaultString(values['workStatus']);
        overTime = defaultString(values['overTime']);
        technicianName = defaultString(values['technicianName']);
        date = defaultString(values['date']);
        machineImage = values['machineImage'];
        signatureImage = values['signatureImage'];
      });
    });
  }

  String defaultString(String org) {
    return org == "" ? 'No Data' : org;
  }

  @override
  Widget build(BuildContext context) {
    String month = widget.month;
    String taskId = widget.taskId;
    String subTaskId = widget.subTaskId;
    String userId = widget.userId;
    String title = "$subTaskId";
    _initData(month, taskId, subTaskId);

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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Task ID:                  ",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          subTaskId,
                          style: TextStyle(
                              color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Lab Name:            ",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          labName,
                          style: TextStyle(
                            color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Technician Name:",
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          color: Colors.deepPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          technicianName,
                          style: TextStyle(
                            color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Type:                      ",
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          color: Colors.deepPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          type,
                          style: TextStyle(
                            color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Description:          ",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          description,
                          style: TextStyle(
                              color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Work Day:             ",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          date,
                          style: TextStyle(
                            color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Place:                  ",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          place,
                          style: TextStyle(
                            color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Work Status:      ",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          workStatus,
                          style: TextStyle(
                            color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Over Time:          ",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: Text(
                          overTime,
                          style: TextStyle(
                            color: Colors.deepPurple,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Machine Image: ",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: CircularImageFirebase(machineImage),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Signature Image:",
                        style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Colors.deepPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        child: CircularImageFirebase(signatureImage),
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
                              color: Color(0xFF6200EE),
                              textColor: Colors.white,
                              padding: EdgeInsets.all(8.0),
                              splashColor: Color(0xFF6200EE),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            FlatButton(
                              color: Color(0xFF6200EE),
                              textColor: Colors.white,
                              padding: EdgeInsets.all(8.0),
                              splashColor: Color(0xFF6200EE),
                              onPressed: () {
                                EditTask(userId: userId,);
                              },
                              child: Text(
                                "Edit",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  : FlatButton(
                      color: Color(0xFF6200EE),
                      textColor: Colors.white,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Color(0xFF6200EE),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
