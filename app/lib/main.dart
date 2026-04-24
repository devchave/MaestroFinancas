import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MaestroApp());
}

class MaestroApp extends StatelessWidget {
  const MaestroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Maestro Finanças',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
