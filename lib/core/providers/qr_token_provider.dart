import 'package:flutter_riverpod/legacy.dart';

// Holds the signed QR token string returned by `createHousehold` (and later,
// `signQrToken`). Consumed by the enrollment success screen and MyQrScreen so
// the signed token is rendered instead of an unsigned `hayati://qr?...` URL.
// Null until a QR token has been issued this session.
final lastQrTokenProvider = StateProvider<String?>((ref) => null);
