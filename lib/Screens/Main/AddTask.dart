import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:flutter_qr_scan/components/photo_view_page.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

// import 'package:qrscan/qrscan.dart' as scanner;
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
  var epochTime;

  TextEditingController _taskNameController,
      _labNameController,
      _typeController,
      _descriptionController,
      _placeController,
      _workStatusController,
      _overTimeController;

  String userName;
  Reference _refStorage;
  PickedFile _imageSignature;
  PickedFile _imageMachine;
  final ImagePicker _picker = ImagePicker();
  String taskId;
  String direc;

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

    _refStorage = FirebaseStorage.instance.ref();

    epochTime = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    taskId = int.parse(epochTime).toString();
    getUserName(widget.userId);
    direc = _getDirectory();
  }

  _imgFromCamera(int type) async {
    final pickedFile = await _picker.getImage(source: ImageSource.camera);

    setState(() {
      if (type == typeMachine) {
        _imageMachine = pickedFile;
      } else {
        _imageSignature = pickedFile;
      }
    });
  }

  _imgFromGallery(int type) async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (type == typeMachine) {
        _imageMachine = pickedFile;
      } else {
        _imageSignature = pickedFile;
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

  _uploadFile(String taskID, PickedFile _image, String child) async {
    CollectionReference task = FirebaseFirestore.instance.collection('Tasks');
    UploadTask uploadTask =
        _refStorage.child(child).child(taskID).putFile(File(_image.path));

    await uploadTask.whenComplete(() => {
          _refStorage
              .child(child)
              .child(taskID)
              .getDownloadURL()
              .then((fileURL) {
            if (child == IMAGE_MACHINE_FIELD) {
              task.doc(taskID).update({'machine_image': fileURL});
            } else {
              task.doc(taskID).update({'signature_image': fileURL});
            }
          })
        });
  }

  displayImage(PickedFile pickedFile) {
    if (pickedFile != null) {
      return Container(
        child: Image.file(
          File(pickedFile.path),
          fit: BoxFit.fitWidth,
        ),
      );
    }
    return Container(child: Image.asset("assets/images/no_image.png"));
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    Size size = MediaQuery.of(context).size;
    final bodyHeight = size.height - MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPrimaryColor.withOpacity(0.2),
                          ),
                          margin: EdgeInsets.only(left: 20),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              displayImage(_imageMachine)))
                                },
                                child: _imageMachine != null
                                    ? CircularImage(_imageMachine)
                                    : Image.asset(
                                        "assets/images/no_image.png",
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 300,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                left: 0,
                                height: 33,
                                child: GestureDetector(
                                  onTap: () =>
                                      _showPicker(context, typeMachine),
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(right: 5),
                                    height: 20,
                                    width: 30,
                                    child: Icon(
                                      Icons.photo_camera,
                                      color: kPrimaryColor,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ))),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPrimaryColor.withOpacity(0.2),
                          ),
                          margin: EdgeInsets.only(left: 20),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              displayImage(_imageSignature)))
                                },
                                child: _imageSignature != null
                                    ? CircularImage(_imageSignature)
                                    : Image.asset(
                                        "assets/images/no_image.png",
                                        fit: BoxFit.cover,
                                        height: 150,
                                        width: 300,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                left: 0,
                                height: 33,
                                child: GestureDetector(
                                  onTap: () =>
                                      _showPicker(context, typeSignature),
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.only(right: 5),
                                    height: 20,
                                    width: 30,
                                    child: Icon(
                                      Icons.photo_camera,
                                      color: kPrimaryColor,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ))),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Center(
                child: RepaintBoundary(
                  key: globalKey,
                  child: QrImage(
                    data: QR_MATCH_CODE + SLASH + taskId,
                    size: 0.3 * bodyHeight,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(direc),
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

  void getUserName(String userId) async {
    CollectionReference user = FirebaseFirestore.instance.collection('User');
    user
        .where('login_id', isEqualTo: userId)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          userName = doc.get('user_name');
        });
      });
    });
  }

  void saveTask(String userId) {
    CollectionReference task = FirebaseFirestore.instance.collection('Tasks');
    CollectionReference month = FirebaseFirestore.instance.collection('Months');
    String taskName = _taskNameController.text;
    String labName = _labNameController.text;
    String type = _typeController.text;
    String description = _descriptionController.text;
    String place = _placeController.text;
    String workStatus = _workStatusController.text;
    String overTime = _overTimeController.text;

    final DateFormat formatter = DateFormat('yyyy-MM');

    Map<String, Object> taskData = {
      TASK_ID_FIELD: taskId,
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
      USER_ID_FIELD: userId,
      DATE_FIELD: now,
    };
    task
        .doc(taskId)
        .set(taskData)
        .then((value) => print('Task Added'))
        .catchError((error) => print("Failed to add user: $error"));

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
                      .update({'tasks': taskNum + 1, 'updated_at': now});
                });
              })
            }
          else
            {
              month.doc(formatter.format(now)).set({
                'name': formatter.format(now),
                'tasks': 1,
                'updated_at': now
              })
            }
        });
    _captureAndSharePng(taskId);

    if (_imageMachine != null) {
      _uploadFile(taskId, _imageMachine, IMAGE_MACHINE_FIELD);
    }
    if (_imageSignature != null) {
      _uploadFile(taskId, _imageSignature, IMAGE_SIGNATURE_FIELD);
    }
    Toast.show(ADD_CONFIRM, context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MainScreen(
                  userId: userId,
                )),
        (Route<dynamic> route) => false);
  }

  _getDirectory() async {
    final temp = await getExternalStorageDirectory();
    return temp.path;
  }

  Future<void> _captureAndSharePng(String taskId) async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getExternalStorageDirectory();
      print(directory.path);
      final file = await new File('${directory.path}/QR-$taskId.png').create();
      await file.writeAsBytes(pngBytes);
    } catch (e) {
      print(e.toString());
    }
  }
}
