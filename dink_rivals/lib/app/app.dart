import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'router.dart';

class DinkRivalsApp extends StatelessWidget {
  const DinkRivalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dink Rivals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
