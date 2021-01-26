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
import 'package:flutter_qr_scan/Constants/MessageConstants.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Models/TaskInfo.dart';
import 'package:flutter_qr_scan/Utils/Util.dart';
import 'package:flutter_qr_scan/components/circle_image_container.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:flutter_qr_scan/components/rounded_normal_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:toast/toast.dart';

import 'MainScreen.dart';

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
  Uint8List bytes = Uint8List(0);
  final _formKey = GlobalKey<FormState>();
  GlobalKey globalKey = new GlobalKey();
  TaskInfo taskInfo = new TaskInfo();
  final DateTime now = DateTime.now();
  final DateFormat formatterMonth = DateFormat(FORMAT_MONTH);
  final DateFormat formatterDate = DateFormat(FORMAT_DATE_TIME);
  String formattedMonth;
  String formattedDate;
  var epochTime;

  TextEditingController _taskNameController,
      _labNameController,
      _typeController,
      _descriptionController,
      _placeController,
      _workStatusController,
      _overTimeController;
  File _imageMachine, _imageSignature;
  DatabaseReference _refTasks, _refMonth, _refLastTask, _refUser, _refPersonal;
  Reference _refStorage;

  @override
  void initState() {
    super.initState();
    Util.checkUser(widget.userId, context);
    _taskNameController = TextEditingController();
    _labNameController = TextEditingController();
    _typeController = TextEditingController();
    _descriptionController = TextEditingController();
    _placeController = TextEditingController();
    _workStatusController = TextEditingController();
    _overTimeController = TextEditingController();
    _refTasks = FirebaseDatabase.instance.reference().child(TASK_FIREBASE);
    _refLastTask =
        FirebaseDatabase.instance.reference().child(LAST_TASK_FIREBASE);
    _refMonth = FirebaseDatabase.instance.reference().child(MONTH_FIREBASE);
    _refUser = FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);
    _refPersonal =
        FirebaseDatabase.instance.reference().child(PERSONAL_INFO_FIREBASE);
    _refStorage = FirebaseStorage.instance.ref();
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
              title: Text(CHOSE_IMAGE),
              content: Text(CHOSE_IMAGE_TYPE),
              actions: [
                FlatButton(
                  textColor: kPrimaryColor,
                  onPressed: () {
                    _imgFromCamera(type);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(CAMERA),
                ),
                FlatButton(
                  textColor: kPrimaryColor,
                  onPressed: () {
                    _imgFromGallery(type);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(GALLERY),
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
            if (child == IMAGE_MACHINE_FIELD) {
              _refTaskUpdate.child(MACHINE_IMAGE_FIELD).set(fileURL);
            } else {
              _refTaskUpdate.child(SIGNATURE_IMAGE_FIELD).set(fileURL);
            }
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Center(
            child: Text(
          ADD_TASK_TEXT,
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
                controller: _taskNameController,
                decoration: const InputDecoration(
                    icon: const Icon(Icons.perm_identity),
                    labelText: 'Task Name'),
                validator: (value) {
                  if (value.isEmpty) {
                    return REQUIRED_FIELD;
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
                        MACHINE_IMAGE_TEXT,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3),
                      ),
                      RoundedNormalButton(
                        text: MACHINE_IMAGE_TEXT,
                        press: () {
                          Util.checkUser(widget.userId, context);
                          _showPicker(context, typeMachine);
                        },
                      ),
                      SizedBox(height: size.height * 0.03),
                      Text(
                        SIGNATURE_IMAGE_TEXT,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3),
                      ),
                      RoundedNormalButton(
                        text: SIGNATURE_IMAGE_TEXT,
                        press: () {
                          Util.checkUser(widget.userId, context);
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
                  text: ADD_TASK_TEXT,
                  press: () {
                    Util.checkUser(widget.userId, context);
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
    String taskName = _taskNameController.text;
    String labName = _labNameController.text;
    String type = _typeController.text;
    String description = _descriptionController.text;
    String place = _placeController.text;
    String workStatus = _workStatusController.text;
    String overTime = _overTimeController.text;

    String taskId = int.parse(epochTime).toString();
    String subTaskId = taskId + DASH + int.parse(epochTime).toString();
    var sort = int.parse(epochTime) * -1;
    int monthSize = 0;
    int taskSize = 0;
    String userName;
    var childName = taskName + DASH + epochTime;
    DatabaseReference _refTaskUpdate =
        _refTasks.child(formattedMonth).child(taskId).child(subTaskId);

    _refUser.child(userId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        if (key == YOUR_NAME_FIELD) {
          userName = value;
        }
      });
    });

    Map<String, String> task = {
      TASK_ID_FIELD: subTaskId,
      TASK_NAME_FIELD: childName,
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
    _refTasks.child(formattedMonth).child(taskId).child(subTaskId).set(task);

    _refTasks
        .child(formattedMonth)
        .child(taskId)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        taskSize += 1;
      });

      Map<String, String> lastTask = {
        TASK_ID_FIELD: taskId,
        TASK_NAME_FIELD: taskName,
        LAB_NAME_FIELD: labName,
        TECHNICIAN_NAME_FIELD: userName,
        DATE_FIELD: formattedDate,
        SORT_FIELD: sort.toString(),
        TASK_SIZE_FIELD: taskSize.toString() + TASK_CONTENT,
      };

      // Added last task
      _refLastTask.child(formattedMonth).child(taskId).set(lastTask);
      _refLastTask
          .child(formattedMonth)
          .child(taskId)
          .child(SORT_FIELD)
          .set(sort);

      // Update technician name
      _refTaskUpdate.child(TECHNICIAN_NAME_FIELD).set(userName);
      _refTaskUpdate.child(SORT_FIELD).set(sort);
    });

    _refTasks.child(formattedMonth).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        monthSize += value.length;
      });
      Map<String, String> month = {
        MONTH_FIELD: formattedMonth,
        TASK_SIZE_FIELD: monthSize.toString() + TASK_CONTENT,
        SORT_FIELD: sort.toString(),
      };
      if (_imageMachine != null) {
        _uploadFile(
            subTaskId, _imageMachine, IMAGE_MACHINE_FIELD, _refTaskUpdate);
      }
      if (_imageSignature != null) {
        _uploadFile(
            subTaskId, _imageSignature, IMAGE_SIGNATURE_FIELD, _refTaskUpdate);
      }
      String personalContent = [formattedMonth, taskId, subTaskId].join(SLASH);
      Map<String, String> personalInfo = {
        PERSONAL_INFO_FIREBASE: personalContent,
      };

      _refPersonal.child(userId).child(subTaskId).set(personalInfo);

      Toast.show(ADD_CONFIRM, context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

      String inputCode =
          QR_MATCH_CODE + SLASH + formattedMonth + SLASH + taskId;

      _generateBarCode(taskId, inputCode);

      // ImageGallerySaver.saveImage(this.bytes);

      // Added month
      _refMonth.child(formattedMonth).set(month);
      _refMonth.child(formattedMonth).child(SORT_FIELD).set(sort).then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) {
            return MainScreen(
              userId: userId,
            );
          }),
        );
      });
    });
  }

  Future _generateBarCode(String taskId, String inputCode) async {
    Uint8List result = await scanner.generateBarCode(inputCode);
    final directory = await getExternalStorageDirectory(); // 1
    final pathOfTheFileToWrite = directory.path + "/$taskId.png";
    File file = File(pathOfTheFileToWrite);
    file.writeAsBytes(result);
  }
}
