import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:websocket/PointerController.dart';
import 'main.dart';

class QRCodeScan extends StatefulWidget {
  const QRCodeScan({
    Key? key,
  }) : super(key: key);

  @override
  _QRCodeScanState createState() => _QRCodeScanState();
}

class _QRCodeScanState extends State<QRCodeScan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
                borderWidth: 10,
                borderColor: Colors.blueAccent,
                borderLength: 20,
                borderRadius: 10,
              ),
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                if (result != null) {
                  Navigator.pushNamed(context, '/PointerController');
                }
              },
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (result != null)
                      Text('Data: ${result!.code}',
                          style: const TextStyle(
                            fontSize: 20.0,
                          ))
                    else
                      const Text('Scan a code',
                          style: TextStyle(
                            fontSize: 20.0,
                          )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        resultUri='${result!.code}';
      });
    });
    controller.pauseCamera();
    controller.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
