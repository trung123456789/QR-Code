
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/login_screen.dart';
import 'package:flutter_qr_scan/Screens/Auth/SignUp/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManage extends StatefulWidget {
  final userId;
  final String title;
  UserManage({
    Key key,
    this.title,
    this.userId,
  }) : super(key: key);

  @override
  UserManageState createState() => UserManageState();
}

class UserManageState extends State<UserManage> {
  Query _ref;
  DatabaseReference _refUserInfo =
      FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);
  bool adminAuth = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ref = FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);
    if (widget.userId != null) {
      checkAuthority(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Center(
            child: Text(
          "Users",
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        )),
        actions: <Widget>[
          adminAuth ?
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded),
            tooltip: "Add user",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            },
          ) : IconButton(
            icon: Icon(Icons.person_add_disabled_sharp),
            tooltip: "Add user",
            onPressed: () {
            },
          ),
        ],
        elevation: 50.0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.flip_camera_android_sharp ),
              onPressed: _showMaterialDialog,
              tooltip: "Back",
            );
          },
        ),
        brightness: Brightness.dark,
      ),
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: _ref,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map userInfo = snapshot.value;
            return _buildUserInfoItem(userInfo: userInfo, index: index);
          },
        ),
      ),
    );
  }

  _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: Text('Logout confirm?'),
              content: Text('Do you want logout?'),
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
                    deleteLoggedIn();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('ACCEPT'),
                ),
              ],
            ));
  }

  Widget _buildUserInfoItem({Map userInfo, int index}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      height: 70,
      color: Colors.white,
      child: Row(children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    color: kPrimaryColor,
                    size: 25,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    userInfo['yourName'],
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
                    width: 35,
                  ),
                  Text(
                    userInfo['userType'],
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
        adminAuth ?
        IconButton(
          icon: new Icon(
            Icons.do_disturb_on_rounded,
            color: Colors.pink,
            size: 30,
          ),
          highlightColor: Colors.pink,
          onPressed: () {
            _showDeleteConfirmDialog(userInfo['yourId']);
          },
        ) : new Container(),
      ]),
    );
  }

  // Remove the selected item from the list model.
  void _onClickDeleteUser(String id) {
    if (id != null) {
      FirebaseDatabase.instance
          .reference()
          .child(USER_INFO_FIREBASE)
          .child(id)
          .remove();
    }
  }


  Future<void> checkAuthority(String userId) async {
    await _refUserInfo.child(userId).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values != null && values['userType'] == ADMIN_TYPE) {
        setState(() {
          adminAuth = true;
        });
      } else {
        setState(() {
          adminAuth = false;
        });
      }
    });
  }

  _showDeleteConfirmDialog(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
          title: Text('Delete confirm?'),
          content: Text('Do you want delete user?'),
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
                _onClickDeleteUser(id);
                Navigator.pop(context);
              },
              child: Text('ACCEPT'),
            ),
          ],
        ));
  }

  Future<void> deleteLoggedIn() async {
    SharedPreferences prefrences = await SharedPreferences.getInstance();
    prefrences.remove("userId");
  }
}
