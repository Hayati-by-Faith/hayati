import 'package:flutter/material.dart';

import '../../../core/utils/localization.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l('staff_home_title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: Text(
          context.l('staff_home_title'),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

