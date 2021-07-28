import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/components/background.dart';
import 'package:flutter_qr_scan/Screens/Main/EditTask.dart';
import 'package:flutter_qr_scan/Utils/Util.dart';
import 'package:flutter_qr_scan/components/circle_image_container_firebase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import 'MainScreen.dart';

class TaskHistoryDetail extends StatefulWidget {
  final String title;
  final String taskId;
  final String userId;

  TaskHistoryDetail({Key key, this.title, this.taskId, this.userId})
      : super(key: key);

  @override
  _TaskHistoryDetailState createState() => _TaskHistoryDetailState();
}

class _TaskHistoryDetailState extends State<TaskHistoryDetail> {
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

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  static ScrollController _scrollController;
  List<DocumentSnapshot> tasks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Util.checkUser(widget.userId, context);
    epochTime = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    _scrollController = ScrollController();
    getTasks();
  }

  String defaultString(String org) {
    return org == EMPTY_STRING ? NO_DATA : org;
  }

  getTasks() async {
    QuerySnapshot querySnapshot;
    querySnapshot = await firestore
        .collection('Tasks')
        .where('task_id', isEqualTo: widget.taskId)
        .limit(1)
        .get();
    tasks.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  var div = Divider(
    height: 1,
    thickness: 1,
    indent: 1,
    endIndent: 1,
  );

  displayImage(String imageNetwork) {
    if (imageNetwork != NO_IMAGE) {
      return Image.network(imageNetwork);
    }
    return Container(child: Image.asset("assets/images/no_image.png"));
  }

  @override
  Widget build(BuildContext context) {
    String taskId = widget.taskId;
    String userId = widget.userId;
    String title = "$taskId";

    Size size = MediaQuery.of(context).size;
    final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    return Material(
      type: MaterialType.transparency,
      child: Background(
        child: Container(
            margin: EdgeInsets.only(top: 40, bottom: 25),
            child: ListView.builder(
                controller: _scrollController,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: size.height * 0.04),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              TASK_NAME_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              tasks[index].get(TASK_NAME_FIELD),
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              LAB_NAME_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              tasks[index].get(LAB_NAME_FIELD),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              TECHNICIAN_NAME_HEADER,
                              style: TextStyle(
                                fontFamily: FONT_DEFAULT,
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              tasks[index].get(TECHNICIAN_NAME_FIELD) ?? '',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              TYPE_HEADER,
                              style: TextStyle(
                                fontFamily: FONT_DEFAULT,
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              tasks[index].get(TYPE_FIELD),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              DESCRIPTION_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              tasks[index].get(DESCRIPTION_FIELD),
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              WORK_DAY_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              formatter
                                  .format(tasks[index].get(DATE_FIELD).toDate())
                                  .toString(),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              PLACE_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              tasks[index].get(PLACE_FIELD),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              WORK_STATUS_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              tasks[index].get(WORK_STATUS_FIELD),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              OVER_TIME_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: 200.0,
                            child: Text(
                              tasks[index].get(OVER_TIME_FIELD),
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              MACHINE_IMAGE_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            child: GestureDetector(
                              child: CircularImageFirebase(
                                  tasks[index].get(MACHINE_IMAGE_FIELD),
                                  200,
                                  100),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => displayImage(
                                            tasks[index]
                                                .get(MACHINE_IMAGE_FIELD))));
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      div,
                      SizedBox(height: size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: size.height * 0.05),
                          Container(
                            width: 130.0,
                            child: Text(
                              SIGNATURE_IMAGE_HEADER,
                              style: TextStyle(
                                  fontFamily: FONT_DEFAULT,
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            child: GestureDetector(
                              child: CircularImageFirebase(
                                  tasks[index].get(SIGNATURE_IMAGE_FIELD),
                                  200,
                                  100),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => displayImage(
                                            tasks[index]
                                                .get(SIGNATURE_IMAGE_FIELD))));
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.03),
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
                                                    taskId: taskId,
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
                                        _showMaterialDialog(userId, taskId);
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
                  );
                })),
      ),
    );
  }

  _showMaterialDialog(String userId, String taskId) {
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
                    deleteTask(userId, taskId);
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            ));
  }

  void deleteTask(String userId, String taskId) async {
    CollectionReference month = FirebaseFirestore.instance.collection('Months');
    QuerySnapshot querySnapshot;
    querySnapshot = await firestore
        .collection('Tasks')
        .where('task_id', isEqualTo: taskId)
        .get();

    final DateFormat formatter = DateFormat('yyyy-MM');
    DateTime now = DateTime.now();

    querySnapshot.docs.forEach((doc) {
      now = doc.get('updated_at').toDate();
      if (doc.get('machine_image') != NO_IMAGE) {
        Reference _refStorage = FirebaseStorage.instance.ref();
        _refStorage.child(IMAGE_MACHINE_FIELD).child(taskId).delete();
      }
      if (doc.get('signature_image') != NO_IMAGE) {
        Reference _refStorage = FirebaseStorage.instance.ref();
        _refStorage.child(IMAGE_SIGNATURE_FIELD).child(taskId).delete();
      }
    });

    CollectionReference task = FirebaseFirestore.instance.collection('Tasks');
    if (taskId != null) {
      task
          .doc(taskId)
          .delete();
          // .then((value) => Toast.show("Deleted task!", context,
          //     duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM))
          // .catchError((error) => Toast.show("Delete task failed!", context,
          //     duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM));
    }

    querySnapshot.docs.forEach((doc) {});
    // Update month
    month.doc(formatter.format(now)).get().then((doc) => {
          if (doc.exists)
            {
              month
                  .where('name', isEqualTo: formatter.format(now))
                  .limit(1)
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                querySnapshot.docs.forEach((doc) {
                  var taskNum = doc.get('tasks');
                  month
                      .doc(formatter.format(now))
                      .update({'tasks': taskNum - 1, 'updated_at': now});
                });
              })
            }
        });

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        MainScreen(userId: userId,)), (Route<dynamic> route) => false);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) {
    //     return MainScreen(
    //       userId: userId,
    //     );
    //   }),
    // );
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
