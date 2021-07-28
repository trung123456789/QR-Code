import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_scan/Constants/MessageConstants.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
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
  bool adminAuth = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  bool isLoading = false;
  bool hasMore = true;
  int userLimit = 20;
  DocumentSnapshot lastUser;
  static ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    Util.checkUser(widget.userId, context);
    if (widget.userId != null) {
      checkAuthority(widget.userId);
    }

    _scrollController = ScrollController();
    getUser();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getUser();
      }
    });
  }

  getUser() async {
    if (!hasMore) {
      print('No More User');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastUser == null) {
      querySnapshot = await firestore
          .collection('User')
          .orderBy('user_name')
          .limit(userLimit)
          .get();
    } else {
      querySnapshot = await firestore
          .collection('User')
          .orderBy('user_name')
          .startAfterDocument(lastUser)
          .limit(userLimit)
          .get();
      print(1);
    }
    if (querySnapshot.docs.length == 0) {
      hasMore = false;
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (querySnapshot.docs.length < userLimit) {
      hasMore = false;
    }
    lastUser = querySnapshot.docs[querySnapshot.docs.length - 1];
    users.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          centerTitle: true,
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
        body: SafeArea(
            child: Column(children: [
          Expanded(
            child: users.length == 0
                ? Center(
                    child: Text('No Data...'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _buildUserInfoItem(
                        userInfo: users[index],
                      );
                    }),
          ),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Loading...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                )
              : Container()
        ])));
  }

  _showMaterialDialog() {
    Util.checkUser(widget.userId, context);
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
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                        LoginScreen()), (Route<dynamic> route) => false);
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => LoginScreen()),
                    // );
                  },
                  child: Text(BUTTON_ACCEPT_TEXT),
                ),
              ],
            ));
  }

  Widget _buildUserInfoItem({DocumentSnapshot userInfo}) {
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
                    userInfo.get('user_name'),
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
                    userInfo.get('user_type'),
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
                  _showDeleteConfirmDialog(
                      userInfo.get('login_id'), widget.userId);
                },
              )
            : new Container(),
      ]),
    );
  }

  // Remove the selected item from the list model.
  void _onClickDeleteUser(String id) {
    CollectionReference user = FirebaseFirestore.instance.collection('User');
    if (id != null) {
      user
          .doc(id)
          .delete()
          .then((value) => Toast.show("Deleted user!", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM))
          .catchError((error) => Toast.show("Delete user failed!", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM));
    }
  }

  Future<void> checkAuthority(String userId) async {
    CollectionReference user = FirebaseFirestore.instance.collection('User');
    user
        .where('login_id', isEqualTo: userId)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc.get("user_type") == ADMIN_TYPE) {
          setState(() {
            adminAuth = true;
          });
        } else {
          setState(() {
            adminAuth = false;
          });
        }
      });
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
    var userId = prefrences.getString('userId');
  }
}
