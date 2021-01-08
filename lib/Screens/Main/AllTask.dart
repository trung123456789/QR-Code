import 'dart:developer';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Main/MonthTask.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:toast/toast.dart';

class AllTask extends StatefulWidget {
  final String title;
  final String userId;

  AllTask({
    Key key,
    this.title,
    this.userId,
  }) : super(key: key);

  @override
  _AllTaskState createState() => _AllTaskState();
}

class _AllTaskState extends State<AllTask> {

  Query _ref;

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance
        .reference()
        .child(MONTH_FIREBASE)
        .orderByChild("sort");
  }


  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Center(child: Text("All Task",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.white),)),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.qr_code,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScanMain(userId: userId,)),
                  );
                },
              );
            },
          ),
        ],
        elevation: 50.0,
        brightness: Brightness.dark,
      ),
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: _ref,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map monthTask = snapshot.value;
            return _buildMonthInfoItem(monthTask: monthTask, userId: userId);
          },
        ),
      ),
    );
  }

  Widget _buildMonthInfoItem({Map monthTask, String userId}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      height: 70,
      color: Colors.white,
      child: Row(
        children: [
          Icon(
            Icons.assignment_outlined,
            color: kPrimaryColor,
            size: 40,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    SelectableText(
                      monthTask['month'],
                      onTap: () => _monthTask(monthTask['month'], userId),
                      style: TextStyle(
                          fontSize: 18,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      monthTask['taskSize'],
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.pink,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          /*3*/
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.download_rounded,
                  color: Colors.red[500],
                  size: 40,
                ),
                onPressed: () {
                  _showMaterialDialog(monthTask['month']);
                },
                tooltip: "Back",
              );
            },
          ),
        ]
      ),
    );
  }

  _showMaterialDialog(String month) {
    showDialog(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
          title: Text('Export confirm?'),
          content: Text('Do you want export data?'),
          actions: [
            FlatButton(
              textColor: Color(0xFF6200EE),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('CANCEL'),
            ),
            FlatButton(
              textColor: Color(0xFF6200EE),
              onPressed: () {
                _exportToCsv(month);
                Navigator.pop(context);

              },
              child: Text('ACCEPT'),
            ),
          ],
        ));
  }

  void _monthTask(String month, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MonthTask(month: month,userId: userId,)),
    );
  }

  void _exportToCsv(String month) async {
    log('month: $month');
    String header = "Technician Name,Task ID,Place,Lab Name,Description,Type,Work Status,Over Time,Date\n";
    List<String> csvDataList = List<String>();
    csvDataList.add(header);
    DatabaseReference _ref = FirebaseDatabase.instance.reference().child(TASK_FIREBASE).child(month);
    final directory = await getExternalStorageDirectory();

    _ref.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        value.forEach((k, v) {
          String date = v['date'];
          String workStatus = v['workStatus'];
          String technicianName = v['technicianName'];
          String overTime = v['overTime'];
          String description = v['description'];
          String labName = v['labName'];
          String place = v['place'];
          String type = v['type'];
          String taskId = v['taskId'];

          String record = sprintf("%s,%s,%s,%s,%s,%s,%s,%s,%s\n", [technicianName, taskId, place, labName, description, type, workStatus, overTime, date]);
          csvDataList.add(record);
        });
      });
      /// Write to a file
      final pathOfTheFileToWrite = directory.path + "/$month.csv";
      File file = File(pathOfTheFileToWrite);
      file.writeAsString(csvDataList.join(''));
    });
    Toast.show("Exported to CSV!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
  }
}
