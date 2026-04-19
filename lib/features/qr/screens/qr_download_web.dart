import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> downloadQrBytes(Uint8List bytes) async {
  final blob = web.Blob(
    JSArray.from<web.BlobPart>([bytes.toJS].toJS),
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = 'hayati-qr.png'
    ..style.display = 'none';

  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();

  Future<void>.delayed(const Duration(seconds: 1), () {
    web.URL.revokeObjectURL(url);
  });
}
