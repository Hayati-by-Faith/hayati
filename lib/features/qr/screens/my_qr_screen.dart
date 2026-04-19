import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/qr_service.dart';
import '../../../core/utils/localization.dart';
import '../../../core/widgets/big_button.dart';
import 'qr_capture.dart';
import 'qr_download.dart'
    if (dart.library.js_interop) 'qr_download_web.dart';

typedef QrBytesHandler = Future<void> Function(Uint8List bytes);

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key, this.onSaveQrBytes, this.qrKey});

  final QrBytesHandler? onSaveQrBytes;
  final GlobalKey? qrKey;

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  late final GlobalKey _qrKey = widget.qrKey ?? GlobalKey();

  Future<Uint8List> _captureQrBytes() async {
    return captureQrBytes(_qrKey);
  }

  Future<void> _shareQr() async {
    final bytes = await _captureQrBytes();
    await _shareQrBytes(bytes);
  }

  Future<void> _shareQrBytes(Uint8List bytes) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            name: 'hayati-qr.png',
            mimeType: 'image/png',
          ),
        ],
      ),
    );
  }

  Future<void> _saveQr() async {
    final bytes = await _captureQrBytes();

    if (widget.onSaveQrBytes != null) {
      await widget.onSaveQrBytes!(bytes);
    } else if (kIsWeb) {
      await downloadQrBytes(bytes);
    } else {
      await _shareQrBytes(bytes);
    }

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
