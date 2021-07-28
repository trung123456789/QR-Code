import 'dart:io';
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
import 'package:flutter_qr_scan/components/circle_image_container_firebase.dart';
import 'package:flutter_qr_scan/components/photo_view_page.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class EditTask extends StatefulWidget {
  final String title;
  final String userId;
  final String taskId;

  EditTask({
    Key key,
    this.title,
    this.userId,
    this.taskId,
  }) : super(key: key);

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  TaskInfo taskInfo = new TaskInfo();
  final DateTime now = DateTime.now();
  String userName;

  TextEditingController _taskNameController,
      _labNameController,
      _typeController,
      _descriptionController,
      _placeController,
      _workStatusController,
      _overTimeController;
  PickedFile _imageSignature, _imageMachine;
  String machineImage = NO_IMAGE;
  String signatureImage = NO_IMAGE;
  Reference _refStorage;
  final ImagePicker _picker = ImagePicker();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
    getUserName(widget.userId);
    getTasks();
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

  getTasks() async {
    firestore
        .collection('Tasks')
        .where('task_id', isEqualTo: widget.taskId)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _taskNameController.text = doc[TASK_NAME_FIELD];
          _labNameController.text = doc[LAB_NAME_FIELD];
          _typeController.text = doc[TYPE_FIELD];
          _descriptionController.text = doc[DESCRIPTION_FIELD];
          _placeController.text = doc[PLACE_FIELD];
          _workStatusController.text = doc[WORK_STATUS_FIELD];
          _overTimeController.text = doc[OVER_TIME_FIELD];
          machineImage = doc[MACHINE_IMAGE_FIELD];
          signatureImage = doc[SIGNATURE_IMAGE_FIELD];
        });
      });
    });
  }

  displayImage(PickedFile pickedFile, String imageNetwork) {
    if (pickedFile != null) {
      return Container(
        child: Image.file(
          File(pickedFile.path),
          fit: BoxFit.fitWidth,
        ),
      );
    }
    if (imageNetwork != NO_IMAGE) {
      return Image.network(imageNetwork);
    }
    return Container(child: Image.asset("assets/images/no_image.png"));
  }

  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    String taskId = widget.taskId;

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title: Center(
            child: Text(
          EDIT_TASK,
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        )),
        elevation: 50.0,
        brightness: Brightness.dark,
      ),
      body: Form(
          child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
        children: <Widget>[
          Text(
            taskId,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: FONT_DEFAULT,
                color: kPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          TextFormField(
            controller: _labNameController,
            decoration: const InputDecoration(
                icon: const Icon(Icons.room, color: kPrimaryColor),
                labelText: 'Lab Name'),
            onSaved: (value) {
              taskInfo.labName = value;
            },
          ),
          TextFormField(
            controller: _typeController,
            decoration: const InputDecoration(
                icon: const Icon(Icons.sort, color: kPrimaryColor),
                labelText: 'Type'),
            onSaved: (value) {
              taskInfo.type = value;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
                icon: const Icon(Icons.description, color: kPrimaryColor),
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
              icon: const Icon(Icons.place, color: kPrimaryColor),
              labelText: 'Place',
            ),
            onSaved: (value) {
              taskInfo.place = value;
            },
          ),
          TextFormField(
            controller: _workStatusController,
            decoration: const InputDecoration(
              icon: const Icon(Icons.info, color: kPrimaryColor),
              labelText: 'Work Status',
            ),
            onSaved: (value) {
              taskInfo.workStatus = value;
            },
          ),
          TextFormField(
            controller: _overTimeController,
            decoration: const InputDecoration(
              icon: const Icon(Icons.access_alarms_sharp, color: kPrimaryColor),
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
                                      builder: (context) => displayImage(
                                          _imageMachine, machineImage)))
                            },
                            child: _imageMachine != null ||
                                    machineImage == NO_IMAGE
                                ? CircularImage(_imageMachine)
                                : Container(
                                    child: CircularImageFirebase(
                                        machineImage, 300, 150),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            height: 33,
                            child: GestureDetector(
                              onTap: () => _showPicker(context, typeMachine),
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
                                      builder: (context) => displayImage(
                                          _imageSignature, signatureImage)))
                            },
                            child: _imageSignature != null ||
                                    signatureImage == NO_IMAGE
                                ? CircularImage(_imageSignature)
                                : Container(
                                    child: CircularImageFirebase(
                                        signatureImage, 300, 150),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            height: 33,
                            child: GestureDetector(
                              onTap: () => _showPicker(context, typeSignature),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: RoundedButton(
              text: BUTTON_SAVE_TEXT,
              press: () {
                saveTask(userId, taskId);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      )),
    );
  }

  Future<String> getUserName(String userId) async {
    firestore
        .collection('User')
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

  void saveTask(String userId, String taskId) {
    CollectionReference task = FirebaseFirestore.instance.collection('Tasks');
    String taskName = _taskNameController.text;
    String labName = _labNameController.text;
    String type = _typeController.text;
    String description = _descriptionController.text;
    String place = _placeController.text;
    String workStatus = _workStatusController.text;
    String overTime = _overTimeController.text;

    Map<String, Object> taskData = {
      TASK_NAME_FIELD: taskName,
      LAB_NAME_FIELD: labName,
      TECHNICIAN_NAME_FIELD: userName,
      TYPE_FIELD: type,
      DESCRIPTION_FIELD: description,
      PLACE_FIELD: place,
      WORK_STATUS_FIELD: workStatus,
      OVER_TIME_FIELD: overTime,
      DATE_FIELD: now,
      USER_ID_FIELD: widget.userId,
    };
    task.doc(taskId).update(taskData);

    if (_imageMachine != null) {
      _uploadFile(taskId, _imageMachine, IMAGE_MACHINE_FIELD);
    }
    if (_imageSignature != null) {
      _uploadFile(taskId, _imageSignature, IMAGE_SIGNATURE_FIELD);
    }
    Toast.show(EDIT_CONFIRM, context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }
}
