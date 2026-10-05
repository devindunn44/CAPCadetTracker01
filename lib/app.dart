import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';

class CapCadetApp extends StatelessWidget {
  const CapCadetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAP Cadet Progress Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B2E6B)),
        cardTheme: const CardTheme(margin: EdgeInsets.zero),
      ),
      home: const DashboardScreen(),
    );
  }
}
