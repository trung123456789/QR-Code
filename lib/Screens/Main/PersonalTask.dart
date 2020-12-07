import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/QrScan/ScanMain.dart';

class PersonalTask extends StatefulWidget {
  final String title;
  final String userId;

  PersonalTask({
    Key key,
    this.title,
    this.userId,

  }) : super(key: key);

  @override
  _PersonalTaskState createState() => _PersonalTaskState();
}

class _PersonalTaskState extends State<PersonalTask> {

  Query _ref;

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance
        .reference()
        .child(MONTH_FIREBASE)
        .orderByChild('sort');
  }


  @override
  Widget build(BuildContext context) {
    String userId = widget.userId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(child: Text("Personal Task",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.white),)),
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
            return _buildContactItem(monthTask: monthTask);
          },
        ),
      ),
    );
  }

  Widget _buildContactItem({Map monthTask}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      height: 70,
      color: Colors.white,
      child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 25,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        monthTask['month'],
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
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
                        width: 35,
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
            Icon(
              Icons.download_rounded,
              color: Colors.red[500],
              size: 40,
            ),
          ]
      ),
    );
  }
}