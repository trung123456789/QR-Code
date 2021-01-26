import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/MessageConstants.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Models/UserInfo.dart';
import 'package:flutter_qr_scan/Screens/Auth/Login/login_screen.dart';
import 'package:flutter_qr_scan/Screens/Auth/SignUp/signup_screen.dart';
import 'package:flutter_qr_scan/Utils/Util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

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

  int present = 0;
  int perPage = 15;
  int returnMaxNum = 0;

  List allUsers = [];
  List itemCurrentPages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Util.checkUser(widget.userId, context);
    _ref = FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);
    if (widget.userId != null) {
      checkAuthority(widget.userId);
    }
    initialValue();
  }

  Future<void> initialValue() async {
    Query _refExcu = _ref.orderByChild(SORT_FIELD);
    await _refExcu.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, value) {
        UserInfo userInfo = new UserInfo();
        userInfo.user_type = value[USER_TYPE].toString();
        userInfo.your_id = value[YOUR_ID].toString();
        userInfo.your_name = value[YOUR_NAME].toString();
        userInfo.your_password = value[YOUR_PASSWORD].toString();
        userInfo.your_phone = value[YOUR_PHONE].toString();
        allUsers.add(userInfo);
      });
    });

    setState(() {
      allUsers.sort((a, b) => b.your_name.compareTo(a.your_name));
      if ((present + perPage) > allUsers.length) {
        itemCurrentPages.addAll(allUsers.getRange(present, allUsers.length));
        present = allUsers.length;
      } else {
        itemCurrentPages.addAll(allUsers.getRange(present, present + perPage));
        present = present + perPage;
      }
    });
  }

  void loadMore() {
    setState(() {
      if ((present + perPage) > allUsers.length) {
        itemCurrentPages.addAll(allUsers.getRange(present, allUsers.length));
        present = allUsers.length;
      } else {
        itemCurrentPages.addAll(allUsers.getRange(present, present + perPage));
        present = present + perPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Center(
              child: Text(
            USER_TEXT,
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          )),
          actions: <Widget>[
            adminAuth
                ? IconButton(
                    icon: Icon(Icons.person_add_alt_1_rounded),
                    tooltip: ADD_USER_TOOLTIP,
                    onPressed: () {
                      Util.checkUser(widget.userId, context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.person_add_disabled_sharp),
                    tooltip: ADD_USER_TOOLTIP,
                    onPressed: () {},
                  ),
          ],
          elevation: 50.0,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.flip_camera_android_sharp),
                onPressed: _showMaterialDialog,
                tooltip: BUTTON_BACK_TEXT,
              );
            },
          ),
          brightness: Brightness.dark,
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              loadMore();
            }
          },
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: (present <= allUsers.length)
                  ? itemCurrentPages.length + 1
                  : itemCurrentPages.length,
              itemBuilder: (context, index) {
                return (index == itemCurrentPages.length)
                    ? Container(
                        color: Colors.greenAccent,
                        child: FlatButton(
                          child: Text(LOAD_MORE),
                          onPressed: () {
                            loadMore();
                          },
                        ),
                      )
                    : _buildUserInfoItem(
                        userInfo: itemCurrentPages[index],
                      );
              }),
        ));
  }

  _showMaterialDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: Text(LOGIN_CONFIRM),
              content: Text(LOGIN_CONTENT),
              actions: [
                FlatButton(
                  textColor: kPrimaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(BUTTON_CANCEL_TEXT),
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
                  child: Text(BUTTON_ACCEPT_TEXT),
                ),
              ],
            ));
  }

  Widget _buildUserInfoItem({UserInfo userInfo}) {
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
                    userInfo.your_name,
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
                    userInfo.user_type,
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
        adminAuth
            ? IconButton(
                icon: new Icon(
                  Icons.do_disturb_on_rounded,
                  color: Colors.pink,
                  size: 30,
                ),
                highlightColor: Colors.pink,
                onPressed: () {
                  _showDeleteConfirmDialog(userInfo.your_id, widget.userId);
                },
              )
            : new Container(),
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
      if (values != null && values[USER_TYPE] == ADMIN_TYPE) {
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

  _showDeleteConfirmDialog(String id, String userLogin) {
    if (id == userLogin) {
      Toast.show(CAN_NOT_DELETE, context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                title: Text(DELETE_CONFIRM),
                content: Text(DELETE_CONTENT),
                actions: [
                  FlatButton(
                    textColor: kPrimaryColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(BUTTON_CANCEL_TEXT),
                  ),
                  FlatButton(
                    textColor: kPrimaryColor,
                    onPressed: () {
                      _onClickDeleteUser(id);
                      Util.checkUser(widget.userId, context);
                      Navigator.pop(context);
                    },
                    child: Text(BUTTON_ACCEPT_TEXT),
                  ),
                ],
              ));
    }
  }

  Future<void> deleteLoggedIn() async {
    SharedPreferences prefrences = await SharedPreferences.getInstance();
    prefrences.remove(USER_ID);
  }
}
