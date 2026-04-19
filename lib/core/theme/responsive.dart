import 'package:flutter/widgets.dart';

/// Breakpoints used across the Hayati responsive layouts.
///
/// Web W4 ships mobile-first. Breakpoints are:
/// - `phone`    : width <  [kPhoneMaxWidth]
/// - `tablet`   : [kPhoneMaxWidth]  ≤ width < [kTabletMaxWidth]
/// - `desktop`  : width ≥ [kTabletMaxWidth]
///
/// Arabic RTL and 48 dp minimum touch targets are preserved at every
/// breakpoint. See `hayati-architecture.md` §26 and `plans/web-support.md` §W4.
const double kPhoneMaxWidth = 600;
const double kTabletMaxWidth = 1024;

/// Device-size bucket used to select layouts.
enum Breakpoint { phone, tablet, desktop }

Breakpoint breakpointForWidth(double width) {
  if (width < kPhoneMaxWidth) {
    return Breakpoint.phone;
  }
  if (width < kTabletMaxWidth) {
    return Breakpoint.tablet;
  }
  return Breakpoint.desktop;
}

/// Picks a value per [Breakpoint]. `phone` is required; `tablet` and
/// `desktop` fall back to the next-narrower provided value.
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.phone,
    this.tablet,
    this.desktop,
  });

  final T phone;
  final T? tablet;
  final T? desktop;

  T resolve(Breakpoint breakpoint) {
    switch (breakpoint) {
      case Breakpoint.phone:
        return phone;
      case Breakpoint.tablet:
        return tablet ?? phone;
      case Breakpoint.desktop:
        return desktop ?? tablet ?? phone;
    }
  }
}

extension ResponsiveContext on BuildContext {
  Breakpoint get breakpoint =>
      breakpointForWidth(MediaQuery.sizeOf(this).width);

  bool get isPhone => breakpoint == Breakpoint.phone;
  bool get isTablet => breakpoint == Breakpoint.tablet;
  bool get isDesktop => breakpoint == Breakpoint.desktop;
}
