import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Models/TaskInfo.dart';
import 'package:flutter_qr_scan/Screens/Main/AllTask.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/components/circle_image_container.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:flutter_qr_scan/components/rounded_normal_button.dart';

class AddTask extends StatefulWidget {
  final String title;
  String userId;
  AddTask({
    Key key,
    this.title,
    this.userId,
  }) : super(key: key);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  TaskInfo taskInfo = new TaskInfo();
  final DateTime now = DateTime.now();
  final DateFormat formatterMonth = DateFormat('yyyy-MM');
  final DateFormat formatterDate = DateFormat('yyyy-MM-dd hh:mm:ss');
  String formattedMonth;
  String formattedDate;
  var epochTime;

  TextEditingController _taskIdController,
      _labNameController,
      _typeController,
      _descriptionController,
      _placeController,
      _workStatusController,
      _overTimeController,
      _machineImageController,
      _signatureImageController;
  File _imageMachine, _imageSignature;
  DatabaseReference _refTasks, _refMonth, _refLastTask, _refUser;

  @override
  void initState() {
    super.initState();
    _taskIdController = TextEditingController();
    _labNameController = TextEditingController();
    _typeController = TextEditingController();
    _descriptionController = TextEditingController();
    _placeController = TextEditingController();
    _workStatusController = TextEditingController();
    _overTimeController = TextEditingController();
    _machineImageController = TextEditingController();
    _signatureImageController = TextEditingController();
    _refTasks = FirebaseDatabase.instance.reference().child(TASK_FIREBASE);
    _refLastTask =
        FirebaseDatabase.instance.reference().child(LAST_TASK_FIREBASE);
    _refMonth = FirebaseDatabase.instance.reference().child(MONTH_FIREBASE);
    _refUser = FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);
    formattedMonth = formatterMonth.format(now);
    formattedDate = formatterDate.format(now);
    epochTime = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
  }

  _imgFromCamera(int type) async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      if (type == typeMachine) {
        _imageMachine = image;
      } else {
        _imageSignature = image;
      }
    });
  }

  _imgFromGallery(int type) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (type == typeMachine) {
        _imageMachine = image;
      } else {
        _imageSignature = image;
      }
    });
  }

  void _showPicker(context, type) {
    showDialog(
        context: context,
        builder: (BuildContext bc) => new AlertDialog(
              title: Text('Chose image'),
              content: Text('Chose image from?'),
              actions: [
                FlatButton(
                  textColor: Color(0xFF6200EE),
                  onPressed: () {
                    _imgFromCamera(type);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text('Camera'),
                ),
                FlatButton(
                  textColor: Color(0xFF6200EE),
                  onPressed: () {
                    _imgFromGallery(type);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text('Gallery'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(
            child: Text(
          "Add Task",
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        )),
        elevation: 50.0,
        brightness: Brightness.dark,
      ),
      body: Form(
              key: _formKey,
              child: new ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                children: <Widget>[
                  TextFormField(
                    controller: _taskIdController,
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.perm_identity),
                        labelText: 'Task ID'),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Required field! Please enter information';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _labNameController,
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.room), labelText: 'Lab Name'),
                    onSaved: (value) {
                      taskInfo.labName = value;
                    },
                  ),
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.sort), labelText: 'Type'),
                    onSaved: (value) {
                      taskInfo.type = value;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.description),
                        labelText: 'Description'),
                    minLines: 3,
                    //Normal textInputField will be displayed
                    maxLines: 5,
                    onSaved: (value) {
                      taskInfo.description = value;
                    },
                  ),
                  TextFormField(
                    controller: _placeController,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.place),
                      labelText: 'Place',
                    ),
                    onSaved: (value) {
                      taskInfo.place = value;
                    },
                  ),
                  TextFormField(
                    controller: _workStatusController,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.info),
                      labelText: 'Work Status',
                    ),
                    onSaved: (value) {
                      taskInfo.workStatus = value;
                    },
                  ),
                  TextFormField(
                    controller: _overTimeController,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.access_alarms_sharp),
                      labelText: 'OT',
                    ),
                    onSaved: (value) {
                      taskInfo.overTime = value;
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "MACHINE IMAGE",
                            style: TextStyle(
                                color: Color(0xffff0863),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.3),
                          ),
                          RoundedNormalButton(
                            text: "MACHINE IMAGE",
                            press: () {
                              _showPicker(context, typeMachine);
                            },
                          ),
                          SizedBox(height: size.height * 0.03),
                          Text(
                            "SIGNATURE IMAGE",
                            style: TextStyle(
                                color: Color(0xffff0863),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.3),
                          ),
                          RoundedNormalButton(
                            text: "SIGNATURE IMAGE",
                            press: () {
                              _showPicker(context, typeSignature);
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircularImage(_imageMachine),
                          SizedBox(height: size.height * 0.03),
                          CircularImage(_imageSignature),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: RoundedButton(
                      text: "Add Task",
                      press: () {
                        if (_formKey.currentState.validate()) {
                          saveTask(userId);
                        }
                      },
                    ),
                  ),
                ],
              )),
    );
  }

  void saveTask(String userId) {
    String taskId = _taskIdController.text;
    String labName = _labNameController.text;
    String type = _typeController.text;
    String description = _descriptionController.text;
    String place = _placeController.text;
    String workStatus = _workStatusController.text;
    String overTime = _overTimeController.text;
    String machineImage;
    String signatureImage;

    var sort = int.parse(epochTime) * -1;
    int monthSize = 0;
    int taskSize = 0;
    String userName;
    var childId = taskId + "-" + epochTime;

    _refUser.child(userId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        if (key == "yourName") {
          userName = value;
        }
      });
    });

    Map<String, String> task = {
      'taskId': childId,
      'labName': labName,
      'technicianName': userName,
      'type': type,
      'description': description,
      'place': place,
      'workStatus': workStatus,
      'overTime': overTime,
      'machineImage': machineImage,
      'signatureImage': signatureImage,
      'date': formattedDate,
      'sort': sort.toString(),
    };

    // Added task
    _refTasks.child(formattedMonth).child(taskId).child(childId).set(task);

    _refTasks.child(formattedMonth).child(taskId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        taskSize += 1;
      });

      Map<String, String> lastTask = {
        'taskId': taskId,
        'labName': labName,
        'technicianName': userName,
        'date': formattedDate,
        'sort': sort.toString(),
        'taskSize': taskSize.toString() + TASK_CONTENT,
      };

      // Added last task
      _refLastTask.child(formattedMonth).child(taskId).set(lastTask);

      // Update technician name
      _refTasks.child(formattedMonth).child(taskId).child(childId).child('technicianName').set(userName);
    });

    _refTasks.child(formattedMonth).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        monthSize += value.length;
      });
      Map<String, String> month = {
        'month': formattedMonth,
        'taskSize': monthSize.toString() + TASK_CONTENT,
        'sort': sort.toString(),
      };

      // Added month
      _refMonth.child(formattedMonth).set(month).then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            return AllTask();
          }),
        );
      });
    });
  }
}
