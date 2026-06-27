import 'package:flutter/material.dart';

import 'clock_screen.dart';

void main() {
  runApp(const ShikenDokeiApp());
}

class ShikenDokeiApp extends StatelessWidget {
  const ShikenDokeiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '試験時計',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ClockScreen(),
    );
  }
}
