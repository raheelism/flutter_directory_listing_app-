import 'dart:async';

import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({Key? key}) : super(key: key);

  @override
  State<ScanQR> createState() {
    return _ScanQRState();
  }
}

class _ScanQRState extends State<ScanQR> with WidgetsBindingObserver {
  final _controller = MobileScannerController();

  Barcode? _barcode;
  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _subscription = _controller.barcodes.listen(_handleBarcode);

    Future.delayed(const Duration(seconds: 500), () async {
      _controller.start();
    });
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted && _barcode == null) {
      _barcode = barcodes.barcodes.first;
      Navigator.pop(context, _barcode?.rawValue);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _controller.dispose();
    _subscription = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!_controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        break;

      case AppLifecycleState.resumed:
        _subscription = _controller.barcodes.listen(_handleBarcode);

        await _controller.start();
        break;
      case AppLifecycleState.inactive:
        await _subscription?.cancel();
        _subscription = null;
        await _controller.stop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('scan_qrcode'),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          MobileScanner(
            onDetect: _handleBarcode,
          ),
          Positioned(
            bottom: 50,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  child: IconButton(
                    enableFeedback: true,
                    icon: Icon(
                      _controller.torchEnabled
                          ? Icons.flashlight_on_outlined
                          : Icons.flashlight_off_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _controller.toggleTorch();
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
