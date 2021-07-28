import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/Constants/constants.dart';
import 'package:flutter_qr_scan/Screens/Main/TaskHistoryDetail.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'ScanMain.dart';

class QRTaskView extends StatefulWidget {
  final String userId;

  const QRTaskView({Key key, this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRTaskViewState();
}

class _QRTaskViewState extends State<QRTaskView> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Camera'),
          backgroundColor: kPrimaryColor,
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScanMain(
                            userId: widget.userId,
                          )));
                },
                tooltip: "Back",
              );
            },
          )),
      body: Column(
        children: <Widget>[
          Expanded(flex: 6, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        width: 70,
                        height: 35,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(29),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Flash',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold));
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        width: 70,
                        height: 35,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(29),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () async {
                              await controller?.resumeCamera();
                            },
                            child: FutureBuilder(
                              builder: (context, snapshot) {
                                return Text('Re-Scan',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold));
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        width: 110,
                        height: 35,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(29),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text('Camera facing',
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold));
                                } else {
                                  return Text('Camera facing',
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold));
                                }
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      var infoQr = scanData.code.split(SLASH);
      if (infoQr.length == 2) {
        controller?.pauseCamera();
        String hashCode = infoQr[0];
        String taskId = infoQr[1];

        if (hashCode == QR_MATCH_CODE) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskHistoryDetail(
                      taskId: taskId,
                      userId: widget.userId,
                    )),
          );
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
