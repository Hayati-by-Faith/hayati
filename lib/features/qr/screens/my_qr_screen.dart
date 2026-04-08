import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/qr_service.dart';
import '../../../core/utils/localization.dart';
import '../../../core/widgets/big_button.dart';

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  final _qrKey = GlobalKey();

  Future<File> _captureQr() async {
    final boundary =
        _qrKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/hayati-qr.png');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _shareQr() async {
    final file = await _captureQr();
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  Future<void> _saveQr() async {
    await _captureQr();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l('qr_save_button'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payload = const QrService().buildResidentPayload(
      villageId: 'abusir',
      householdId: 'household-demo',
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l('qr_title'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _qrKey,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: QrImageView(
                      data: payload,
                      size: 240,
                      semanticsLabel: context.l('qr_title'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: BigButton(
                      label: context.l('qr_share_button'),
                      icon: Icons.share,
                      onPressed: _shareQr,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BigButton(
                      label: context.l('qr_save_button'),
                      icon: Icons.download,
                      onPressed: _saveQr,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
