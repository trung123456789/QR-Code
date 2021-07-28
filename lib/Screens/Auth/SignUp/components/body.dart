import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/components/already_have_an_account_acheck.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:flutter_qr_scan/components/rounded_input_field.dart';
import 'package:flutter_qr_scan/components/rounded_password_field.dart';
import 'package:toast/toast.dart';

import 'background.dart';

class Body extends StatefulWidget {
  final String title;

  Body({Key key, this.title}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userIDController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = 'Admin';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "SIGNUP",
                style: TextStyle(
                    fontSize: 25,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              RoundedInputField(
                required: true,
                controller: _userNameController,
                hintText: "User name",
                icon: Icons.account_circle_outlined,
                onChanged: (value) {},
              ),
              RoundedInputField(
                required: true,
                controller: _userIDController,
                hintText: "User ID",
                icon: Icons.badge,
                onChanged: (value) {},
              ),
              RoundedInputField(
                required: false,
                controller: _phoneController,
                hintText: "Phone number",
                icon: Icons.contact_phone_outlined,
                onChanged: (value) {},
              ),
              RoundedPasswordField(
                required: true,
                controller: _passwordController,
                onChanged: (value) {},
              ),
              _buildSignupItem(),
              SizedBox(height: size.height * 0.03),
              RoundedButton(
                text: "SIGNUP",
                press: () {
                  if (_formKey.currentState.validate()) {
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                    saveUser();
                    Navigator.pop(context);
                  }
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: Row(children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 35,
                  ),
                ],
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: dropdownValue,
          style: TextStyle(color: kPrimaryColor),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: <String>['Admin', 'Technician']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ]),
    );
  }

  void saveUser() {
    String userName = _userNameController.text;
    String loginId = _userIDController.text;
    String phoneNumber = _phoneController.text;
    String password = _passwordController.text;

    Map<String, String> userData = {
      'user_name': userName,
      'login_id': loginId,
      'phone_number': phoneNumber,
      'password': password,
      'user_type': dropdownValue,
    };
    CollectionReference user = FirebaseFirestore.instance.collection('User');
    user.doc(loginId).get().then((doc) => {
          if (doc.exists)
            {
              Toast.show("User ID is existed!", context,
                  duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM)
            }
          else
            {user.doc(loginId).set(userData)}
        });
  }
}
