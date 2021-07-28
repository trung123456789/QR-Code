
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';

class SelectTimeDialog extends StatefulWidget {
  DateTime dateSelected;

  SelectTimeDialog({this.dateSelected});

  @override
  _SelectTimeDialogState createState() => _SelectTimeDialogState();
}

class _SelectTimeDialogState extends State<SelectTimeDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(top: 45),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: CALENDAR_COLOR,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  CALENDAR,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 120,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    minimumYear: 1,
                    maximumYear: 9999,
                    initialDateTime: widget.dateSelected,
                    onDateTimeChanged: (dateSelected) {
                      setState(() {
                        widget.dateSelected = dateSelected;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, widget.dateSelected);
                      },
                      child: Text(
                        CHOICE,
                        style: TextStyle(fontSize: 18),
                      )),
                ),
              ],
            ),
          ), // bottom part
        ],
      ),
    );
  }
}
