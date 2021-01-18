import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Models/TaskInfo.dart';
import 'package:flutter_qr_scan/components/circle_image_container.dart';
import 'package:flutter_qr_scan/components/circle_image_container_firebase.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:flutter_qr_scan/components/rounded_normal_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class EditTask extends StatefulWidget {
  final String title;
  final String userId;
  final String month;
  final String taskId;
  final String subTaskId;

  EditTask({
    Key key,
    this.title,
    this.userId,
    this.month,
    this.taskId,
    this.subTaskId,
  }) : super(key: key);

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  Uint8List bytes = Uint8List(0);
  final _formKey = GlobalKey<FormState>();
  GlobalKey globalKey = new GlobalKey();
  TaskInfo taskInfo = new TaskInfo();
  final DateTime now = DateTime.now();
  final DateFormat formatterMonth = DateFormat('yyyy-MM');
  final DateFormat formatterDate = DateFormat('yyyy-MM-dd hh:mm:ss');
  String formattedMonth;
  String formattedDate;
  var epochTime;
  String userName;

  TextEditingController _taskNameController,
      _labNameController,
      _typeController,
      _descriptionController,
      _placeController,
      _workStatusController,
      _overTimeController;
  File _imageMachine, _imageSignature;
  String machineImage = NO_IMAGE;
  String signatureImage = NO_IMAGE;
  DatabaseReference _refTasks, _refUser;
  Reference _refStorage;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _labNameController = TextEditingController();
    _typeController = TextEditingController();
    _descriptionController = TextEditingController();
    _placeController = TextEditingController();
    _workStatusController = TextEditingController();
    _overTimeController = TextEditingController();
    _refTasks = FirebaseDatabase.instance.reference().child(TASK_FIREBASE);
    _refUser = FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);
    _refStorage = FirebaseStorage.instance.ref();
    formattedMonth = formatterMonth.format(now);
    formattedDate = formatterDate.format(now);
    epochTime = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    initialValue(widget.month, widget.taskId, widget.subTaskId);
    getUserName(widget.userId);
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
                  textColor: kPrimaryColor,
                  onPressed: () {
                    _imgFromCamera(type);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text('Camera'),
                ),
                FlatButton(
                  textColor: kPrimaryColor,
                  onPressed: () {
                    _imgFromGallery(type);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text('Gallery'),
                ),
              ],
            ));
  }

  _uploadFile(String taskID, File _image, String child,
      DatabaseReference _refTaskUpdate) async {
    UploadTask uploadTask =
        _refStorage.child(child).child(taskID).putFile(_image);

    await uploadTask.whenComplete(() => {
          _refStorage
              .child(child)
              .child(taskID)
              .getDownloadURL()
              .then((fileURL) {
            log("Uploaded to Storage!");
            if (child == IMAGE_MACHINE_FIELD) {
              _refTaskUpdate.child('machineImage').set(fileURL);
            } else {
              _refTaskUpdate.child('signatureImage').set(fileURL);
            }
          })
        });
  }

  Future<void> initialValue(
      String month, String taskId, String subTaskId) async {
    await _refTasks
        .child(month)
        .child(taskId)
        .child(subTaskId)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      setState(() {
        _taskNameController.text = values['taskName'];
        _labNameController.text = values['labName'];
        _typeController.text = values['type'];
        _descriptionController.text = values['description'];
        _placeController.text = values['place'];
        _workStatusController.text = values['workStatus'];
        _overTimeController.text = values['overTime'];
        machineImage = values['machineImage'];
        signatureImage = values['signatureImage'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    String month = widget.month;
    String taskId = widget.taskId;
    String subTaskId = widget.subTaskId;

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Center(
            child: Text(
          "Edit Task",
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        )),
        elevation: 50.0,
        brightness: Brightness.dark,
      ),
      body: Form(
          key: _formKey,
          child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            children: <Widget>[
              TextFormField(
                enabled: false,
                controller: _taskNameController,
                decoration: const InputDecoration(
                    icon: const Icon(Icons.perm_identity),
                    labelText: 'Task Name'),
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
                            color: kPrimaryColor,
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
                            color: kPrimaryColor,
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
                      (_imageMachine != null || machineImage == NO_IMAGE)
                          ? CircularImage(_imageMachine)
                          : Container(
                              width: 200.0,
                              child: CircularImageFirebase(machineImage),
                            ),
                      SizedBox(height: size.height * 0.03),
                      (_imageSignature != null || signatureImage == NO_IMAGE)
                          ? CircularImage(_imageSignature)
                          : Container(
                              width: 200.0,
                              child: CircularImageFirebase(signatureImage),
                            ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: RoundedButton(
                  text: "Save",
                  press: () {
                    if (_formKey.currentState.validate()) {
                      saveTask(userId, taskId, subTaskId, month);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }

  Future<String> getUserName(String userId) async {
    await _refUser.child(userId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        if (key == "yourName") {
          setState(() {
            userName = value;
          });
        }
      });
    });
  }

  void saveTask(String userId, String taskId, String subTaskId, String month) {
    String taskName = _taskNameController.text;
    String labName = _labNameController.text;
    String type = _typeController.text;
    String description = _descriptionController.text;
    String place = _placeController.text;
    String workStatus = _workStatusController.text;
    String overTime = _overTimeController.text;

    var sort = int.parse(epochTime) * -1;

    DatabaseReference _refTaskUpdate =
        _refTasks.child(month).child(taskId).child(subTaskId);
    DatabaseReference _refMonth =
        FirebaseDatabase.instance.reference().child(MONTH_FIREBASE);
    DatabaseReference _refLastTask =
        FirebaseDatabase.instance.reference().child(LAST_TASK_FIREBASE);

    Map<String, String> task = {
      TASK_ID_FIELD: subTaskId,
      TASK_NAME_FIELD: taskName,
      LAB_NAME_FIELD: labName,
      TECHNICIAN_NAME_FIELD: userName,
      TYPE_FIELD: type,
      DESCRIPTION_FIELD: description,
      PLACE_FIELD: place,
      WORK_STATUS_FIELD: workStatus,
      OVER_TIME_FIELD: overTime,
      MACHINE_IMAGE_FIELD: NO_IMAGE,
      SIGNATURE_IMAGE_FIELD: NO_IMAGE,
      DATE_FIELD: formattedDate,
      SORT_FIELD: sort.toString(),
    };

    // Added task
    _refTaskUpdate.set(task);
    _refTaskUpdate.child(SORT_FIELD).set(sort);
    _refMonth.child(formattedMonth).child(SORT_FIELD).set(sort);
    _refLastTask
        .child(formattedMonth)
        .child(taskId)
        .child(SORT_FIELD)
        .set(sort);

    if (_imageMachine != null) {
      _uploadFile(
          subTaskId, _imageMachine, IMAGE_MACHINE_FIELD, _refTaskUpdate);
    } else {
      _refTaskUpdate.child(MACHINE_IMAGE_FIELD).set(machineImage);
    }
    if (_imageSignature != null) {
      _uploadFile(
          subTaskId, _imageSignature, IMAGE_SIGNATURE_FIELD, _refTaskUpdate);
    } else {
      _refTaskUpdate.child(SIGNATURE_IMAGE_FIELD).set(signatureImage);
    }
    Toast.show("Edited task!", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }
}
