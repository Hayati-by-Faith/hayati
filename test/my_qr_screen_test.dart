import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hayati/features/qr/screens/my_qr_screen.dart';
import 'package:hayati/features/qr/screens/qr_capture.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('renders my qr screen', (tester) async {
    await pumpLocalizedScreen(tester, const MyQrScreen());

    expect(find.text('رمز QR الخاص بي'), findsOneWidget);
    expect(find.text('مشاركة'), findsOneWidget);
    expect(find.text('حفظ في المعرض'), findsOneWidget);
  });

  testWidgets('captures non-empty qr bytes', (tester) async {
    final qrKey = GlobalKey();
    late Uint8List capturedBytes;

    await pumpLocalizedScreen(tester, MyQrScreen(qrKey: qrKey));

    await tester.runAsync(() async {
      capturedBytes = await captureQrBytes(qrKey);
    });

    expect(capturedBytes, isNotEmpty);
  });
}
