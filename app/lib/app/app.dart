import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import 'theme/app_theme.dart';

class EvacuaApp extends StatelessWidget {
  const EvacuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVACUA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
