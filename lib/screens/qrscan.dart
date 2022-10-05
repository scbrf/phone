import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/selectors/selectors.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({Key? key}) : super(key: key);
  @override
  QrScanScreenState createState() => QrScanScreenState();
}

class QrScanScreenState extends State<QrScanScreen> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    log.d('qrcode reassemble called');
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        distinct: true,
        converter: (Store<AppState> store) => store.state,
        builder: (ctx, articles) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('扫码'),
            ),
            body: Center(
              child: _buildQrView(context),
            ),
          );
        });
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
      if (Platform.isAndroid) {
        controller.pauseCamera();
      }
      controller.resumeCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code!.startsWith('scbrf://')) {
        if (StoreProvider.of<AppState>(context).state.currentStation.isEmpty) {
          controller.pauseCamera();
          StoreProvider.of<AppState>(context).dispatch(
              CurrentStationSelectedAction(
                  scanData.code!.substring('scbrf://'.length)));
        }
      }
      log.d('got qr result ${scanData.code}');
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log.d('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
