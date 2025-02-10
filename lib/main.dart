// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'services/services.dart';
import 'view/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanSphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lavendarTheme,
      home: const Home(),
    );
  }
}
