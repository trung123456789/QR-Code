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

  TextEditingController _taskIdController,
      _labNameController,
      _typeController,
      _descriptionController,
      _placeController,
      _workStatusController,
      _overTimeController;
  File _imageMachine, _imageSignature;
  DatabaseReference _refTasks, _refUser;
  Reference _refStorage;

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
    _refTasks = FirebaseDatabase.instance.reference().child(TASK_FIREBASE);
    _refUser = FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);
    _refStorage = FirebaseStorage.instance.ref();
    formattedMonth = formatterMonth.format(now);
    formattedDate = formatterDate.format(now);
    epochTime = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    initialValue(widget.month, widget.taskId, widget.subTaskId);
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

  Future<void> initialValue(String month, String taskId, String subTaskId) async {
    await _refTasks.child(month).child(taskId).child(subTaskId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
        setState(() {
          _taskIdController.text = values['taskId'];
          _labNameController.text = values['labName'];
          _typeController.text = values['type'];
          _descriptionController.text = values['description'];
          _placeController.text = values['place'];
          _workStatusController.text = values['workStatus'];
          _overTimeController.text = values['overTime'];
        });
    });
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
                            color: Colors.deepPurple,
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
                            color: Colors.deepPurple,
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
                  text: "Save",
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

    var sort = int.parse(epochTime) * -1;

    String userName;
    var childId = taskId + "-" + epochTime;
    DatabaseReference _refTaskUpdate =
        _refTasks.child(formattedMonth).child(taskId).child(childId);

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
      'machineImage': "No Image",
      'signatureImage': "No Image",
      'date': formattedDate,
      'sort': sort.toString(),
    };

    // Added task
    _refTasks.child(formattedMonth).child(taskId).child(childId).set(task);

      if (_imageMachine != null) {
        _uploadFile(
            childId, _imageMachine, IMAGE_MACHINE_FIELD, _refTaskUpdate);
      }
      if (_imageSignature != null) {
        _uploadFile(
            childId, _imageSignature, IMAGE_SIGNATURE_FIELD, _refTaskUpdate);
      }
      Toast.show("Edited task!", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }
}