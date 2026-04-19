import 'package:flutter/material.dart';

class RtlAwareIcon extends StatelessWidget {
  const RtlAwareIcon(this.icon, {super.key, this.size, this.semanticLabel});

  final IconData icon;
  final double? size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, semanticLabel: semanticLabel);
  }
}
