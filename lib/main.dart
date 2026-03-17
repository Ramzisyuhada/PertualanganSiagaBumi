import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petualangansiagabumi/core/features/home_map/map_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Siaga Bumi',
      theme: AppTheme.lightTheme,
      home: MapScreen(),
    );
  }
}