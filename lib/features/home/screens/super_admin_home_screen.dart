import 'package:flutter/material.dart';

import '../../../core/utils/localization.dart';

class SuperAdminHomeScreen extends StatelessWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l('super_admin_home_title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: Text(
          context.l('super_admin_home_title'),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

