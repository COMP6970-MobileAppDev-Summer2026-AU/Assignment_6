// =============================================================================
// main.dart
// ScanLog — On-Device ML Text Recognition Journal
// COMP 6910 Assignment 6 — Jahidul Arafat (JAJI)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/scan_provider.dart';
import 'screens/front_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ScanProvider()..loadEntries(),
      child:  const ScanLogApp(),
    ),
  );
}

class ScanLogApp extends StatelessWidget {
  const ScanLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanLog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E6B4A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E6B4A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Always start at FrontScreen — shows dev info + known issues
      home: const FrontScreen(),
    );
  }
}
