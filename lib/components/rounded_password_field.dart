import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/components/text_field_container.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final bool required;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
    this.controller,
    this.required,
  }) : super(key: key);


  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        onChanged: widget.onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock_outline,
            color: kPrimaryColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.visibility),
            color: kPrimaryColor,
            onPressed: _toggle,
          ),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (widget.required && value.isEmpty) {
            return 'Required field! Please enter information';
          }
          return null;
        },
      ),
    );
  }
}
