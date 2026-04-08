import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/qr/screens/qr_scanner_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders qr scanner screen', (tester) async {
    await pumpLocalizedScreen(
      tester,
      QrScannerScreen(
        scannerBuilder: (context, onDetect) => const SizedBox(),
      ),
    );

    expect(find.text('مسح رمز QR'), findsOneWidget);
    expect(find.text('وجّه الكاميرا نحو رمز QR الخاص بالأسرة.'), findsOneWidget);
  });
}

