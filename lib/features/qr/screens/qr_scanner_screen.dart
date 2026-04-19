import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/utils/localization.dart';

typedef ScannerBuilder =
    Widget Function(BuildContext context, void Function(String code) onDetect);

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key, this.onDetect, this.scannerBuilder});

  final void Function(String code)? onDetect;
  final ScannerBuilder? scannerBuilder;

  @override
  Widget build(BuildContext context) {
    final detect = onDetect ?? (_) {};
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l('scanner_title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.l('scanner_hint'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child:
                scannerBuilder?.call(context, detect) ??
                MobileScanner(
                  onDetect: (capture) {
                    final code = capture.barcodes.isEmpty
                        ? null
                        : capture.barcodes.first.rawValue;
                    if (code != null) {
                      detect(code);
                    }
                  },
                ),
          ),
        ],
      ),
    );
  }
}
