import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Auth/Signup/components/background.dart';
import 'package:flutter_qr_scan/components/already_have_an_account_acheck.dart';
import 'package:flutter_qr_scan/components/rounded_button.dart';
import 'package:flutter_qr_scan/components/rounded_input_field.dart';
import 'package:flutter_qr_scan/components/rounded_password_field.dart';

class Body extends StatefulWidget {
  final String title;

  Body({Key key, this.title}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController _yourNameController = TextEditingController();
  final TextEditingController _yourIDController = TextEditingController();
  final TextEditingController _yourPhoneController = TextEditingController();
  final TextEditingController _yourPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = 'Admin';

  final DatabaseReference _refUser =
      FirebaseDatabase.instance.reference().child(USER_INFO_FIREBASE);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP",
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            RoundedInputField(
              required: true,
              controller: _yourNameController,
              hintText: "Your Name",
              icon: Icons.account_circle_outlined,
              onChanged: (value) {},
            ),
            RoundedInputField(
              required: true,
              controller: _yourIDController,
              hintText: "Your ID",
              icon: Icons.badge,
              onChanged: (value) {},
            ),
            RoundedInputField(
              required: false,
              controller: _yourPhoneController,
              hintText: "Phone number",
              icon: Icons.contact_phone_outlined,
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              required: true,
              controller: _yourPasswordController,
              onChanged: (value) {},
            ),
            _buildSignupItem(),
            SizedBox(height: size.height * 0.03),
            RoundedButton(
              text: "SIGNUP",
              press: () {
                if (_formKey.currentState.validate()) {
                  // If the form is valid, display a Snackbar.
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
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
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50),
      child: Row(
          children: [
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
              style: TextStyle(color: Colors.deepPurple),
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
          ]
      ),
    );
  }

  void saveUser() {
    String yourName = _yourNameController.text;
    String yourId = _yourIDController.text;
    String yourPhone = _yourPhoneController.text;
    String yourPassword = _yourPasswordController.text;

    Map<String, String> user = {
      'yourName': yourName,
      'yourId': yourId,
      'yourPhone': yourPhone,
      'yourPassword': yourPassword,
      'userType': dropdownValue,
    };

    // Added new user
    _refUser.child(yourId).set(user);
  }
}
